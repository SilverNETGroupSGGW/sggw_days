import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/admin/presentation/cubit/admin_auth_cubit.dart';
import 'package:sggw_days/features/admin/presentation/pages/admin_page.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminAuthCubit(),
      child: const _AdminLoginView(),
    );
  }
}

class _AdminLoginView extends StatefulWidget {
  const _AdminLoginView();

  @override
  State<_AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<_AdminLoginView> {
  final TextEditingController _emailController = TextEditingController(
    text: 'test@test.com',
  );
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminLogin)),
      body: BlocConsumer<AdminAuthCubit, AdminAuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => AdminAuthCubit(),
                  child: const AdminPage(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.adminLogin,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 32),
                      if (state.isUnauthorized)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            l10n.adminNotAuthorized,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Text(
                                l10n.adminSignInFailed,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.adminSignInFailedDetail(state.error!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      if (state.isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => context
                                .read<AdminAuthCubit>()
                                .loginWithGoogle(),
                            icon: const Icon(Icons.login),
                            label: Text(l10n.signInWithGoogle),
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 24),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.debugEmailLoginTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: InputDecoration(
                                      labelText: l10n.email,
                                      prefixIcon: const Icon(
                                        Icons.alternate_email,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: l10n.password,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                    ),
                                    onSubmitted: (_) =>
                                        _signInWithDebugEmail(context),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _signInWithDebugEmail(context),
                                    icon: const Icon(Icons.bug_report_outlined),
                                    label: Text(l10n.signInWithEmailDebug),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _signInWithDebugEmail(BuildContext context) {
    context.read<AdminAuthCubit>().loginWithEmailDebug(
      _emailController.text,
      _passwordController.text,
    );
  }
}
