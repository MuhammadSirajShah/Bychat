
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_verification_screen.dart';


const Color _backgroundColor = Color(0xFF171C20);
const Color _surfaceColor = Color(0xFF222A2E);
const Color _greenColor = Color(0xFF25D366);
const Color _blueColor = Color(0xFF579BFF);
//const Color _orangeColor = Color(0xFFFFA34D);
const Color _textColor = Color(0xFFF1F3F5);
const Color _mutedColor = Color(0xFF9AA4AA);

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  Country _selectedCountry = Country.parse('PK');
  bool _isLoading = false;

  bool get _isPhoneValid {
    final digits = _phoneController.text.replaceAll(
      RegExp(r'\D'),
      '',
    );
    return digits.length >= 7 && digits.length <= 15;
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim().replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (phone.isEmpty || !_isPhoneValid) {
      _showMessage('Please enter a valid phone number.');
      return;
    }

    final fullPhoneNumber = '+${_selectedCountry.phoneCode}$phone';

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
          } on FirebaseAuthException catch (error) {
            _showMessage(error.message ?? 'Phone verification failed.');
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          _showMessage(
            error.message ?? 'Could not send OTP. Please try again.',
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                verificationId: verificationId,
                phoneNumber: fullPhoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Something went wrong.');
    } catch (_) {
      _showMessage('Unable to send OTP. Please try again.');
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

  void _selectCountry() {
    if (_isLoading) return;

    showCountryPicker(
      context: context,
      showPhoneCode: false,
      showSearch: true,
      countryListTheme: CountryListThemeData(
        backgroundColor: _surfaceColor,
        textStyle: const TextStyle(color: _textColor),
        searchTextStyle: const TextStyle(color: _textColor),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: const TextStyle(color: _mutedColor),
          prefixIcon: const Icon(Icons.search, color: _greenColor),
          filled: true,
          fillColor: _backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        bottomSheetHeight: 550,
      ),
      onSelect: (Country country) {
        setState(() => _selectedCountry = country);
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        const Text(
                          'Enter your phone number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 29,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.7,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: _mutedColor,
                              fontSize: 15,
                              height: 1.55,
                            ),
                            children: [
                              TextSpan(
                                text: 'ByChat will verify your account. ',
                              ),
                              TextSpan(
                                text: "What's my phone number?",
                                style: TextStyle(
                                  color: _greenColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 56),

                        // Country selector
                        InkWell(
                          onTap: _selectCountry,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: 10,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _greenColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedCountry.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: _textColor,
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: _greenColor,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Calling code and phone number
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 82,
                              padding: const EdgeInsets.only(
                                top: 3,
                                bottom: 8,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _greenColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                '+${_selectedCountry.phoneCode}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _textColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),

                            const SizedBox(width: 22),

                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                style: const TextStyle(
                                  color: _textColor,
                                  fontSize: 20,
                                ),
                                cursorColor: _greenColor,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  hintText: 'Phone number',
                                  hintStyle: TextStyle(
                                    color: _mutedColor,
                                    fontSize: 20,
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    left: 0,
                                    right: 0,
                                    top: 3,
                                    bottom: 8,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _greenColor,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _blueColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: (_isLoading || !_isPhoneValid)
                      ? null
                      : _sendOtp,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: _surfaceColor,
                    disabledForegroundColor: const Color(0xFF596168),
                    foregroundColor: const Color(0xFF182027),
                    shape: const StadiumBorder(),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.teal,
                    ),
                  )
                      : const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

