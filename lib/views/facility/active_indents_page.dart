import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../models/request.dart';
import 'package:med_supply_prototype/constants/colors.dart';

class ActiveIndentsPage extends ConsumerStatefulWidget {
  final String facilityId;
  const ActiveIndentsPage({super.key, required this.facilityId});

  @override
  ConsumerState<ActiveIndentsPage> createState() => _ActiveIndentsPageState();
}

class _ActiveIndentsPageState extends ConsumerState<ActiveIndentsPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isActionInProgress = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _updateQuantity(String requestId, int quantity) async {
    setState(() => _isActionInProgress = true);
    try {
      // Note: FirebaseService doesn't have a generic update method for fields other than status.
      // I'll update the whole document or add a new method.
      // For now, I'll update the status to pending if requested, but if it's just quantity, 
      // I'll need a way to update that.
      await ref.read(firebaseServiceProvider).updateRequestQuantity(requestId, quantity);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _deleteDraft(String requestId) async {
    setState(() => _isActionInProgress = true);
    try {
      await ref.read(firebaseServiceProvider).deleteRequest(requestId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _finalSubmit(String requestId) async {
    setState(() => _isActionInProgress = true);
    try {
      await ref.read(firebaseServiceProvider).updateRequestStatus(requestId, RequestStatus.pending);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indent sent to CMS! ✓')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediColors.bg,
      appBar: AppBar(title: const Text('Active Indents (Drafts)')),
      body: StreamBuilder<List<MedRequest>>(
        stream: ref.read(firebaseServiceProvider).streamRequests(widget.facilityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: MediColors.error)));
          }

          final drafts = snapshot.data?.where((r) => r.status == RequestStatus.draft).toList() ?? [];

          if (drafts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: MediColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No active drafts.', style: TextStyle(color: MediColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Go to "Create Indent" to start a new request.', style: TextStyle(color: MediColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              if (!_controllers.containsKey(draft.id)) {
                _controllers[draft.id] = TextEditingController(text: draft.quantity.toString());
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Medicine Info
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(draft.medicineName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MediColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text('Created: ${draft.requestDate.day}/${draft.requestDate.month}/${draft.requestDate.year}', style: const TextStyle(fontSize: 12, color: MediColors.textMuted)),
                            if (draft.notes != null) ...[
                              const SizedBox(height: 8),
                              Text(draft.notes!, style: const TextStyle(fontSize: 12, color: MediColors.info, fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      ),

                      // Quantity Editor
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            const Text('Qty: ', style: TextStyle(color: MediColors.textSecondary)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              height: 40,
                              child: TextField(
                                controller: _controllers[draft.id],
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onSubmitted: (val) {
                                  final qty = int.tryParse(val) ?? draft.quantity;
                                  _updateQuantity(draft.id, qty);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: MediColors.error),
                            onPressed: _isActionInProgress ? null : () => _deleteDraft(draft.id),
                            tooltip: 'Remove Draft',
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _isActionInProgress ? null : () => _finalSubmit(draft.id),
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Submit to CMS'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
