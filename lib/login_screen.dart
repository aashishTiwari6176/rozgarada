import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/ragistartion_screen.dart';
import 'package:rojgar/select_state_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Color constants
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color accentYellow = Color(0xFFFFCC00);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color lightLavender = Color(0xFFEAEAF8);
  static const Color borderColor = Color(0xFFD0D5F5);
  static const Color fieldBg = Color(0xFFF7F8FF);
  static const Color scaffoldBg = Color(0xFFFFFFFF);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _acceptedTerms = false;
  final Logger _logger = Logger();

  bool get _isLoginEnabled {
    return _usernameController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _acceptedTerms &&
        !_isLoading;
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onFormChanged);
    _passwordController.removeListener(_onFormChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(context.l10n.text('login_error_empty'));
      return;
    }
    if (!_acceptedTerms) {
      _showErrorDialog('Please accept Terms and Privacy Policy to continue.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('https://rozgaradda.com/api/candidate/login');
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 25));

      _logger.i('Login response (${response.statusCode}): ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;

        final bool status = json['status'] == true;

        if (status) {
          // Persist candidate id if present for later KYC updates
          try {
            final prefs = await SharedPreferences.getInstance();
            final dynamic rawId =
                json['candidate_id'] ?? json['id'] ?? json['data']?['id'];
            int? candidateId;
            if (rawId is int) {
              candidateId = rawId;
            } else if (rawId != null) {
              candidateId = int.tryParse(rawId.toString());
            }
            if (candidateId != null) {
              await prefs.setInt('candidate_id', candidateId);
            }
          } catch (_) {
            // Ignore persistence errors and continue navigation
          }

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SelectStateScreen(successMessage: username),
            ),
          );
        } else {
          final message =
              json['message']?.toString() ??
              'Invalid username or password. Please try again.';
          _showErrorDialog(message);
        }
      } else {
        _showErrorDialog(
          'Login failed with status code ${response.statusCode}. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      final details = kDebugMode ? '\n\n$e' : '';
      _showErrorDialog(
        'Something went wrong. Please check your internet connection and try again.$details',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.text('login_error_title')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.text('ok')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double hPad = size.width * 0.06;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue, size: 24),
            onPressed: () {},
          ),
        ),
        centerTitle: true,
        title: Text(
          l10n.text('login_title'),
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.04),

              // Logo Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: lightLavender,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(Icons.work_rounded, color: primaryBlue, size: 42),
                ),
              ),

              SizedBox(height: size.height * 0.028),

              // Heading
              Text(
                l10n.text('login_welcome_back'),
                style: const TextStyle(
                  color: darkText,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Subheading
              Text(
                l10n.text('login_subtitle'),
                style: const TextStyle(
                  color: greyText,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * 0.04),

              // Email Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.text('login_email_label'),
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Email Field
              _buildInputField(
                hintText: l10n.text('login_email_hint'),
                controller: _usernameController,
                prefixIcon: Icons.mail_outline_rounded,
                obscureText: false,
              ),

              const SizedBox(height: 18),

              // Password Label + Forgot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.text('login_password_label'),
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      l10n.text('login_forgot'),
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Password Field
              _buildInputField(
                hintText: '••••••••',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _isPasswordObscured,
                showSuffix: true,
                onSuffixTap: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Terms and privacy acceptance
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _acceptedTerms ? primaryBlue : Colors.transparent,
                        border: Border.all(
                          color: _acceptedTerms ? primaryBlue : greyText,
                          width: 1.5,
                        ),
                      ),
                      child: _acceptedTerms
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'I agree to Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.032),

              // Sign In Button
              _createAccountBtn(
                onTap: _isLoginEnabled ? _login : null,
                isEnabled: _isLoginEnabled,
                isLoading: _isLoading,
              ),

              SizedBox(height: size.height * 0.032),

              // OR CONTINUE WITH divider
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFFE0E0E0)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        color: greyText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFFE0E0E0)),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.028),

              // Social Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      icon: _googleIcon(),
                      label: 'Google',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      icon: _linkedInIcon(),
                      label: 'LinkedIn',
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.04),

              // Register text
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegistrationFormScreen(),
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.text('login_no_account'),
                        style: const TextStyle(
                          color: greyText,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: l10n.text('login_register'),
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFFFCC00),
                          decorationThickness: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData prefixIcon,
    required bool obscureText,
    TextEditingController? controller,
    bool showSuffix = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: greyText, fontSize: 15),
          prefixIcon: Icon(prefixIcon, color: primaryBlue, size: 20),
          suffixIcon: showSuffix
              ? IconButton(
                  onPressed: onSuffixTap,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: greyText,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required Widget icon, required String label}) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _linkedInIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Icon(Icons.person_outline, color: Colors.white, size: 16),
      ),
    );
  }

  static Widget _createAccountBtn({
    required VoidCallback? onTap,
    required bool isEnabled,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isEnabled
              ? const [primaryBlue, Color(0xFF6644FF), accentYellow]
              : const [Color(0xFFB8BCCD), Color(0xFFB8BCCD)],
          stops: isEnabled ? const [0.0, 0.6, 1.0] : const [0.0, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isEnabled ? primaryBlue : const Color(0xFFB8BCCD))
                .withAlpha((0.35 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
