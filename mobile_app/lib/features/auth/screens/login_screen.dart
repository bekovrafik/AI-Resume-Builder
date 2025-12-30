import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/auth/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // Toggle state
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await ref.read(authServiceProvider).signInWithEmailPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      } else {
        await ref.read(authServiceProvider).signUpWithEmailPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      }
      if (mounted) GoRouter.of(context).go('/');
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glass Card
                GlassContainer(
                  padding: const EdgeInsets.all(40),
                  borderRadius: BorderRadius.circular(40),
                  child: Column(
                    children: [
                      // Logo / Icon
                      const Icon(Icons.verified_user_outlined,
                          size: 60, color: Colors.white),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        "AI RESUME BUILDER",
                        style: AppTypography.header1.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "LEAD AI CAREER ARCHITECT",
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white54,
                          letterSpacing: 4.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodySmall
                                .copyWith(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text("INSTITUTIONAL EMAIL",
                                style: AppTypography.labelSmall
                                    .copyWith(color: Colors.white54)),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: TextField(
                              controller: _emailController,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                                hintText: "name@executive.com",
                                hintStyle: TextStyle(color: Colors.white24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text("CREDENTIALS",
                                style: AppTypography.labelSmall
                                    .copyWith(color: Colors.white54)),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                                hintText: "••••••••",
                                hintStyle: TextStyle(color: Colors.white24),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Main Action Button
                      if (_isLoading)
                        const CircularProgressIndicator(
                            color: AppColors.strategicGold)
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 10,
                              shadowColor: Colors.black26,
                            ),
                            child: Text(
                              _isLogin
                                  ? "AUTHENTICATE ACCESS"
                                  : "CREATE BLUEPRINT",
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.black),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Toggle Button
                      TextButton(
                        onPressed: () => setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        }),
                        child: Text(
                          _isLogin
                              ? "DON'T HAVE AN ACCOUNT? SIGN UP"
                              : "ALREADY REGISTERED? LOG IN",
                          style: AppTypography.labelSmall
                              .copyWith(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Footer
                Text(
                  "MILAN • PARIS • NYC • TOKYO",
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white12,
                    letterSpacing: 6.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
