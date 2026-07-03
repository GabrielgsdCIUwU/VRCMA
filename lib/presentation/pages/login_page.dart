import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/presentation/services/snackbar_service.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/widgets/auth_header.dart';
import 'package:vrcma/presentation/widgets/error_extension.dart';
import 'package:vrcma/presentation/widgets/login_form.dart';
import 'package:vrcma/presentation/widgets/otp_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final showOtpView = ref.watch(showOtpViewProvider);

    final bool is2FARequired = authState.hasError && authState.error is TwoFactorRequiredFailure;
    final bool showOtp = showOtpView || is2FARequired;

    ref.listen(authStateProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) {
          if (error is TwoFactorRequiredFailure) {
            ref.read(showOtpViewProvider.notifier).set(true);
          } else if (error is Failure) {
            ref.read(snackbarServiceProvider).show(error.toLocalizedString(context));
          }
        },
        data: (user) {
          if (user != null) {
            ref.read(snackbarServiceProvider).show(context.l10n.loginSuccess);
            ref.read(showOtpViewProvider.notifier).set(false);
          }
        },
      );
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const AuthHeader(),
              const SizedBox(height: 40),
              
              if (!showOtp)
                LoginForm(
                  isLoading: authState.isLoading,
                  onLogin: (user, pass) => ref.read(authStateProvider.notifier).login(user, pass),
                )
              else
                OtpForm(
                  isLoading: authState.isLoading,
                  onVerify: (code) => ref.read(authStateProvider.notifier).verifyOtp(code),
                  onCancel: () => ref.read(showOtpViewProvider.notifier).set(false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}