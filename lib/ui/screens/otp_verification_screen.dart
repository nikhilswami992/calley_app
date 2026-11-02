import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../widgets/auth_shell.dart';
import 'onboarding_screen.dart';

/// Screen 03 — "Whatsapp OTP Verification".
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  late final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text.trim()).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle pasted 6-digit OTP.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      FocusScope.of(context).unfocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (_otp.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP code.')),
      );
      return;
    }

    final app = context.read<AppProvider>();
    final ok = await app.verifyOtp(_otp);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (_) => false,
      );
    } else if (app.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.errorMessage!)),
      );
    }
  }

  Future<void> _resend() async {
    final app = context.read<AppProvider>();
    final ok = await app.resendOtp();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'A new OTP has been sent to your email.'
              : (app.errorMessage ?? 'Could not resend OTP.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final pending = app.pendingRegistration;
    final phoneDisplay = pending != null
        ? '${pending.countryCode} ${pending.mobile}?'
        : '+91 ${app.mobile}?';

    return AuthShell(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (app.lastOtp != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _onDigitChanged(0, app.lastOtp!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mark_email_read_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Your OTP code is ${app.lastOtp} (Tap to auto-fill)',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            'Whatsapp OTP\nVerification',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Please ensure that the email id mentioned is valid\nas we have sent an OTP to your email.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (index) {
              return SizedBox(
                width: 46,
                height: 48,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (v) => _onDigitChanged(index, v),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            phoneDisplay,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: app.isBusy ? null : _resend,
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
                children: const [
                  TextSpan(text: "Didn't receive OTP code? "),
                  TextSpan(
                    text: 'Resend OTP',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: app.isBusy ? null : _verify,
              child: app.isBusy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Verify'),
            ),
          ),
        ],
      ),
    );
  }
}
