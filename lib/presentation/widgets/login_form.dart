import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final Function(String username, String password) onLogin;

  const LoginForm({super.key, required this.isLoading, required this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: context.l10n.usernameLabel, prefixIcon: Icon(Icons.person)),
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: context.l10n.passwordLabel,
            prefixIcon: const Icon(Icons.password),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              tooltip: _obscurePassword 
                ? context.l10n.tooltipShowPassword
                : context.l10n.tooltipHidePassword,
            ),
          ),
          obscureText: _obscurePassword,
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : () => widget.onLogin(_usernameController.text, _passwordController.text),
            child: widget.isLoading ? const CircularProgressIndicator() : Text(context.l10n.loginButton),
          ),
        ),
      ],
    );
  }
}