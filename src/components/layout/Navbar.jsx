import { useAuth } from '../../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const ROLE_LABELS = {
  teacher: '🎓 Teacher',
  admin:   '🛡️ Admin',
  parent:  '👨‍👩‍👧 Parent',
};

export default function Navbar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <nav className="navbar">
      <h1>📚 LexiLearn</h1>
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
        {user && (
          <>
            <span>{ROLE_LABELS[user.role]} — @{user.username}</span>
            <button onClick={handleLogout}>Sign Out</button>
          </>
        )}
      </div>
    </nav>
  );
}