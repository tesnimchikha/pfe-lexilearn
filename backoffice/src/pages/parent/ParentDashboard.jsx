import { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../services/api';

export default function ParentDashboard() {
  const { user }              = useAuth();
  const [stats, setStats]     = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      api.get(`/user-full-stats/${user.id}`),
      api.get(`/game-history/${user.id}`),
    ]).then(([s, h]) => {
      setStats(s);
      setHistory(h.history || []);
    }).catch(console.error)
      .finally(() => setLoading(false));
  }, [user.id]);

  if (loading) return <div className="loading">Loading your stats...</div>;

  const points = stats?.total_points || 0;
  const level  = points >= 500 ? 'Advanced' : points >= 200 ? 'Intermediate' : 'Beginner';
  const maxPts = stats?.games_stats?.length
    ? Math.max(...stats.games_stats.map(g => Number(g.total_points_from_game)))
    : 1;

  return (
    <div className="dashboard">
      <h2>👋 Welcome, {user.username}!</h2>
      <p>Track your learning progress</p>

      <div className="stats-row">
        <div className="stat-box">
          <div className="stat-value">⭐ {points}</div>
          <div className="stat-label">Total Points</div>
        </div>
        <div className="stat-box">
          <div className="stat-value">🎮 {stats?.games_stats?.length || 0}</div>
          <div className="stat-label">Games Played</div>
        </div>
        <div className="stat-box">
          <div className="stat-value">📈 {level}</div>
          <div className="stat-label">Your Level</div>
        </div>
      </div>

      {stats?.games_stats?.length > 0 && (
        <div className="card">
          <h3>🎯 Performance by Game</h3>
          {stats.games_stats.map((g, i) => {
            const pct = Math.round((Number(g.total_points_from_game) / maxPts) * 100);
            return (
              <div key={i} className="progress-row">
                <div className="progress-label">
                  <span>{g.game_name}</span>
                  <span>⭐ {g.total_points_from_game}</span>
                </div>
                <div className="progress-bar">
                  <div className="progress-fill" style={{ width: `${pct}%` }} />
                </div>
              </div>
            );
          })}
        </div>
      )}

      <div className="card">
        <h3>📜 Recent Activity</h3>
        {history.length === 0
          ? <p style={{ color: '#888' }}>No games played yet!</p>
          : history.slice(0, 10).map((h, i) => (
            <div key={i} className="history-item">
              <span>{h.game_name}</span>
              <span style={{ color: '#4f46e5', fontWeight: 'bold' }}>+{h.points_earned} pts</span>
              <span style={{ color: '#aaa' }}>{new Date(h.played_at).toLocaleDateString()}</span>
            </div>
          ))
        }
      </div>
    </div>
  );
}