import { useState, useEffect } from 'react';
import { api } from '../../services/api';

export default function AdminDashboard() {
  const [kids, setKids]       = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch]   = useState('');

  useEffect(() => {
    api.get('/api/kids')
      .then(setKids)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this student?')) return;
    try {
      await api.delete(`/api/kids/${id}`);
      setKids(prev => prev.filter(k => k.id !== id));
    } catch (err) {
      alert('Failed: ' + err.message);
    }
  };

  const filtered = kids.filter(k =>
    k.username.toLowerCase().includes(search.toLowerCase())
  );

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div className="dashboard">
      <h2>🛡️ Admin Dashboard</h2>
      <p>Full access — manage all student accounts</p>
      <div className="card">
        <h3>All Students ({kids.length})</h3>
        <input
          className="search-input"
          placeholder="Search by name..."
          value={search}
          onChange={e => setSearch(e.target.value)}
        />
        <table>
          <thead>
            <tr><th>#</th><th>Username</th><th>Points</th><th>Action</th></tr>
          </thead>
          <tbody>
            {filtered.map((kid, i) => (
              <tr key={kid.id}>
                <td>{i + 1}</td>
                <td><strong>{kid.username}</strong></td>
                <td>⭐ {kid.total_points || 0}</td>
                <td>
                  <button className="btn-danger" onClick={() => handleDelete(kid.id)}>
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}