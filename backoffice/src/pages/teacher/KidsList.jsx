import { useState, useEffect } from 'react';
import { api } from '../../services/api';

export default function KidsList({ canDelete = false, onDelete }) {
  const [kids, setKids] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState(null);
  const [stats, setStats] = useState(null);

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
    } catch (e) {
      setStats({ error: true });
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this kid? This will remove all their data.')) return;
    try {
      await api.delete(`/api/kids/${id}`);
      setKids(prev => prev.filter(k => k.id !== id));
      if (selected?.id === id) { setSelected(null); setStats(null); }
      onDelete?.();
    } catch (e) {
      alert('Failed to delete: ' + e.message);
    }
  };

  const filtered = kids.filter(k => k.username.toLowerCase().includes(search.toLowerCase()));

  if (loading) return <div className="loading-row"><span className="spinner" /> Loading kids...</div>;

  return (
    <div className="kids-panel">
      <div className="panel-top">
        <div className="stat-badge">{kids.length} Students</div>
        <input
          className="search-input"
          placeholder="🔍 Search by name..."
          value={search}
          onChange={e => setSearch(e.target.value)}
        />
      </div>

      <div className="kids-grid">
        {filtered.length === 0 && <p className="empty-msg">No kids found.</p>}
        {filtered.map(kid => (
          <div
            key={kid.id}
            className={`kid-card ${selected?.id === kid.id ? 'active' : ''}`}
            onClick={() => fetchStats(kid)}
          >
            <div className="kid-avatar">{kid.username[0].toUpperCase()}</div>
            <div className="kid-info">
              <h4>{kid.username}</h4>
              <span className="points-badge">⭐ {kid.total_points || 0} pts</span>
            </div>
            {canDelete && (
              <button
                className="btn-delete-sm"
                onClick={e => { e.stopPropagation(); handleDelete(kid.id); }}
              >🗑️</button>
            )}
          </div>
        ))}
      </div>

      {selected && (
        <div className="stats-panel">
          <h3>📊 Stats for {selected.username}</h3>
          {!stats && <div className="loading-row"><span className="spinner" /> Fetching...</div>}
          {stats?.error && <p className="error-msg">Failed to load stats.</p>}
          {stats && !stats.error && (
            <div>
              <div className="stats-summary">
                <div className="stat-chip">
                  <span>Total Points</span>
                  <strong>⭐ {stats.total_points}</strong>
                </div>
                <div className="stat-chip">
                  <span>Games Played</span>
                  <strong>🎮 {stats.games_stats?.length || 0}</strong>
                </div>
              </div>
              {stats.games_stats?.length > 0 && (
                <table className="stats-table">
                  <thead>
                    <tr>
                      <th>Game</th>
                      <th>Times Played</th>
                      <th>Points Earned</th>
                    </tr>
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
            </div>
          )}
        </div>
      )}
    </div>
  );
}
