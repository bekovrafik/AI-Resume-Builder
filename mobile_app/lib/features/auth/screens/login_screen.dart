import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/auth/services/auth_service.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';

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

  Future<void> _handleGuestLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInAnonymously();
      if (mounted) GoRouter.of(context).go('/');
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) {
        GoRouter.of(context).go('/');
      } else {
        // User canceled, stop loading
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = "Please enter your email first.");
      return;
    }
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: "Password reset email sent!",
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glass Card
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_outlined,
                              size: 50, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            "AI RESUME\nBUILDER",
                            style: AppTypography.header2.copyWith(
                              color: Colors.white,
                              letterSpacing: 2.0,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create your professional resume with AI",
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white54,
                              letterSpacing: 0.5,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          // Error Message
                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodySmall
                                    .copyWith(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Fields
                          _buildTextField(
                            controller: _emailController,
                            label: "Email",
                            hint: "name@example.com",
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: "Password",
                            hint: "••••••••",
                            obscureText: true,
                          ),
                          // Forgot Password
                          if (_isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  minimumSize: const Size(0, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  "Forgot Password?",
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Login/Register Button
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  _isLogin ? "Login" : "Register",
                                  style: AppTypography.labelLarge.copyWith(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () => setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                            }),
                            child: Text(
                              _isLogin
                                  ? "Don't have an account? Sign up"
                                  : "Already registered? Log in",
                              style: AppTypography.labelSmall
                                  .copyWith(color: Colors.white54),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12, height: 32),

                          // Modern Buttons for Guest/Google
                          _buildOutlineButton(
                            icon: Icons.person_outline,
                            label: "Continue as Guest",
                            onPressed: _handleGuestLogin,
                          ),
                          const SizedBox(height: 12),
                          _buildOutlineButton(
                            icon: Icons.g_mobiledata,
                            label: "Sign in with Google",
                            onPressed: _handleGoogleLogin,
                            iconSize: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall.copyWith(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double iconSize = 18,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white70, size: iconSize),
        label: Text(
          label,
          style: AppTypography.labelSmall
              .copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white.withOpacity(0.08),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }
}
