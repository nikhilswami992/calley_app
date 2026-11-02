import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Top brand header used on Register, OTP Verification, and Sign In screens.
class CalleyLogoHeader extends StatelessWidget {
  const CalleyLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/logo_mark.jpg',
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CALLEY',
              style: GoogleFonts.inter(
                fontSize: 23,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                height: 1.05,
                color: const Color(0xFF3898EC),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'AUTOMATIC CALL DIALER',
              style: GoogleFonts.inter(
                fontSize: 9.2,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shared scaffold for screens 02, 03, and 04: logo header on a soft grey
/// background with a rounded white card holding the form and bottom CTA.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.body,
    required this.bottom,
  });

  final Widget body;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CalleyLogoHeader()),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 52,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: body),
                                const SizedBox(height: 20),
                                bottom,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
