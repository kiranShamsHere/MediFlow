import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/ai_service.dart';
import '../../models/inventory_item.dart';
import '../../main.dart';
import '../shared/ai_chat_page.dart';

class AlertsPage extends ConsumerStatefulWidget {
  final String facilityId;
  const AlertsPage({super.key, required this.facilityId});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> {
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final inventory = await ref.read(firebaseServiceProvider).getInventoryOnce(widget.facilityId);
      final alerts = await ref.read(aiServiceProvider).generateSmartAlerts(inventory);
      if (mounted) setState(() { _alerts = alerts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiryAlerts = _alerts.where((a) => a['type'] == 'expiry').toList();
    final lowStockAlerts = _alerts.where((a) => a['type'] == 'low_stock').toList();

    return Scaffold(
      backgroundColor: MediColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Alerts', style: TextStyle(fontWeight: FontWeight.w800, color: MediColors.textPrimary)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PHC Rampur',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade600, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: MediColors.textSecondary),
            onPressed: _loadAlerts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatPage(role: "Facility Manager")));
        },
        backgroundColor: const Color(0xFF1E3A8A), // Dark blue sparkles button
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expiryAlerts.isNotEmpty) ...[
                    const Text('Expiry Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: MediColors.textPrimary)),
                    const SizedBox(height: 16),
                    ...expiryAlerts.map((alert) => _buildExpiryAlertCard(alert)),
                    const SizedBox(height: 32),
                  ],
                  if (lowStockAlerts.isNotEmpty) ...[
                    const Text('Low Stock Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: MediColors.textPrimary)),
                    const SizedBox(height: 16),
                    ...lowStockAlerts.map((alert) => _buildLowStockAlertCard(alert)),
                  ],
                  if (expiryAlerts.isEmpty && lowStockAlerts.isEmpty)
                    const Center(child: Text("No active alerts detected.", style: TextStyle(color: MediColors.textSecondary))),
                ],
              ),
            ),
    );
  }

  Widget _buildExpiryAlertCard(Map<String, dynamic> alert) {
    final severity = alert['severity'] ?? 'yellow';
    final isRed = severity == 'red';
    final accentColor = isRed ? MediColors.error : MediColors.warning;
    final icon = isRed ? Icons.warning_rounded : Icons.info_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MediColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(alert['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: MediColors.textPrimary)),
                    const SizedBox(width: 8),
                    Text(alert['batchId'] ?? '', style: const TextStyle(fontSize: 12, color: MediColors.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Expires in ${alert['expiresInDays']} days · ${alert['remainingQuantity']} units remaining', style: const TextStyle(color: MediColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildActionButton('Request Redistribution', accentColor),
                    _buildActionButton('Mark for Disposal', accentColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlertCard(Map<String, dynamic> alert) {
    final accentColor = MediColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MediColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.trending_down_rounded, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(alert['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: MediColors.textPrimary)),
                    const SizedBox(width: 8),
                    Text(alert['batchId'] ?? '', style: const TextStyle(fontSize: 12, color: MediColors.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${alert['remainingPercentage']}% remaining · Burn rate: ${alert['burnRate']} · Depletes in ~${alert['depletesInDays']} days', style: const TextStyle(color: MediColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildActionButton('Request Restock', accentColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.5)),
        color: accentColor.withValues(alpha: 0.05),
      ),
      child: Text(
        text,
        style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

