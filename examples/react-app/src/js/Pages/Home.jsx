import React, { useState } from 'react';

export default function Home({ name }) {
  const [count, setCount] = useState(0);

  return (
    <div style={{
      fontFamily: 'system-ui, sans-serif',
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '2rem'
    }}>
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: '2rem'
      }}>
        <img src="/images/kemal.png" alt="Kemal" width="80" height="80" />
        <span style={{ fontSize: '2rem', fontWeight: 'bold', margin: '0 1rem', color: '#ccc' }}>+</span>
        <img src="/images/inertia.png" alt="Inertia" width="80" height="80" />
        <span style={{ fontSize: '2rem', fontWeight: 'bold', margin: '0 1rem', color: '#ccc' }}>+</span>
        <img src="/images/react.png" alt="React" width="80" height="80" />
      </div>

      <h1 style={{ marginBottom: '1rem' }}>Hello from {name}!</h1>

      <div className="card">
        <p className="counter-text">
          Counter: <span className="count-value">{count}</span>
        </p>
        <button 
          onClick={() => setCount(count + 1)}
          className="btn-primary"
        >
          Increment
        </button>
      </div>

      <style>{`
        .card {
          margin-top: 2rem;
          padding: 2rem;
          background: white;
          border-radius: 12px;
          text-align: center;
          min-width: 240px;
        }

        .counter-text {
          font-size: 1.25rem;
          color: #374151;
          margin-bottom: 1.5rem;
        }

        .count-value {
          font-weight: 800;
          color: #007bff;
          font-size: 1.5rem;
        }

        .btn-primary {
          padding: 0.75rem 1.5rem;
          background: #007bff;
          color: white;
          border: none;
          border-radius: 8px;
          cursor: pointer;
          font-weight: 600;
          font-size: 1rem;
          transition: all 0.2s;
        }

        .btn-primary:hover {
          background: #0056b3;
        }
      `}</style>
    </div>
  );
}
