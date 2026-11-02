import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Blue profile greeting card shown at the top of Onboarding, Dashboard,
/// and Settings screens.
class UserGreetingCard extends StatelessWidget {
  const UserGreetingCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.extraLines = const [],
  });

  final String name;
  final String subtitle;
  final List<String> extraLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: extraLines.isEmpty
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
              image: const DecorationImage(
                image: AssetImage('assets/images/avatar.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello $name',
                  style: GoogleFonts.inter(
                    fontSize: extraLines.isEmpty ? 13 : 15,
                    fontWeight: extraLines.isEmpty
                        ? FontWeight.w500
                        : FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: extraLines.isEmpty ? 17 : 13,
                    fontWeight: extraLines.isEmpty
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                for (final line in extraLines) ...[
                  const SizedBox(height: 2),
                  Text(
                    line,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action row with the green-outlined WhatsApp button and the primary
/// "Start Calling Now" CTA (Screens 05 & 06).
class WhatsAppStartCallingBar extends StatelessWidget {
  const WhatsAppStartCallingBar({
    super.key,
    required this.onStartCalling,
  });

  final VoidCallback onStartCalling;

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse(AppLinks.whatsappSupport);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp support: +91 7676286822')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => _openWhatsApp(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.done, width: 1.4),
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.whatsapp,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onStartCalling,
              child: const Text('Start Calling Now'),
            ),
          ),
        ),
      ],
    );
  }
}
