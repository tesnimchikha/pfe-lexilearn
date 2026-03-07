# 📚 LexiLearn — Back Office

A React back-office for the LexiLearn dyslexia Flutter app.

## 🚀 Quick Start

### Backend
```bash
node index.js
```
Server runs on http://localhost:3000

### Frontend
```bash
cd backoffice
npm install
npm run dev
```
Frontend runs on http://localhost:5173

---

## 👥 Roles

| Role    | Access |
|---------|--------|
| 🎓 **Teacher** | View all kids + their stats, manage exercises by category |
| 🛡️ **Admin** | All teacher access + delete kids |
| 👨‍👩‍👧 **Parent** | View own profile, points, game history |

---

## 📁 Project Structure

```
backoffice/
├── src/
│   ├── components/
│   │   ├── auth/         Login, Register, PrivateRoute
│   │   └── layout/       Navbar
│   ├── context/          AuthContext (JWT session)
│   ├── pages/
│   │   ├── teacher/      Dashboard, KidsList, ExercisesManager
│   │   ├── admin/        AdminDashboard
│   │   └── parent/       ParentDashboard
│   └── services/         api.js (fetch wrapper)
└── package.json
```

## 🗄️ DB Tables Required

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role VARCHAR(20) NOT NULL,  -- 'teacher', 'admin', 'parent'
  total_points INT DEFAULT 0,
  avatar_id INT
);

CREATE TABLE exercises (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT
);

CREATE TABLE game_sessions (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  game_name VARCHAR(100),
  points_earned INT,
  played_at TIMESTAMP DEFAULT NOW()
);
```
