import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import 'package:med_supply_prototype/constants/colors.dart';

class SidebarLayout extends StatefulWidget {
  final Widget child;
  final String role;
  final String? facilityId;

  const SidebarLayout({
    super.key,
    required this.child,
    required this.role,
    this.facilityId,
  });

  @override
  State<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  bool _isExpanded = false;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (widget.role == 'facility') {
      if (location.endsWith('/overview')) return 0;
      if (location.endsWith('/forecast')) return 1;
      if (location.endsWith('/indent')) return 2;
      if (location.endsWith('/active-indents')) return 3;
      if (location.endsWith('/logging')) return 4;
      if (location.endsWith('/alerts')) return 5;
      if (location.endsWith('/chat')) return 6;
      if (location.endsWith('/help')) return 7;
      return 0;
    } else {
      if (location.endsWith('/overview')) return 0;
      if (location.endsWith('/approvals')) return 1;
      if (location.endsWith('/indent-status')) return 2;
      if (location.endsWith('/routing')) return 3;
      if (location.endsWith('/chat')) return 4;
      if (location.endsWith('/help')) return 5;
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    if (widget.role == 'facility' && widget.facilityId != null) {
      switch (index) {
        case 0: context.go('/facility/${widget.facilityId}/overview'); break;
        case 1: context.go('/facility/${widget.facilityId}/forecast'); break;
        case 2: context.go('/facility/${widget.facilityId}/indent'); break;
        case 3: context.go('/facility/${widget.facilityId}/active-indents'); break;
        case 4: context.go('/facility/${widget.facilityId}/logging'); break;
        case 5: context.go('/facility/${widget.facilityId}/alerts'); break;
        case 6: context.go('/facility/${widget.facilityId}/chat'); break;
        case 7: context.go('/facility/${widget.facilityId}/help'); break;
      }
    } else if (widget.role == 'admin') {
      switch (index) {
        case 0: context.go('/admin/overview'); break;
        case 1: context.go('/admin/approvals'); break;
        case 2: context.go('/admin/indent-status'); break;
        case 3: context.go('/admin/routing'); break;
        case 4: context.go('/admin/chat'); break;
        case 5: context.go('/admin/help'); break;
      }
    }
  }

  List<_NavItem> get _navItems => widget.role == 'facility'
      ? [
          _NavItem(Icons.grid_view_rounded, 'Overview'),
          _NavItem(Icons.auto_graph_rounded, 'Forecast'),
          _NavItem(Icons.receipt_long_rounded, 'Create Indent'),
          _NavItem(Icons.inventory_2_rounded, 'Active Indents'),
          _NavItem(Icons.edit_calendar_rounded, 'Daily Log'),
          _NavItem(Icons.notifications_active_rounded, 'Alerts'),
          _NavItem(Icons.smart_toy_rounded, 'AI Chat'),
          _NavItem(Icons.help_outline_rounded, 'Help'),
        ]
      : [
          _NavItem(Icons.dashboard_rounded, 'Overview'),
          _NavItem(Icons.rule_rounded, 'Approvals'),
          _NavItem(Icons.history_rounded, 'Indent Status'),
          _NavItem(Icons.map_rounded, 'Route Opt.'),
          _NavItem(Icons.smart_toy_rounded, 'AI Chat'),
          _NavItem(Icons.help_outline_rounded, 'Help'),
        ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final items = _navItems;

    return Scaffold(
      backgroundColor: MediColors.bg,
      body: Row(
        children: [
          // ── Sidebar ──
          MouseRegion(
            onEnter: (_) => setState(() => _isExpanded = true),
            onExit: (_) => setState(() => _isExpanded = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: _isExpanded ? 220 : 72,
              decoration: BoxDecoration(
                color: MediColors.surface,
                border: Border(right: BorderSide(color: MediColors.border, width: 1)),
              ),
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: MediColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
                    ),
                  ),

                  // Nav Items
                  ...List.generate(items.length, (i) {
                    final isSelected = i == selectedIndex;
                    return _buildNavItem(items[i], isSelected, () => _onItemTapped(i, context));
                  }),

                  const Spacer(),

                  // Logout
                  _buildNavItem(
                    _NavItem(Icons.logout_rounded, 'Logout'),
                    false,
                    () async {
                      if (context.mounted) context.go('/');
                      await FirebaseAuth.instance.signOut();
                    },
                    isLogout: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Main Content ──
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isSelected, VoidCallback onTap, {bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: MediColors.surfaceHover,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? MediColors.primary.withValues(alpha: 0.12) : Colors.transparent,
              border: isSelected ? Border.all(color: MediColors.primary.withValues(alpha: 0.25)) : null,
            ),
            child: ClipRect(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    child: Center(
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: isLogout
                            ? MediColors.error
                            : isSelected
                                ? MediColors.primary
                                : MediColors.textMuted,
                      ),
                    ),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isLogout
                              ? MediColors.error
                              : isSelected
                                  ? MediColors.primary
                                  : MediColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem(this.icon, this.label);
}
