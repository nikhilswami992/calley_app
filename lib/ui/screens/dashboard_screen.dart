import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/call_list.dart';
import '../../providers/app_provider.dart';
import '../widgets/donut_chart.dart';
import '../widgets/user_greeting_card.dart';
import 'app_drawer.dart';
import 'calling_lists_sheet.dart';
import 'calls_list_screen.dart';
import 'settings_screen.dart';

/// Screens 06 & 08 — Dashboard (empty state "LOAD NUMBER TO CALL" and active
/// calling-list analytics view with donut chart & Pending/Done/Schedule cards).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _bottomIndex = 2; // Center play tab highlighted by default per Figma.

  Future<void> _openCallingLists() async {
    await showCallingListsSheet(context);
  }

  Future<void> _openWebPanel() async {
    final uri = Uri.parse(AppLinks.webPanel);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openCalls({String filter = 'all'}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallsListScreen(initialFilter: filter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.user;
    final firstName = user?.firstName ?? 'Swati';
    final selectedList = app.selectedList;
    final details = app.listDetails;
    final hasLoadedList = selectedList != null && details != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const CalleyAppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 24),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        titleSpacing: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Support',
            icon: const Icon(Icons.headset_mic_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calley Support: support@getcalley.com'),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings & Calling Lists',
            icon: const Icon(Icons.notifications_active_outlined, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(openCallingListsOnMount: true),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: hasLoadedList
          ? _ActiveListView(
              list: selectedList,
              details: details,
              userInitial:
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
              onTapListCard: _openCallingLists,
              onTapFilter: (f) => _openCalls(filter: f),
              onStartCalling: () => _openCalls(filter: 'all'),
            )
          : _EmptyDashboardView(
              firstName: firstName,
              onTapWebLink: _openWebPanel,
              onStartCalling: _openCallingLists,
            ),
      bottomNavigationBar: hasLoadedList
          ? null
          : _CalleyBottomNavBar(
              currentIndex: _bottomIndex,
              onTap: (index) {
                setState(() => _bottomIndex = index);
                if (index == 2) {
                  _openCallingLists();
                } else if (index == 0 && hasLoadedList) {
                  app.clearSelectedList();
                }
              },
            ),
    );
  }
}

/// Screen 06 — Empty dashboard before a calling list is loaded.
class _EmptyDashboardView extends StatelessWidget {
  const _EmptyDashboardView({
    required this.firstName,
    required this.onTapWebLink,
    required this.onStartCalling,
  });

  final String firstName;
  final VoidCallback onTapWebLink;
  final VoidCallback onStartCalling;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      child: Column(
        children: [
          UserGreetingCard(
            name: firstName,
            subtitle: 'Welcome to Calley!',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: AppColors.navy,
                    child: Text(
                      'LOAD NUMBER TO CALL',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Visit '),
                          TextSpan(
                            text: 'https://app.getcalley.com',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = onTapWebLink,
                          ),
                          const TextSpan(
                            text:
                                ' to upload numbers that you wish to call using Calley Mobile App.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Image.asset(
                        'assets/images/dashboard_illustration.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          WhatsAppStartCallingBar(onStartCalling: onStartCalling),
        ],
      ),
    );
  }
}

/// Screen 08 — Active calling list analytics with donut chart & status cards.
class _ActiveListView extends StatelessWidget {
  const _ActiveListView({
    required this.list,
    required this.details,
    required this.userInitial,
    required this.onTapListCard,
    required this.onTapFilter,
    required this.onStartCalling,
  });

  final CallList list;
  final CallListDetails details;
  final String userInitial;
  final VoidCallback onTapListCard;
  final ValueChanged<String> onTapFilter;
  final VoidCallback onStartCalling;

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          children: [
            // Top "Test List / 50 CALLS" summary card.
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTapListCard,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${details.totalCalls}',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'CALLS',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          userInitial,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: CallsDonutChart(
                  pending: details.pending,
                  done: details.called,
                  scheduled: details.rescheduled,
                  size: 205,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _StatusStatCard(
                    title: 'Pending',
                    count: _twoDigits(details.pending),
                    accentColor: AppColors.pending,
                    backgroundColor: AppColors.pendingBg,
                    onTap: () => onTapFilter('pending'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusStatCard(
                    title: 'Done',
                    count: _twoDigits(details.called),
                    accentColor: AppColors.done,
                    backgroundColor: AppColors.doneBg,
                    onTap: () => onTapFilter('called'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusStatCard(
                    title: 'Schedule',
                    count: _twoDigits(details.rescheduled),
                    accentColor: AppColors.schedule,
                    backgroundColor: AppColors.scheduleBg,
                    onTap: () => onTapFilter('rescheduled'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onStartCalling,
                child: const Text('Start Calling Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStatCard extends StatelessWidget {
  const _StatusStatCard({
    required this.title,
    required this.count,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String count;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          count,
                          style: GoogleFonts.inter(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Calls',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom 5-icon bottom bar matching Figma Screens 06 & 09.
class _CalleyBottomNavBar extends StatelessWidget {
  const _CalleyBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <IconData>[
      Icons.home_outlined,
      Icons.badge_outlined,
      Icons.play_arrow_outlined,
      Icons.phone_callback_outlined,
      Icons.calendar_today_outlined,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEEF4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Color(0xFF93B4F8), width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isCenterPlay = i == 2;
              if (isCenterPlay) {
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      items[i],
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                );
              }
              return IconButton(
                onPressed: () => onTap(i),
                icon: Icon(
                  items[i],
                  size: 22,
                  color: currentIndex == i
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
