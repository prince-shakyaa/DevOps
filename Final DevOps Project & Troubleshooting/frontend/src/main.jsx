import React, { useEffect, useState } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'

function App() {
  const [items, setItems] = useState([])
  const [health, setHealth] = useState('checking...')
  const [form, setForm] = useState({ title: '', location: '', kind: 'lost' })

  const load = () => fetch('/api/items').then(r => r.json()).then(setItems)

  useEffect(() => {
    load()
    fetch('/api/health').then(r => r.json())
      .then(h => setHealth(`API ${h.status}, database ${h.db}`))
      .catch(() => setHealth('API unreachable'))
  }, [])

  const submit = async e => {
    e.preventDefault()
    await fetch('/api/items', {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(form),
    })
    setForm({ title: '', location: '', kind: 'lost' })
    load()
  }

  const markReturned = async id => {
    await fetch(`/api/items/${id}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: 'returned' }),
    })
    load()
  }

  return (
    <main>
      <h1>Campus Lost &amp; Found</h1>
      <p className="health">{health}</p>
      <form onSubmit={submit}>
        <input placeholder="Item" value={form.title} required
               onChange={e => setForm({ ...form, title: e.target.value })} />
        <input placeholder="Where" value={form.location} required
               onChange={e => setForm({ ...form, location: e.target.value })} />
        <select value={form.kind} onChange={e => setForm({ ...form, kind: e.target.value })}>
          <option value="lost">lost</option><option value="found">found</option>
        </select>
        <button>Report</button>
      </form>
      <table>
        <thead><tr><th>#</th><th>Item</th><th>Where</th><th>Type</th><th>Status</th><th /></tr></thead>
        <tbody>
          {items.map(i => (
            <tr key={i.id} className={i.status}>
              <td>{i.id}</td><td>{i.title}</td><td>{i.location}</td><td>{i.kind}</td><td>{i.status}</td>
              <td>{i.status === 'open' && <button onClick={() => markReturned(i.id)}>Mark returned</button>}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  )
}

createRoot(document.getElementById('root')).render(<App />)
