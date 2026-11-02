import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';

/// Screen 09 — Side Navigation Drawer.
class CalleyAppDrawer extends StatelessWidget {
  const CalleyAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.user;
    final firstName = user?.firstName ?? 'Swati';
    final email = user?.email ?? 'swati@cstech.in';

    void infoToast(String label) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label)),
      );
    }

    return Drawer(
      width: 300,
      backgroundColor: const Color(0xFFEEF4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blue header card at top of drawer.
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.5),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/avatar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                firstName,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.pending,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Personal',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.pending,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                children: [
                  _DrawerTile(
                    icon: Icons.rocket_launch_outlined,
                    label: 'Getting Started',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.cloud_sync_outlined,
                    label: 'Sync Data',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await app.fetchLists();
                      if (app.selectedList != null) {
                        await app.selectCallList(app.selectedList!);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling data synced.')),
                        );
                      }
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.grid_view_rounded,
                    label: 'Gamification',
                    onTap: () => infoToast('Gamification leaderboard coming soon.'),
                  ),
                  _DrawerTile(
                    icon: Icons.phone_forwarded_outlined,
                    label: 'Send Logs',
                    onTap: () => infoToast('Diagnostic logs sent to Calley support.'),
                  ),
                  _DrawerTile(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.headset_mic_outlined,
                    label: 'Help?',
                    onTap: () => infoToast('Support available at support@getcalley.com'),
                  ),
                  _DrawerTile(
                    icon: Icons.person_off_outlined,
                    label: 'Cancel Subscription',
                    onTap: () => infoToast('Subscription management on app.getcalley.com'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFD6E0F5), height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 8),
                    child: Text(
                      'App Info',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.contact_page_outlined,
                    label: 'About Us',
                    onTap: () => infoToast('Calley Automatic Call Dialer by C S Tech.'),
                  ),
                  _DrawerTile(
                    icon: Icons.policy_outlined,
                    label: 'Privacy Policy',
                    onTap: () => infoToast('Privacy Policy at getcalley.com/privacy'),
                  ),
                  _DrawerTile(
                    icon: Icons.verified_outlined,
                    label: 'Version 1.01.52',
                    onTap: () => infoToast('Calley App Version 1.01.52 (up to date)'),
                  ),
                  _DrawerTile(
                    icon: Icons.share_outlined,
                    label: 'Share App',
                    onTap: () => infoToast('Share link copied: https://app.getcalley.com'),
                  ),
                  _DrawerTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await app.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, size: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
