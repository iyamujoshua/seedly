import 'package:flutter/material.dart';
import 'package:seedly/components/back_button.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  // Brand color
  static const Color _brandColor = Color.fromARGB(255, 172, 71, 4);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    // TODO: Implement send code logic
    // Navigate to OTP screen after sending code
    if (_emailController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(email: _emailController.text),
        ),
      );
    }
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
                'Forgot\npassword?',
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
              Text(
                'Don\'t worry! It happens. Please enter the email address associated with your account.',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Email field label
              Text(
                'Email address',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),

              // Email field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      fontFamily: 'Geist',
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Send code button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Send Code',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
