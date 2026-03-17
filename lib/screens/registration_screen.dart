// ============================================================
// Screen 03a: Authentication / Registration Screen
// Name, email, and password registration form
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'login_screen.dart'; // To navigate back after registration

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables for UI feedback
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Password strength tracking (0.0 to 1.0)
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Calculates password strength based on length, character variety, etc.
  // Returns a value between 0.0 (empty) and 1.0 (very strong).
  void _updatePasswordStrength(String password) {
    double strength = 0.0;
    String label = '';

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthLabel = '';
      });
      return;
    }

    // +0.25 for meeting minimum length
    if (password.length >= 6) strength += 0.25;
    // +0.25 for having uppercase AND lowercase letters
    if (password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    // +0.25 for including a number
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    // +0.25 for including a special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    if (strength <= 0.25) {
      label = 'Weak';
    } else if (strength <= 0.5) {
      label = 'Fair';
    } else if (strength <= 0.75) {
      label = 'Good';
    } else {
      label = 'Strong';
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
    });
  }

  // Basic email validation
  bool _isValidEmail(String email) {
    // Use a regular expression for more robust email validation.
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  // Handle registration logic
  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Clear previous error
    setState(() => _errorMessage = null);

    // --- Form Validation ---
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    // Show loading spinner
    setState(() => _isLoading = true);

    try {
      // --- Simulate Backend Call ---
      // A 'register.php' endpoint is assumed to exist, similar to 'login.php'
      // We send the data as a form field to work around server configurations
      // that might strip raw JSON bodies.
      final response = await http.post(
        Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/register.php'),
        body: {
          'payload': json.encode({
            'name': name,
            'email': email,
            'password': password,
          })
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) { // 201 Created is more appropriate
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        // Navigate to the login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // --- Enhanced Debugging ---
        // Log the exact status code and body to help diagnose server-side issues.
        debugPrint('Registration failed with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        // --- End Enhanced Debugging ---

        final errorData = json.decode(response.body);
        String serverError = errorData['error'] ?? 'Registration failed. Please try again.';

        // This is a workaround for a server-side issue where the registration endpoint
        // might be incorrectly returning a login error. This provides a clearer message to the user.
        if (serverError.toLowerCase().contains('invalid email or password')) {
          serverError = 'This email may already be taken, or a server error occurred.';
        }
        setState(() {
          _errorMessage = serverError;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Registration failed with error: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The UI is very similar to the Login Screen for consistency
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button to return to Login
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 20),

              // Header
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start managing your shipments today.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              // --- Form Fields ---
              _buildTextField(controller: _nameController, label: 'FULL NAME', hint: 'Jane Doe'),
              const SizedBox(height: 20),
              _buildTextField(controller: _emailController, label: 'EMAIL ADDRESS', hint: 'jane.doe@email.com', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _passwordController,
                label: 'PASSWORD',
                isVisible: _isPasswordVisible,
                onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                onChanged: _updatePasswordStrength,
              ),
              // Password strength indicator bar
              if (_passwordStrength > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.grey.shade200,
                          // Color changes based on strength: red -> orange -> blue -> green
                          color: _passwordStrength <= 0.25
                              ? Colors.red
                              : _passwordStrength <= 0.5
                                  ? Colors.orange
                                  : _passwordStrength <= 0.75
                                      ? const Color(0xFF1A56DB)
                                      : const Color(0xFF10B981),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _passwordStrengthLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _passwordStrength <= 0.25
                            ? Colors.red
                            : _passwordStrength <= 0.5
                                ? Colors.orange
                                : _passwordStrength <= 0.75
                                    ? const Color(0xFF1A56DB)
                                    : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              _buildPasswordField(controller: _confirmPasswordController, label: 'CONFIRM PASSWORD', isVisible: _isConfirmPasswordVisible, onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 15)),
                ),
              const SizedBox(height: 8),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1A56DB).withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for standard text fields to reduce repetition
  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A56DB), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // Helper widget for password fields with optional onChanged callback
  Widget _buildPasswordField({required TextEditingController controller, required String label, required bool isVisible, required VoidCallback onToggleVisibility, ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A56DB), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 22),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}