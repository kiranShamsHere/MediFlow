import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../models/request.dart';
import 'package:med_supply_prototype/constants/colors.dart';

class AdminIndentStatusPage extends ConsumerStatefulWidget {
  const AdminIndentStatusPage({super.key});

  @override
  ConsumerState<AdminIndentStatusPage> createState() => _AdminIndentStatusPageState();
}

class _AdminIndentStatusPageState extends ConsumerState<AdminIndentStatusPage> {
  bool _isActionInProgress = false;

  Future<void> _updateStatus(String requestId, RequestStatus status) async {
    setState(() => _isActionInProgress = true);
    try {
      await ref.read(firebaseServiceProvider).updateRequestStatus(requestId, status);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.approved: return MediColors.success;
      case RequestStatus.rejected: return MediColors.error;
      case RequestStatus.pending: return MediColors.warning;
      case RequestStatus.fulfilled: return MediColors.info;
      case RequestStatus.draft: return MediColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediColors.bg,
      appBar: AppBar(title: const Text('Indent Status History')),
      body: StreamBuilder<List<MedRequest>>(
        stream: ref.read(firebaseServiceProvider).streamRequests(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final requests = snapshot.data?.where((r) => r.status != RequestStatus.draft).toList() ?? [];
          requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));

          if (requests.isEmpty) {
            return const Center(child: Text('No requests found.', style: TextStyle(color: MediColors.textMuted)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Column(
                children: [
                  _buildTableHeader(),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: requests.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return _buildTableRow(req);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: MediColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Date', style: TextStyle(color: MediColors.textSecondary, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Facility', style: TextStyle(color: MediColors.textSecondary, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Medicine', style: TextStyle(color: MediColors.textSecondary, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Quantity', style: TextStyle(color: MediColors.textSecondary, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Status', style: TextStyle(color: MediColors.textSecondary, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Action', style: TextStyle(color: MediColors.textSecondary, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(MedRequest req) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('${req.requestDate.day}/${req.requestDate.month}', style: const TextStyle(color: MediColors.textSecondary))),
          Expanded(flex: 3, child: Text(req.facilityId.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, color: MediColors.textPrimary, fontSize: 13))),
          Expanded(flex: 3, child: Text(req.medicineName, style: const TextStyle(color: MediColors.textPrimary))),
          Expanded(flex: 2, child: Text(req.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(req.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(req.status.name.toUpperCase(), style: TextStyle(color: _getStatusColor(req.status), fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 2,
            child: PopupMenuButton<RequestStatus>(
              icon: const Icon(Icons.edit_note_rounded, color: MediColors.primaryLight),
              onSelected: (status) => _updateStatus(req.id, status),
              itemBuilder: (context) => RequestStatus.values.where((s) => s != RequestStatus.draft).map((status) {
                return PopupMenuItem(
                  value: status,
                  child: Text(status.name.toUpperCase()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
