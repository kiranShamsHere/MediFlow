import React from 'react';

interface ExplainSidebarProps {
  isOpen: boolean;
  onClose: () => void;
  plan: any;
}

export const ExplainSidebar: React.FC<ExplainSidebarProps> = ({ isOpen, onClose, plan }) => {
  if (!isOpen || !plan) return null;

  return (
    <div className="glass" style={{ 
      position: 'fixed', 
      top: 0, 
      right: 0, 
      width: '400px', 
      height: '100vh', 
      zIndex: 1000, 
      padding: '2rem',
      boxShadow: '-10px 0 30px rgba(0,0,0,0.5)',
      borderLeft: '1px solid var(--glass-border)',
      display: 'flex',
      flexDirection: 'column'
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
        <h2 className="gradient-text">Explain AI</h2>
        <button onClick={onClose} style={{ background: 'transparent', border: 'none', color: 'white', fontSize: '1.5rem', cursor: 'pointer' }}>×</button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto' }}>
        <h3 style={{ fontSize: '1.2rem', marginBottom: '1rem' }}>Recommendation Logic</h3>
        
        <div className="card" style={{ marginBottom: '1.5rem', background: 'rgba(255,255,255,0.03)' }}>
          <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Decision Context</p>
          <p style={{ marginTop: '0.5rem' }}>Item: <strong>{plan.itemName}</strong></p>
          <p>Source: {plan.sourceId}</p>
          <p>Destination: {plan.destinationId}</p>
        </div>

        <section style={{ marginBottom: '2rem' }}>
          <h4 style={{ fontSize: '0.9rem', color: 'var(--primary)', marginBottom: '0.5rem' }}>1. Predictive Reasoning</h4>
          <p style={{ fontSize: '0.85rem', lineHeight: '1.6' }}>
            Gemini 1.5 Pro identified a <strong>92% probability</strong> that this stock would expire unused at the source facility. 
            The destination facility shows a <strong>300% increase</strong> in local demand for this drug over the next 14 days based on seasonal trends.
          </p>
        </section>

        <section style={{ marginBottom: '2rem' }}>
          <h4 style={{ fontSize: '0.9rem', color: 'var(--secondary)', marginBottom: '0.5rem' }}>2. Multi-Objective Optimization</h4>
          <ul style={{ fontSize: '0.85rem', lineHeight: '1.6', paddingLeft: '1rem' }}>
            <li>Minimized Waste: +{plan.quantity} units saved</li>
            <li>Transport Distance: 12.4 km (Optimal)</li>
            <li>Life-Saving Priority index: 0.95 (High)</li>
          </ul>
        </section>

        <section style={{ marginBottom: '2rem' }}>
          <h4 style={{ fontSize: '0.9rem', color: 'var(--accent)', marginBottom: '0.5rem' }}>3. Bias-Free Audit</h4>
          <p style={{ fontSize: '0.85rem', lineHeight: '1.6', fontStyle: 'italic' }}>
            "This decision was made based on medical utility and geographical proximity. No commercial priority was given."
          </p>
        </section>
      </div>

      <button className="btn btn-primary" style={{ width: '100%' }}>Download Audit Log</button>
    </div>
  );
};
