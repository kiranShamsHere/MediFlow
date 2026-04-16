'use client';

import React, { useState, useEffect } from 'react';
import { generateMockData } from '@/lib/ai/mockData';
import { MediFlowAI, RedistributionPlan, InventoryItem, Facility } from '@/lib/ai/engine';
import { ExplainSidebar } from '@/components/ExplainSidebar';

export default function Home() {
  const [data, setData] = useState<{ facilities: Facility[], inventory: InventoryItem[] } | null>(null);
  const [plans, setPlans] = useState<RedistributionPlan[]>([]);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [activeTab, setActiveTab] = useState<'intelligence' | 'market'>('intelligence');
  const [simulationMode, setSimulationMode] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<RedistributionPlan | null>(null);

  useEffect(() => {
    setData(generateMockData());
  }, []);

  const runAnalysis = () => {
    if (!data) return;
    setIsAnalyzing(true);
    
    setTimeout(() => {
      const consumptionRates: Record<string, number> = {
        'Insulin': simulationMode ? 40 : 13,
        'Paracetamol': 50,
        'Amoxicillin': 20,
        'Azithromycin': 15,
        'Metformin': 30,
        'Amlodipine': 25
      };
      
      const risks = MediFlowAI.predictExpiryRisk(data.inventory, consumptionRates);
      
      const demands: Record<string, Record<string, number>> = {};
      data.facilities.forEach(f => {
        if (f.type !== 'PHC') {
          demands[f.id] = {
            'Insulin': Math.floor(Math.random() * (simulationMode ? 500 : 200)),
            'Paracetamol': Math.floor(Math.random() * 500)
          };
        }
      });
      
      const newPlans = MediFlowAI.generateRedistribution(risks, data.facilities, demands);
      setPlans(newPlans);
      setIsAnalyzing(false);
    }, 1200);
  };

  if (!data) return <div style={{ background: 'var(--background)', color: 'white', height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>Initializing MediFlow Intelligence Core...</div>;

  const riskCount = data.inventory.filter(i => {
    const d = new Date(i.expiryDate);
    return d < new Date(Date.now() + 30 * 24 * 3600 * 1000);
  }).length;

  return (
    <main style={{ padding: '2rem', maxWidth: '1400px', margin: '0 auto' }}>
      <ExplainSidebar 
        isOpen={!!selectedPlan} 
        onClose={() => setSelectedPlan(null)} 
        plan={selectedPlan} 
      />

      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '3rem' }}>
        <div>
          <h1 className="gradient-text" style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>MediFlow 2.0</h1>
          <p style={{ color: 'var(--text-muted)' }}>Autonomous Healthcare Supply Intelligence Network</p>
        </div>
        <div style={{ display: 'flex', gap: '1rem' }}>
          <div className="glass" style={{ display: 'flex', padding: '0.4rem', borderRadius: '12px' }}>
             <button 
               onClick={() => setActiveTab('intelligence')}
               className={`btn ${activeTab === 'intelligence' ? 'btn-primary' : ''}`} 
               style={{ background: activeTab === 'intelligence' ? '' : 'transparent', fontSize: '0.9rem' }}
             >Intelligence</button>
             <button 
               onClick={() => setActiveTab('market')}
               className={`btn ${activeTab === 'market' ? 'btn-primary' : ''}`} 
               style={{ background: activeTab === 'market' ? '' : 'transparent', fontSize: '0.9rem' }}
             >Stock Market</button>
          </div>
          <button className="btn btn-primary" onClick={runAnalysis} disabled={isAnalyzing}>
            {isAnalyzing ? 'Analyzing Network...' : 'Run AI Analysis'}
          </button>
        </div>
      </header>

      {/* Top Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1.5rem', marginBottom: '3rem' }}>
        <div className="card">
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Network Nodes</p>
          <h3 style={{ fontSize: '2rem', marginTop: '0.5rem' }}>{data.facilities.length}</h3>
          <p style={{ color: 'var(--secondary)', fontSize: '0.8rem', marginTop: '0.5rem' }}>↑ 12 active today</p>
        </div>
        <div className="card">
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Expiry Risks</p>
          <h3 style={{ fontSize: '2rem', marginTop: '0.5rem', color: 'var(--error)' }}>{riskCount}</h3>
          <p style={{ color: 'var(--error)', fontSize: '0.8rem', marginTop: '0.5rem' }}>Next 30 days</p>
        </div>
        <div className="card" style={{ border: simulationMode ? '1px solid var(--accent)' : '1px solid var(--glass-border)' }}>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Optimization Gain</p>
          <h3 style={{ fontSize: '2rem', marginTop: '0.5rem' }}>{simulationMode ? '98.2%' : '84.5%'}</h3>
          <p style={{ color: 'var(--accent)', fontSize: '0.8rem', marginTop: '0.5rem' }}>Efficiency increase</p>
        </div>
        <div className="card" 
          style={{ cursor: 'pointer', border: simulationMode ? '2px solid var(--accent)' : '1px solid var(--glass-border)' }} 
          onClick={() => setSimulationMode(!simulationMode)}
        >
           <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
             <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Antigravity Mode</p>
             <div style={{ width: '10px', height: '10px', borderRadius: '50%', background: simulationMode ? 'var(--secondary)' : 'var(--error)' }}></div>
           </div>
           <h3 style={{ fontSize: '1.2rem', marginTop: '1rem', color: simulationMode ? 'var(--accent)' : 'inherit' }}>
             {simulationMode ? 'Scenario: Viral Outbreak' : 'Real-time Mode'}
           </h3>
           <p style={{ color: 'var(--text-muted)', fontSize: '0.75rem', marginTop: '0.5rem' }}>Simulation: Toggling demand spikes</p>
        </div>
      </div>

      {activeTab === 'intelligence' ? (
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '2rem' }}>
          <section className="card" style={{ minHeight: '400px' }}>
            <h2 style={{ marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              Regional Intelligence Map
              {simulationMode && <span className="glass" style={{ padding: '0.2rem 0.5rem', fontSize: '0.6rem', color: 'var(--accent)' }}>SIMULATING COLD-CHAIN BURST</span>}
            </h2>
            <div style={{ 
              width: '100%', 
              height: '400px', 
              background: 'rgba(0,0,0,0.3)', 
              borderRadius: '12px',
              position: 'relative',
              overflow: 'hidden',
              border: '1px solid var(--glass-border)'
            }}>
               {data.facilities.slice(0, 35).map((f) => (
                 <div key={f.id} style={{ 
                   position: 'absolute', 
                   left: `${(f.lon - 77.0) * 1000}%`, 
                   top: `${(f.lat - 28.4) * 1000}%`,
                   width: f.type === 'DH' ? '12px' : '8px',
                   height: f.type === 'DH' ? '12px' : '8px',
                   borderRadius: '50%',
                   background: f.type === 'DH' ? 'var(--primary)' : 'var(--secondary)',
                   boxShadow: `0 0 15px ${f.type === 'DH' ? 'var(--primary)' : 'var(--secondary)'}`,
                   transition: 'all 0.5s ease'
                 }} />
               ))}
               {plans.slice(0, 15).map((p, i) => {
                 const src = data.facilities.find(f => f.id === p.sourceId);
                 const dst = data.facilities.find(f => f.id === p.destinationId);
                 if (!src || !dst) return null;
                 return (
                   <div key={i} style={{ 
                     position: 'absolute',
                     left: `${(src.lon - 77.0) * 1000}%`,
                     top: `${(src.lat - 28.4) * 1000}%`,
                     width: '2px',
                     height: '100px',
                     background: 'linear-gradient(to bottom, var(--primary), transparent)',
                     transform: `rotate(${Math.atan2((dst.lat - src.lat), (dst.lon - src.lon)) * 180 / Math.PI}deg)`,
                     transformOrigin: 'top',
                     opacity: 0.3
                   }} />
                 );
               })}
            </div>
          </section>

          <section className="card" style={{ display: 'flex', flexDirection: 'column' }}>
            <h2 style={{ marginBottom: '1.5rem' }}>AI Recommendations</h2>
            <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '1rem', maxHeight: '420px', paddingRight: '0.5rem' }}>
              {plans.length === 0 ? (
                <div style={{ textAlign: 'center', marginTop: '4rem' }}>
                  <p style={{ color: 'var(--text-muted)' }}>Scan network nodes for optimization routes.</p>
                </div>
              ) : (
                plans.map((p, i) => (
                  <div key={i} className="glass" style={{ padding: '1rem', borderLeft: p.urgency === 'high' ? '4px solid var(--error)' : '4px solid var(--primary)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                      <span style={{ fontWeight: 'bold' }}>{p.itemName}</span>
                      <span style={{ color: 'var(--secondary)' }}>{p.quantity} Units</span>
                    </div>
                    <p style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginBottom: '0.8rem' }}>
                      {p.sourceId} ➔ {p.destinationId}
                    </p>
                    <div style={{ marginTop: '0.8rem', display: 'flex', gap: '0.5rem' }}>
                       <button className="btn btn-primary" style={{ padding: '0.3rem 0.6rem', fontSize: '0.7rem' }}>Approve</button>
                       <button 
                        onClick={() => setSelectedPlan(p)}
                        className="btn glass" 
                        style={{ padding: '0.3rem 0.6rem', fontSize: '0.7rem', color: 'white' }}
                       >Explain AI</button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </section>
        </div>
      ) : (
        <section className="card">
          <h2 style={{ marginBottom: '1.5rem' }}>B2B Medicine Exchange Marketplace</h2>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1.5rem' }}>
            {[1, 2, 3, 4, 5, 6].map(i => (
              <div key={i} className="glass" style={{ padding: '1.5rem' }}>
                 <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                   <span className="glass" style={{ padding: '0.2rem 0.5rem', fontSize: '0.6rem', background: i % 2 === 0 ? 'var(--secondary)' : 'var(--accent)' }}>
                     {i % 2 === 0 ? 'SURPLUS' : 'REQUESTED'}
                   </span>
                   <span style={{ fontSize: '0.7rem', color: 'var(--text-muted)' }}>Verified Facility</span>
                 </div>
                 <h4 style={{ fontSize: '1.1rem', marginBottom: '0.5rem' }}>Critical Medicine {i}</h4>
                 <p style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>Location: Hospital Hub {100 + i}</p>
                 <div style={{ marginTop: '1.5rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontWeight: 'bold' }}>{100 * i} Units</span>
                    <button className="btn btn-primary" style={{ padding: '0.4rem 1rem', fontSize: '0.85rem' }}>
                      {i % 2 === 0 ? 'Accept' : 'Fulfill'}
                    </button>
                 </div>
              </div>
            ))}
          </div>
        </section>
      )}
    </main>
  );
}
