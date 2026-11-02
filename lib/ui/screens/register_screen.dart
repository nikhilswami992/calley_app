import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../widgets/auth_shell.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

/// Screen 02 — "Welcome! Please register to continue".
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _countryCodeCtrl = TextEditingController(text: '+91');
  final _mobileCtrl = TextEditingController();

  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _countryCodeCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions.'),
        ),
      );
      return;
    }

    final app = context.read<AppProvider>();
    final ok = await app.registerAndSendOtp(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      countryCode: _countryCodeCtrl.text,
      mobile: _mobileCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      final offlineNote = app.usingOfflineFallback
          ? ' (Offline mock active — enter any 6-digit OTP, e.g. 229166)'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${_emailCtrl.text.trim()}$offlineNote'),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OtpVerificationScreen()),
      );
    } else if (app.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<AppProvider>().isBusy;

    return AuthShell(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Welcome!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please register to continue',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Name',
                suffixIcon: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Email address',
                suffixIcon: Icon(
                  Icons.mail_outline,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your email';
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.lock_outline
                        : Icons.lock_open_outlined,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Enter a password'
                  : null,
            ),
            const SizedBox(height: 14),
            // Country code + WhatsApp icon field matching Figma Screen 02.
            TextFormField(
              controller: _countryCodeCtrl,
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: _IndianFlagCircle(),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: const Icon(
                  Icons.phone_in_talk_outlined,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Mobile number',
                suffixIcon: Icon(
                  Icons.stay_current_portrait_outlined,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
              validator: (v) => (v == null || v.trim().length < 7)
                  ? 'Enter a valid mobile number'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: AppColors.border, width: 1.4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _agreedToTerms = !_agreedToTerms),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        children: const [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
                children: const [
                  TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Sign In',
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
              onPressed: isBusy ? null : _submit,
              child: isBusy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndianFlagCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFFF9933))),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF000080),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Container(color: const Color(0xFF138808))),
        ],
      ),
    );
  }
}
