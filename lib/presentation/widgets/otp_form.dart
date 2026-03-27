import 'package:flutter/material.dart';

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
        const Text('Enter 2FA Code', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          decoration: const InputDecoration(labelText: '6-Digit Code', prefixIcon: Icon(Icons.security)),
          keyboardType: TextInputType.number,
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
              onPressed: widget.isLoading ? null : () => widget.onVerify(_otpController.text),
              child: widget.isLoading ? const CircularProgressIndicator() : const Text('Verify'),
          ),
        ),
        TextButton(onPressed: widget.onCancel, child: const Text('Back')),
      ],
    );
  }
}