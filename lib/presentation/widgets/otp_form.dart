import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/ll10n_extension.dart';

class OtpForm extends StatefulWidget {
  final bool isLoading;
  final Function(String code) onVerify;
  final VoidCallback onCancel;

  const OtpForm({
    super.key,
    required this.isLoading,
    required this.onVerify,
    required this.onCancel
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.l10n.enter2faTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          decoration: InputDecoration(labelText: context.l10n.digitCodeLabel, prefixIcon: Icon(Icons.security)),
          keyboardType: TextInputType.number,
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
              onPressed: widget.isLoading ? null : () => widget.onVerify(_otpController.text),
              child: widget.isLoading ? const CircularProgressIndicator() : Text(context.l10n.verifyButton),
          ),
        ),
        TextButton(onPressed: widget.onCancel, child: Text(context.l10n.backButton)),
      ],
    );
  }
}