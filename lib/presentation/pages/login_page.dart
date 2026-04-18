import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/presentation/services/snackbar_service.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/widgets/auth_header.dart';
import 'package:vrcma/presentation/widgets/login_form.dart';
import 'package:vrcma/presentation/widgets/otp_form.dart';
class LoginPage  extends ConsumerStatefulWidget{
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _showOtpView = false;

  @override
  Widget build(BuildContext context) {
   final authState = ref.watch(authStateProvider);

   final bool is2FARequired = authState.hasError && authState.error is TwoFactorRequiredFailure;
   final bool showOtp = _showOtpView || is2FARequired;

   ref.listen(authStateProvider, (prev, next) {
     next.whenOrNull(
       error: (error, _) {
         if (error is TwoFactorRequiredFailure) {
           setState(() => _showOtpView = true);
         } else if (error is Failure) {
           ref.read(snackbarServiceProvider).show(error.message);
         }
       },
       data: (user) {
         if (user != null) ref.read(snackbarServiceProvider).show('Login Success!');
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
                   onLogin: (user, pass) => ref.read(authStateProvider.notifier)
                    .login(user, pass),
               ) else
                 OtpForm(
                     isLoading: authState.isLoading,
                     onVerify: (code) => ref.read(authStateProvider.notifier).verifyOtp(code),
                     onCancel: () => setState(() => _showOtpView = false)
                 ),
           ],
         ),
       ),
     )
   );
  }
}