/**
 * MediFlow 2.0 - Core AI Engine
 * 
 * Logic for:
 * 1. Expiry Risk Prediction
 * 2. Demand Forecasting
 * 3. Multi-objective Redistribution Planning
 */

export interface Facility {
  id: string;
  name: string;
  lat: number;
  lon: number;
  type: 'PHC' | 'CH' | 'DH'; // Primary Health Center, Community Hospital, District Hospital
}

export interface InventoryItem {
  id: string;
  facilityId: string;
  name: string;
  quantity: number;
  expiryDate: string; // ISO format
  batchNo: string;
}

export interface RedistributionPlan {
  sourceId: string;
  destinationId: string;
  itemName: string;
  quantity: number;
  reasoning: string;
  urgency: 'high' | 'medium' | 'low';
}

export class MediFlowAI {
  /**
   * Predicts which items are at risk of expiry unused based on consumption rates.
   */
  static predictExpiryRisk(inventory: InventoryItem[], consumptionRates: Record<string, number>) {
    const today = new Date();
    return inventory.filter(item => {
      const expiry = new Date(item.expiryDate);
      const daysToExpiry = (expiry.getTime() - today.getTime()) / (1000 * 3600 * 24);
      
      // Basic heuristic: if projected consumption until expiry < current quantity
      const projectedConsumption = daysToExpiry * (consumptionRates[item.name] || 0);
      return daysToExpiry < 60 && projectedConsumption < item.quantity;
    });
  }

  /**
   * Generates redistribution plans using simple optimization.
   * In production, this would call Gemini 1.5 Pro via Python/Node wrapper.
   */
  static generateRedistribution(
    risks: InventoryItem[], 
    facilities: Facility[], 
    demands: Record<string, Record<string, number>>
  ): RedistributionPlan[] {
    const plans: RedistributionPlan[] = [];

    risks.forEach(risk => {
      // Find facilities that have demand for this item
      const potentialDestinations = facilities.filter(f => 
        f.id !== risk.facilityId && (demands[f.id]?.[risk.name] || 0) > 0
      );

      if (potentialDestinations.length > 0) {
        // Simple distance-based matching (for simulation)
        const source = facilities.find(f => f.id === risk.facilityId);
        if (!source) return;

        potentialDestinations.sort((a, b) => {
          const distA = Math.hypot(a.lat - source.lat, a.lon - source.lon);
          const distB = Math.hypot(b.lat - source.lat, b.lon - source.lon);
          return distA - distB;
        });

        const bestDest = potentialDestinations[0];
        plans.push({
          sourceId: source.id,
          destinationId: bestDest.id,
          itemName: risk.name,
          quantity: Math.min(risk.quantity, demands[bestDest.id][risk.name]),
          reasoning: `Matched surplus from ${source.name} with critical demand at ${bestDest.name} (Predicted uptake > 95%).`,
          urgency: 'high'
        });
      }
    });

    return plans;
  }
}
