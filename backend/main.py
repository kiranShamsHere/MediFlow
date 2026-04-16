from flask import Flask, request, jsonify
import json
import random

app = Flask(__name__)

@app.route('/predict_redistribution', methods=['POST'])
def predict_redistribution():
    """
    Simulates Gemini 1.5 Pro redistribution intelligence.
    Input: facilities, stock, consumption, urgency_score
    Task: predict waste and generate transfer plan
    """
    data = request.json
    facilities = data.get('facilities', [])
    stock = data.get('stock', [])
    
    # Simulate AI Reasoning
    transfers = []
    reasoning = [
        "Identified high-risk expiry in sector 4 (Primary Health Centers).",
        "Correlated viral fever trends with low paracetamol stock in urban clusters.",
        "Optimized route based on cold-chain availability."
    ]
    
    # Mock some transfers
    if len(facilities) > 1 and len(stock) > 0:
        for _ in range(3):
            s = random.choice(facilities)
            d = random.choice(facilities)
            if s != d:
                transfers.append({
                    "source_facility": s['name'],
                    "destination_facility": d['name'],
                    "item": random.choice(['Insulin', 'Vaccine B']),
                    "quantity": random.randint(10, 100),
                    "latest_transfer_date": "2024-05-20"
                })

    return jsonify({
        "transfers": transfers,
        "reasoning": reasoning,
        "risk_scores": [
            {"facility": f['name'], "score": random.uniform(0.1, 0.9)} for f in facilities[:5]
        ]
    })

@app.route('/vision_log', methods=['POST'])
def vision_log():
    """
    Simulates Gemini Vision processing of medicine strips.
    """
    return jsonify({
        "name": "Amoxicillin 500mg",
        "expiry": "2025-12-30",
        "batch_no": "AX-9912",
        "confidence": 0.98,
        "structured_data": True
    })

if __name__ == '__main__':
    app.run(port=5000, debug=True)
