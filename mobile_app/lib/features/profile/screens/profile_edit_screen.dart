import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Added
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';
import 'package:mobile_app/core/services/gemini_service.dart';
import 'package:mobile_app/features/auth/services/auth_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _linkedInController = TextEditingController();

  bool _initialized = false;
  String? _pickedImagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _linkedInController.dispose();
    super.dispose();
  }

  void _initData(ResumeData data) {
    if (_initialized) return;
    _nameController.text = data.fullName ?? '';
    _roleController.text = data.targetRole ?? '';
    _emailController.text = data.email ?? '';
    _linkedInController.text = data.linkedIn ?? '';
    _pickedImagePath = data.avatarUrl;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.midnightNavy;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profile',
            style:
                AppTypography.header3.copyWith(color: textColor, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.strategicGold),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.strategicGold),
            onPressed: () => _saveProfile(profileAsync.value),
          )
        ],
      ),
      body: GradientBackground(
        child: profileAsync.when(
          data: (data) {
            _initData(data);
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.white10
                                      : AppColors.midnightNavy
                                          .withOpacity(0.05),
                                  border: Border.all(
                                      color: AppColors.strategicGold, width: 2),
                                  image: _pickedImagePath != null
                                      ? DecorationImage(
                                          image: FileImage(
                                              File(_pickedImagePath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _pickedImagePath == null
                                    ? const Icon(Icons.person,
                                        size: 50, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.midnightNavy,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.strategicGold),
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: AppColors.strategicGold, size: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            if (_roleController.text.isEmpty) {
                              CustomSnackBar.show(
                                context,
                                message: "Please enter Target Role first.",
                                type: SnackBarType.error,
                              );
                              return;
                            }
                            CustomSnackBar.show(
                              context,
                              message:
                                  "Generative AI Agent: Designing Avatar...",
                              type: SnackBarType.info,
                            );

                            // Call Gemini 2.0
                            final gemini = ref.read(geminiServiceProvider);
                            final newAvatarUrl = await gemini.generateHeadshot(
                                _roleController.text, null);

                            setState(() {
                              _pickedImagePath = newAvatarUrl;
                            });
                          },
                          icon: const Icon(Icons.auto_awesome,
                              color: AppColors.strategicGold, size: 16),
                          label: Text("GENERATE AI AVATAR",
                              style: AppTypography.labelSmall
                                  .copyWith(color: AppColors.strategicGold)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'PROFILE DATA',
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.strategicGold, letterSpacing: 2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      GlassContainer(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildGlassTextField(
                              controller: _nameController,
                              label: "FULL NAME",
                              icon: Icons.person_outline,
                              textColor: textColor,
                              hintColor: hintColor,
                            ),
                            const SizedBox(height: 20),
                            _buildGlassTextField(
                              controller: _roleController,
                              label: "TARGET ROLE",
                              icon: Icons.badge_outlined,
                              textColor: textColor,
                              hintColor: hintColor,
                            ),
                            const SizedBox(height: 20),
                            _buildGlassTextField(
                              controller: _emailController,
                              label: "CONTACT EMAIL",
                              icon: Icons.email_outlined,
                              textColor: textColor,
                              hintColor: hintColor,
                            ),
                            const SizedBox(height: 20),
                            _buildGlassTextField(
                              controller: _linkedInController,
                              label: "LINKEDIN PROFILE LINK",
                              icon: Icons.link,
                              textColor: textColor,
                              hintColor: hintColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => _saveProfile(data),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.midnightNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          side: BorderSide(
                              color: AppColors.strategicGold.withOpacity(0.5)),
                        ),
                        child: Text("SAVE PROFILE",
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white)),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: TextButton(
                          onPressed: _deleteAccount,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                          ),
                          child: Text("DELETE ACCOUNT",
                              style: AppTypography.labelSmall.copyWith(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.strategicGold)),
          error: (err, stack) => Center(
              child: Text('Error: $err', style: TextStyle(color: textColor))),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall.copyWith(
                color: textColor.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: controller,
            style: AppTypography.bodyMedium.copyWith(color: textColor),
            decoration: InputDecoration(
              icon: Icon(icon, color: AppColors.strategicGold, size: 20),
              border: InputBorder.none,
              hintText: "Enter $label...",
              hintStyle: TextStyle(color: hintColor),
            ),
            validator: (value) => null, // Optional validation
          ),
        ),
      ],
    );
  }

  void _saveProfile(ResumeData? currentData) {
    if (_formKey.currentState!.validate()) {
      final newData = currentData ?? ResumeData();
      newData.fullName = _nameController.text;
      newData.targetRole = _roleController.text;
      newData.email = _emailController.text;
      newData.linkedIn = _linkedInController.text;
      newData.avatarUrl = _pickedImagePath;

      ref.read(profileProvider.notifier).saveProfile(newData);

      CustomSnackBar.show(
        context,
        message: 'Profile Updated',
        type: SnackBarType.success,
      );
      context.pop();
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.midnightNavy,
          title: Text("Delete Account?",
              style: AppTypography.header3.copyWith(color: Colors.white)),
          content: Text(
              "This action is irreversible. All your resume data and profile information will be permanently removed.",
              style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("DELETE",
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(authServiceProvider).deleteAccount();
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: "Account Deleted successfully.",
            type: SnackBarType.success,
          );
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: "Deletion Failed: $e",
            type: SnackBarType.error,
          );
        }
      }
    }
  }
}
