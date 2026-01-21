import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seedly/components/back_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  // Brand color
  static const Color _brandColor = Color.fromARGB(255, 172, 71, 4);

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerify() {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 4) {
      // TODO: Implement OTP verification logic
    }
  }

  void _handleResendCode() {
    // TODO: Implement resend code logic
  }

  String _getMaskedEmail() {
    final email = widget.email;
    if (email.contains('@')) {
      final parts = email.split('@');
      final name = parts[0];
      final domain = parts[1];
      if (name.length > 2) {
        return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
      }
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button
              const UniversalBackButton(),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'We have sent a verification code to ',
                    ),
                    TextSpan(
                      text: _getMaskedEmail(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => _buildOtpField(index)),
              ),

              const SizedBox(height: 40),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Resend code
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleResendCode,
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
                          color: _brandColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? _brandColor
              : Colors.grey.shade300,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontFamily: 'Geist',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }
}
