import { useState, useEffect } from 'react';
import { api } from '../../services/api';

const CATEGORIES = ['Alphabets', 'Numbers', 'Colors', 'Puzzles', 'Communication', 'Mathematics', 'Daily Challenge'];

export default function ExercisesManager() {
  const [exercises, setExercises] = useState([]);
  const [loading, setLoading] = useState(true);
  const [form, setForm] = useState({ title: '', description: '', category: CATEGORIES[0] });
  const [submitting, setSubmitting] = useState(false);
  const [filterCat, setFilterCat] = useState('All');
  const [error, setError] = useState('');

  const load = () => {
    api.get('/api/exercises')
      .then(setExercises)
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const handleAdd = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setError('');
    try {
      const desc = `[${form.category}] ${form.description}`;
      const ex = await api.post('/api/exercises', { title: form.title, description: desc });
      setExercises(prev => [ex, ...prev]);
      setForm({ ...form, title: '', description: '' });
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
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

  const parseCategory = (desc) => {
    const m = desc?.match(/^\[(.+?)\]/);
    return m ? m[1] : 'General';
  };

  const filtered = filterCat === 'All'
    ? exercises
    : exercises.filter(e => parseCategory(e.description) === filterCat);

  return (
    <div className="exercises-panel">
      <div className="add-exercise-card">
        <h3>➕ Add New Exercise</h3>
        <form onSubmit={handleAdd} className="exercise-form">
          <div className="form-row">
            <div className="field-group">
              <label>Title</label>
              <input
                type="text"
                placeholder="Exercise title..."
                value={form.title}
                onChange={e => setForm({ ...form, title: e.target.value })}
                required
              />
            </div>
            <div className="field-group">
              <label>Category</label>
              <select
                value={form.category}
                onChange={e => setForm({ ...form, category: e.target.value })}
              >
                {CATEGORIES.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>
          </div>
          <div className="field-group">
            <label>Description</label>
            <textarea
              placeholder="Describe the exercise..."
              value={form.description}
              onChange={e => setForm({ ...form, description: e.target.value })}
              rows={3}
              required
            />
          </div>
          {error && <div className="error-msg">⚠️ {error}</div>}
          <button type="submit" className="btn-primary" disabled={submitting}>
            {submitting ? <span className="spinner" /> : 'Add Exercise'}
          </button>
        </form>
      </div>

      <div className="filter-row">
        {['All', ...CATEGORIES].map(c => (
          <button
            key={c}
            className={`filter-chip ${filterCat === c ? 'active' : ''}`}
            onClick={() => setFilterCat(c)}
          >{c}</button>
        ))}
      </div>

      {loading && <div className="loading-row"><span className="spinner" /> Loading exercises...</div>}

      <div className="exercises-list">
        {filtered.length === 0 && !loading && <p className="empty-msg">No exercises in this category.</p>}
        {filtered.map(ex => (
          <div key={ex.id} className="exercise-item">
            <div className="exercise-cat-tag">{parseCategory(ex.description)}</div>
            <div className="exercise-body">
              <h4>{ex.title}</h4>
              <p>{ex.description?.replace(/^\[.+?\]\s*/, '')}</p>
            </div>
            <button className="btn-delete-sm" onClick={() => handleDelete(ex.id)}>🗑️</button>
          </div>
        ))}
      </div>
    </div>
  );
}