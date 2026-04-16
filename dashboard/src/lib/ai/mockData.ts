import { Facility, InventoryItem } from './engine';

export const generateMockData = () => {
  const facilities: Facility[] = [
    { id: 'f1', name: 'District Hospital City', lat: 28.6139, lon: 77.2090, type: 'DH' },
    { id: 'f2', name: 'PHC Rural North', lat: 28.7041, lon: 77.1025, type: 'PHC' },
    { id: 'f3', name: 'Community Hospital East', lat: 28.6500, lon: 77.3000, type: 'CH' },
    { id: 'f4', name: 'PHC West Village', lat: 28.6000, lon: 77.1000, type: 'PHC' },
    { id: 'f5', name: 'Industrial Health Hub', lat: 28.5000, lon: 77.2000, type: 'CH' },
  ];

  // Generate 50 more facilities randomly
  for (let i = 6; i <= 55; i++) {
    facilities.push({
      id: `f${i}`,
      name: `Facility ${i} (PHC)`,
      lat: 28.4 + Math.random() * 0.4,
      lon: 77.0 + Math.random() * 0.4,
      type: 'PHC'
    });
  }

  const drugs = ['Insulin', 'Paracetamol', 'Amoxicillin', 'Azithromycin', 'Metformin', 'Amlodipine'];
  const inventory: InventoryItem[] = [];

  facilities.forEach(f => {
    drugs.forEach(drug => {
      // 30% chance of having a stock
      if (Math.random() > 0.3) {
        const qty = Math.floor(Math.random() * 500);
        const expiryOffset = Math.floor(Math.random() * 120) - 30; // some already expired, some soon
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + expiryOffset);

        inventory.push({
          id: `i-${f.id}-${drug}`,
          facilityId: f.id,
          name: drug,
          quantity: qty,
          expiryDate: expiryDate.toISOString(),
          batchNo: `BATCH-${Math.floor(Math.random() * 10000)}`
        });
      }
    });
  });

  return { facilities, inventory };
};
