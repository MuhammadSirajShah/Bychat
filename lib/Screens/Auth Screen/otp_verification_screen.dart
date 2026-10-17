
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _backgroundColor = Color(0xFF171C20);
const Color _surfaceColor = Color(0xFF222A2E);
const Color _blueColor = Color(0xFF579BFF);
const Color _tealColor = Color(0xFF009688);
const Color _textColor = Color(0xFFF1F3F5);
const Color _mutedColor = Color(0xFF9AA4AA);

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showMessage('Please enter the 6-digit OTP.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      _showMessage('Phone number verified successfully!');

      // AuthGate will display HomeScreen after successful login.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Invalid OTP. Please try again.');
    } catch (_) {
      _showMessage('Verification failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _surfaceColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        title: const Text('Verify your number'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 72,
                    color: _blueColor,
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Enter verification code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Enter the code sent to ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _mutedColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    enabled: !_isLoading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _textColor,
                      fontSize: 27,
                      letterSpacing: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    cursorColor: _blueColor,
                    decoration: InputDecoration(
                      hintText: '------',
                      hintStyle: const TextStyle(color: _mutedColor),
                      filled: true,
                      fillColor: _surfaceColor,
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _blueColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _tealColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: FilledButton.styleFrom(
                        backgroundColor: _tealColor,
                        foregroundColor: const Color(0xFF182027),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: _backgroundColor,
                      )
                          : const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
