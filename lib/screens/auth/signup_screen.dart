import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'widgets/auth_wallpaper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      role: _selectedRole,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(
        context,
        _selectedRole == UserRole.admin ? AppRoutes.admin : AppRoutes.home,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: AuthWallpaper(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AuthPanel(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create account',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text('Create a user or admin account.'),
                        const SizedBox(height: 20),
                        _RoleSelector(
                          selectedRole: _selectedRole,
                          onChanged: (role) =>
                              setState(() => _selectedRole = role),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Name',
                          controller: _nameController,
                          validator: (value) =>
                              Validators.required(value, fieldName: 'Name'),
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            auth.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        CustomButton(
                          label: auth.state == ViewState.loading
                              ? 'Creating account...'
                              : 'Create account',
                          icon: Icons.person_add_alt_1,
                          onPressed: auth.state == ViewState.loading
                              ? null
                              : _submit,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selectedRole, required this.onChanged});

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(
          value: UserRole.user,
          icon: Icon(Icons.person_outline),
          label: Text('User'),
        ),
        ButtonSegment(
          value: UserRole.admin,
          icon: Icon(Icons.admin_panel_settings_outlined),
          label: Text('Admin'),
        ),
      ],
      selected: {selectedRole},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
