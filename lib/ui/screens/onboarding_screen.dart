import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../widgets/user_greeting_card.dart';
import 'dashboard_screen.dart';

/// Screen 05 — First-time onboarding screen with the "2 MINUTE CHALLENGE"
/// video card and "Start Calling Now" CTA.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.parse(AppLinks.introVideo);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening Calley 2 Minute Challenge tutorial...'),
        ),
      );
    }
  }

  Future<void> _continueToDashboard(BuildContext context) async {
    await context.read<AppProvider>().markIntroSeen();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final firstName = user?.firstName ?? 'Swati';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            children: [
              UserGreetingCard(
                name: firstName,
                subtitle: 'Calley Personal',
              ),
              const SizedBox(height: 16),
              // Dark navy instructions banner + 2 Minute Challenge video card.
              Container(
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Text(
                        'If you are here for the first time then ensure that '
                        'you have uploaded the list to call from calley Web '
                        'Panel hosted on https://app.getcalley.com',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openVideo(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Image.asset(
                            'assets/images/video_thumbnail.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              WhatsAppStartCallingBar(
                onStartCalling: () => _continueToDashboard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
