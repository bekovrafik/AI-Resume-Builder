import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';

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
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Standard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.strategicGold),
            onPressed: () => _saveProfile(profileAsync.value),
          )
        ],
      ),
      body: profileAsync.when(
        data: (data) {
          _initData(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comprehensive Identity Data',
                    style: AppTextStyles.headerSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Full Name", _nameController, Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField("Target Role", _roleController, Icons.work),
                  const SizedBox(height: 12),
                  _buildTextField("Email", _emailController, Icons.email),
                  const SizedBox(height: 12),
                  _buildTextField(
                      "LinkedIn URL", _linkedInController, Icons.link),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _saveProfile(data),
                    icon: const Icon(Icons.save),
                    label: const Text("Save Identity"),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.slateGrey),
      ),
      validator: (value) {
        // Optional validation
        return null;
      },
    );
  }

  void _saveProfile(ResumeData? currentData) {
    if (_formKey.currentState!.validate()) {
      final newData = currentData ?? ResumeData();
      newData.fullName = _nameController.text;
      newData.targetRole = _roleController.text;
      newData.email = _emailController.text;
      newData.linkedIn = _linkedInController.text;

      ref.read(profileProvider.notifier).saveProfile(newData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Saved Locally')),
      );
    }
  }
}
