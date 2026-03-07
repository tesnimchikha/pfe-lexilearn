import { useState, useEffect } from 'react';
import { api } from '../../services/api';

export default function TeacherDashboard() {
  const [activeTab, setActiveTab] = useState('kids');

  return (
    <div className="dashboard">
      <h2>🎓 Teacher Dashboard</h2>
      <p>Manage your students and exercises</p>
      <div className="tabs">
        <button className={`tab-btn ${activeTab === 'kids' ? 'active' : ''}`} onClick={() => setActiveTab('kids')}>
          👦 Kids List
        </button>
        <button className={`tab-btn ${activeTab === 'exercises' ? 'active' : ''}`} onClick={() => setActiveTab('exercises')}>
          📝 Exercises
        </button>
      </div>
      {activeTab === 'kids'      && <KidsList />}
      {activeTab === 'exercises' && <ExercisesManager />}
    </div>
  );
}

function KidsList() {
  const [kids, setKids]         = useState([]);
  const [search, setSearch]     = useState('');
  const [loading, setLoading]   = useState(true);
  const [selected, setSelected] = useState(null);
  const [stats, setStats]       = useState(null);

  useEffect(() => {
    api.get('/api/kids')
      .then(setKids)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const fetchStats = async (kid) => {
    setSelected(kid);
    setStats(null);
    try {
      const s = await api.get(`/user-full-stats/${kid.id}`);
      setStats(s);
    } catch {
      setStats({ error: true });
    }
  };

  const filtered = kids.filter(k =>
    k.username.toLowerCase().includes(search.toLowerCase())
  );

  if (loading) return <div className="loading">Loading kids...</div>;

  return (
    <div>
      <div className="card">
        <h3>Students ({kids.length})</h3>
        <input
          className="search-input"
          placeholder="Search by name..."
          value={search}
          onChange={e => setSearch(e.target.value)}
        />
        <div className="kids-grid">
          {filtered.map(kid => (
            <div
              key={kid.id}
              className={`kid-card ${selected?.id === kid.id ? 'selected' : ''}`}
              onClick={() => fetchStats(kid)}
            >
              <div className="kid-avatar">{kid.username[0].toUpperCase()}</div>
              <h4>{kid.username}</h4>
              <span>⭐ {kid.total_points || 0} pts</span>
            </div>
          ))}
        </div>
      </div>

      {selected && (
        <div className="card">
          <h3>📊 Stats — {selected.username}</h3>
          {!stats && <div className="loading">Loading...</div>}
          {stats?.error && <div className="error-msg">Failed to load stats.</div>}
          {stats && !stats.error && (
            <>
              <div className="stats-row">
                <div className="stat-box">
                  <div className="stat-value">⭐ {stats.total_points}</div>
                  <div className="stat-label">Total Points</div>
                </div>
                <div className="stat-box">
                  <div className="stat-value">🎮 {stats.games_stats?.length || 0}</div>
                  <div className="stat-label">Games Played</div>
                </div>
              </div>
              {stats.games_stats?.length > 0 && (
                <table>
                  <thead>
                    <tr><th>Game</th><th>Times Played</th><th>Points</th></tr>
                  </thead>
                  <tbody>
                    {stats.games_stats.map((g, i) => (
                      <tr key={i}>
                        <td>{g.game_name}</td>
                        <td>{g.times_played}</td>
                        <td>⭐ {g.total_points_from_game}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </>
          )}
        </div>
      )}
    </div>
  );
}

const CATEGORIES = ['Reading', 'Writing', 'Phonics', 'Memory', 'Math', 'Visual'];

function ExercisesManager() {
  const [exercises, setExercises] = useState([]);
  const [loading, setLoading]     = useState(true);
  const [title, setTitle]         = useState('');
  const [description, setDesc]    = useState('');
  const [category, setCategory]   = useState(CATEGORIES[0]);
  const [error, setError]         = useState('');

  useEffect(() => {
    api.get('/api/exercises')
      .then(setExercises)
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const handleAdd = async (e) => {
    e.preventDefault();
    try {
      const ex = await api.post('/api/exercises', {
        title,
        description: `[${category}] ${description}`,
      });
      setExercises(prev => [ex, ...prev]);
      setTitle('');
      setDesc('');
    } catch (err) {
      setError(err.message);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this exercise?')) return;
    try {
      await api.delete(`/api/exercises/${id}`);
      setExercises(prev => prev.filter(e => e.id !== id));
    } catch (err) {
      alert('Failed: ' + err.message);
    }
  };

  if (loading) return <div className="loading">Loading exercises...</div>;

  return (
    <div>
      <div className="card">
        <h3>➕ Add Exercise</h3>
        {error && <div className="error-msg">{error}</div>}
        <form onSubmit={handleAdd}>
          <div className="form-group">
            <label>Title</label>
            <input value={title} onChange={e => setTitle(e.target.value)} required placeholder="Exercise title..." />
          </div>
          <div className="form-group">
            <label>Category</label>
            <select value={category} onChange={e => setCategory(e.target.value)}>
              {CATEGORIES.map(c => <option key={c}>{c}</option>)}
            </select>
          </div>
          <div className="form-group">
            <label>Description</label>
            <textarea value={description} onChange={e => setDesc(e.target.value)} required rows={3} />
          </div>
          <button className="btn btn-primary" type="submit">Add Exercise</button>
        </form>
      </div>
      <div className="card">
        <h3>📋 All Exercises</h3>
        {exercises.length === 0 && <p style={{color:'#888'}}>No exercises yet.</p>}
        <table>
          <thead>
            <tr><th>Title</th><th>Description</th><th>Action</th></tr>
          </thead>
          <tbody>
            {exercises.map(ex => (
              <tr key={ex.id}>
                <td><strong>{ex.title}</strong></td>
                <td>{ex.description}</td>
                <td><button className="btn-danger" onClick={() => handleDelete(ex.id)}>Delete</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}