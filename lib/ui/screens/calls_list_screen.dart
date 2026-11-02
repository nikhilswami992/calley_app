import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/call_list.dart';
import '../../providers/app_provider.dart';

/// Displays the individual call records returned by `GET /list/{listId}` so the
/// user can inspect Pending, Called, and Rescheduled contacts and dial them.
class CallsListScreen extends StatefulWidget {
  const CallsListScreen({super.key, this.initialFilter = 'all'});

  final String initialFilter;

  @override
  State<CallsListScreen> createState() => _CallsListScreenState();
}

class _CallsListScreenState extends State<CallsListScreen> {
  late String _filter = widget.initialFilter;

  Future<void> _dial(BuildContext context, CallRecord record) async {
    final uri = Uri(scheme: 'tel', path: record.phone);
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dialling ${record.fullName} (${record.phone})...'),
        ),
      );
    }
  }

  List<CallRecord> _filtered(List<CallRecord> all) {
    switch (_filter) {
      case 'pending':
        return all
            .where((c) => c.status.toLowerCase() == 'pending')
            .toList();
      case 'called':
        return all
            .where((c) => c.status.toLowerCase() == 'called')
            .toList();
      case 'rescheduled':
        return all
            .where((c) =>
                c.rescheduledAt != null && c.rescheduledAt!.isNotEmpty)
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final details = app.listDetails;
    final listName = app.selectedList?.name ?? 'Test List';
    final calls = _filtered(details?.calls ?? const []);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '$listName (${calls.length})',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${details?.totalCalls ?? 0})',
                  selected: _filter == 'all',
                  color: AppColors.primary,
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending (${details?.pending ?? 0})',
                  selected: _filter == 'pending',
                  color: AppColors.pending,
                  onTap: () => setState(() => _filter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Done (${details?.called ?? 0})',
                  selected: _filter == 'called',
                  color: AppColors.done,
                  onTap: () => setState(() => _filter = 'called'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Schedule (${details?.rescheduled ?? 0})',
                  selected: _filter == 'rescheduled',
                  color: AppColors.schedule,
                  onTap: () => setState(() => _filter = 'rescheduled'),
                ),
              ],
            ),
          ),
          Expanded(
            child: calls.isEmpty
                ? Center(
                    child: Text(
                      'No calls in this category.',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                    itemCount: calls.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = calls[index];
                      final isCalled = c.status.toLowerCase() == 'called';
                      final statusColor =
                          isCalled ? AppColors.done : AppColors.pending;
                      final statusBg =
                          isCalled ? AppColors.doneBg : AppColors.pendingBg;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${c.title} ${c.fullName}'.trim(),
                                          style: GoogleFonts.inter(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          c.status.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${c.phone}  •  ${c.company}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (c.feedback != null &&
                                      c.feedback!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Feedback: ${c.feedback}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _dial(context, c),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.lightBlue,
                              ),
                              icon: const Icon(
                                Icons.call_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
