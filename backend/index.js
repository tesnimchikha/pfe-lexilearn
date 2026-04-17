const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_key_change_this';

app.use(cors({
  origin: function(origin, callback) {
    // Autorise toutes les origines localhost (peu importe le port)
    if (!origin || origin.startsWith('http://localhost')) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'dyslexia_app',
  password: process.env.DB_PASSWORD || 'admin',
  port: process.env.DB_PORT || 5432,
});

pool.connect((err) => {
  if (err) console.error('❌ Connection Error:', err.stack);
  else console.log('✅ Connected to database successfully!');
});

// ==================== Helper: Verify Token ====================
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// ==================== Public Routes ====================

// Register
app.post('/register', async (req, res) => {
  const { username, password, role } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      'INSERT INTO users (username, password, role) VALUES ($1, $2, $3) RETURNING id, username, role',
      [username, hashedPassword, role]
    );

    const newUser = result.rows[0];

    // Generation mta' el Token
    const token = jwt.sign(
      { id: newUser.id, username: newUser.username, role: newUser.role },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    // ✅ El Token lezem ikoun hne (root level)
    res.status(201).json({
      message: 'User registered',
      token: token, // <--- HNA EL MUHEM
      user: {
        id: newUser.id,
        username: newUser.username,
        role: newUser.role
      }
    });

    console.log(`✅ User ${username} registered successfully!`);
  } catch (err) {
    console.error('❌ Register Error:', err.message);
    if (err.code === '23505') {
      res.status(400).json({ error: 'Username already exists' });
    } else {
      res.status(500).json({ error: 'Database error' });
    }
  }
});
// Login
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }
    const user = result.rows[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }
    const token = jwt.sign(
      { id: user.id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    delete user.password;
    res.json({ success: true, token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});
// Update Avatar
app.post('/update-avatar', authenticateToken, async (req, res) => {
  const { userId, avatarId } = req.body;
  if (!userId || !avatarId) {
    return res.status(400).json({ error: 'userId and avatarId are required' });
  }
  try {
    await pool.query(
      'UPDATE users SET avatar_id = $1 WHERE id = $2',
      [avatarId, userId]
    );
    res.json({ success: true, message: 'Avatar updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update avatar' });
  }
});

// Get current user from token
app.get('/me', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, username, role, total_points, avatar_id FROM users WHERE id = $1',
      [req.user.id]
    );
    if (result.rows.length === 0) return res.sendStatus(404);
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});

// ==================== Protected Routes ====================

// GET all kids
app.get('/api/kids', authenticateToken, async (req, res) => {
  if (req.user.role !== 'teacher' && req.user.role !== 'admin') return res.sendStatus(403);
  try {
    const result = await pool.query(
      'SELECT id, username, total_points FROM users WHERE role = $1 ORDER BY id',
      ['parent']
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});

// DELETE a kid (admin only)
app.delete('/api/kids/:id', authenticateToken, async (req, res) => {
  if (req.user.role !== 'admin') return res.sendStatus(403);
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM game_sessions WHERE user_id = $1', [id]);
    const result = await pool.query('DELETE FROM users WHERE id = $1 AND role = $2 RETURNING id', [id, 'parent']);
    if (result.rowCount === 0) return res.status(404).json({ error: 'Kid not found' });
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete kid' });
  }
});

// GET all exercises
app.get('/api/exercises', authenticateToken, async (req, res) => {
  if (req.user.role !== 'teacher') return res.sendStatus(403);
  try {
    const result = await pool.query('SELECT * FROM exercises ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});

// POST a new exercise
app.post('/api/exercises', authenticateToken, async (req, res) => {
  if (req.user.role !== 'teacher') return res.sendStatus(403);
  const { title, description } = req.body;
  if (!title || !description) return res.status(400).json({ error: 'title and description are required' });
  try {
    const result = await pool.query(
      'INSERT INTO exercises (title, description) VALUES ($1, $2) RETURNING *',
      [title, description]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});

// DELETE an exercise
app.delete('/api/exercises/:id', authenticateToken, async (req, res) => {
  if (req.user.role !== 'teacher') return res.sendStatus(403);
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM exercises WHERE id = $1', [id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});

// User stats
app.get('/user-stats/:userId', authenticateToken, async (req, res) => {
  const { userId } = req.params;
  if (req.user.id != userId && req.user.role !== 'teacher' && req.user.role !== 'admin') return res.sendStatus(403);
  try {
    const result = await pool.query('SELECT total_points FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json({ total_points: result.rows[0].total_points || 0 });
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});

app.post('/add-points', authenticateToken, async (req, res) => {
  const { userId, pointsToAdd } = req.body;
  try {
    const result = await pool.query(
      'UPDATE users SET total_points = COALESCE(total_points, 0) + $1 WHERE id = $2 RETURNING total_points',
      [pointsToAdd, userId]
    );
    res.json({ success: true, newTotal: result.rows[0].total_points });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update points' });
  }
});

app.post('/game-session', authenticateToken, async (req, res) => {
  const { userId, gameName, pointsEarned } = req.body;
  if (req.user.id != userId) return res.sendStatus(403);
  if (!userId || !gameName || pointsEarned == null) {
    return res.status(400).json({ error: 'userId, gameName, and pointsEarned are required' });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      'INSERT INTO game_sessions (user_id, game_name, points_earned) VALUES ($1, $2, $3)',
      [userId, gameName, pointsEarned]
    );
    const result = await client.query(
      'UPDATE users SET total_points = COALESCE(total_points, 0) + $1 WHERE id = $2 RETURNING total_points',
      [pointsEarned, userId]
    );
    await client.query('COMMIT');
    res.json({ success: true, newTotal: result.rows[0].total_points });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Failed to save game session' });
  } finally {
    client.release();
  }
});

app.get('/game-history/:userId', authenticateToken, async (req, res) => {
  const { userId } = req.params;
  if (req.user.id != userId && req.user.role !== 'teacher' && req.user.role !== 'admin') return res.sendStatus(403);
  try {
    const result = await pool.query(
      `SELECT game_name, points_earned, played_at FROM game_sessions WHERE user_id = $1 ORDER BY played_at DESC LIMIT 50`,
      [userId]
    );
    res.json({ success: true, history: result.rows });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch game history' });
  }
});

app.get('/user-full-stats/:userId', authenticateToken, async (req, res) => {
  const { userId } = req.params;
  if (req.user.id != userId && req.user.role !== 'teacher' && req.user.role !== 'admin') return res.sendStatus(403);
  try {
    const userResult = await pool.query('SELECT total_points, username FROM users WHERE id = $1', [userId]);
    const gamesResult = await pool.query(
      `SELECT game_name, COUNT(*) as times_played, SUM(points_earned) as total_points_from_game FROM game_sessions WHERE user_id = $1 GROUP BY game_name`,
      [userId]
    );
    if (userResult.rows.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json({
      success: true,
      username: userResult.rows[0].username,
      total_points: userResult.rows[0].total_points || 0,
      games_stats: gamesResult.rows
    });
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});