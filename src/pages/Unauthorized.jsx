import { useNavigate } from 'react-router-dom';

export default function Unauthorized() {
  const navigate = useNavigate();
  return (
    <div className="fullpage-loader" style={{ flexDirection: 'column', gap: '1rem' }}>
      <span style={{ fontSize: '4rem' }}>🚫</span>
      <h2 style={{ color: '#ff6b6b' }}>Access Denied</h2>
      <p style={{ color: '#999' }}>You don't have permission to view this page.</p>
      <button className="btn-primary" style={{ width: 'auto', padding: '0.75rem 2rem' }} onClick={() => navigate(-1)}>
        Go Back
      </button>
    </div>
  );
}
