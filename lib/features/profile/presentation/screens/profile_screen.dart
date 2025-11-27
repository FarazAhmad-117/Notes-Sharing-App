import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isDeleting = false;
  final _passwordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> _showPasswordVerificationDialog() async {
    _passwordController.clear();
    bool obscurePassword = true;

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.red),
                SizedBox(width: AppSpacing.sm),
                Text('Verify Password'),
              ],
            ),
            content: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please enter your password to confirm account deletion. This action cannot be undone.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (_passwordFormKey.currentState!.validate()) {
                    Navigator.of(context).pop(_passwordController.text);
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Verify & Delete'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    // First confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Password verification dialog
    final password = await _showPasswordVerificationDialog();

    if (password == null || password.isEmpty || !mounted) {
      return;
    }

    // Proceed with deletion
    setState(() => _isDeleting = true);
    try {
      await ref.read(authProvider.notifier).deleteAccount(password);
      if (mounted) {
        ToastService.showSuccess('Account deleted successfully');
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        final authState = ref.read(authProvider);
        ToastService.showError(
          authState.error ?? 'Failed to delete account. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        ToastService.showSuccess('Logged out successfully');
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        final authState = ref.read(authProvider);
        ToastService.showError(
          authState.error ?? 'Failed to logout. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.displayName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Name
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  // Email Verification Badge
                  if (!user.isEmailVerified) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Email not verified',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Information Section
                  _buildSectionTitle('Account Information'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Display Name',
                    value: user.displayName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoCard(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoCard(
                    context,
                    icon: Icons.calendar_today_outlined,
                    title: 'Member Since',
                    value: DateFormat('MMM dd, yyyy').format(user.createdAt),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Settings Section
                  _buildSectionTitle('Settings'),
                  const SizedBox(height: AppSpacing.md),

                  // Theme Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        isDark ? 'Dark theme enabled' : 'Light theme enabled',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (value) {
                          ref
                              .read(themeProvider.notifier)
                              .setTheme(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                          ToastService.showInfo(
                            value ? 'Dark mode enabled' : 'Light mode enabled',
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Actions Section
                  _buildSectionTitle('Actions'),
                  const SizedBox(height: AppSpacing.md),

                  // Logout Button
                  PrimaryButton(
                    text: 'Logout',
                    onPressed: authState.isLoading ? null : _handleLogout,
                    isLoading: authState.isLoading && !_isDeleting,
                    icon: Icons.logout_rounded,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Delete Account Button
                  OutlinedButton(
                    onPressed: _isDeleting || authState.isLoading
                        ? null
                        : _handleDeleteAccount,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded),
                              SizedBox(width: AppSpacing.sm),
                              Text('Delete Account'),
                            ],
                          ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
