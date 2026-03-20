import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rojgar/dashboard_screen.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class AC {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFDDDDEE);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color sectionTitle = Color(0xFF1400FF);
  static const Color otpBg = Color(0xFFF0F0F8);
  static const Color uploadBg = Color(0xFFF7F8FF);
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  // Controllers
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _localityCtrl = TextEditingController();
  final TextEditingController _pincodeCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _acceptedTerms = false;
  bool _isStatesLoading = false;
  bool _isDistrictsLoading = false;
  int? _selectedStateId;
  int? _selectedDistrictId;
  final List<_DropdownItem> _states = [];
  final List<_DropdownItem> _districts = [];
  final Logger _logger = Logger();

  bool get _isRegistrationEnabled {
    return _fullNameCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty &&
        _emailCtrl.text.trim().isNotEmpty &&
        _localityCtrl.text.trim().isNotEmpty &&
        _pincodeCtrl.text.trim().isNotEmpty &&
        _addressCtrl.text.trim().isNotEmpty &&
        _usernameCtrl.text.trim().isNotEmpty &&
        _passwordCtrl.text.isNotEmpty &&
        _selectedStateId != null &&
        _selectedDistrictId != null &&
        _acceptedTerms &&
        !_isSubmitting;
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStates();
    _fullNameCtrl.addListener(_onFormChanged);
    _phoneCtrl.addListener(_onFormChanged);
    _emailCtrl.addListener(_onFormChanged);
    _localityCtrl.addListener(_onFormChanged);
    _pincodeCtrl.addListener(_onFormChanged);
    _addressCtrl.addListener(_onFormChanged);
    _usernameCtrl.addListener(_onFormChanged);
    _passwordCtrl.addListener(_onFormChanged);
  }

  Future<void> _fetchStates() async {
    setState(() => _isStatesLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://rozgaradda.com/api/states'),
      );
      _logger.i('States response (${response.statusCode}): ${response.body}');

      if (response.statusCode != 200) return;

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = json['data'] as List<dynamic>? ?? <dynamic>[];

      if (!mounted) return;
      setState(() {
        _states
          ..clear()
          ..addAll(
            data.map((e) => _DropdownItem.fromJson(e as Map<String, dynamic>)),
          );
      });
    } catch (e) {
      _logger.e('Failed to fetch states', error: e);
    } finally {
      if (mounted) {
        setState(() => _isStatesLoading = false);
      }
    }
  }

  Future<void> _fetchDistricts(int stateId) async {
    setState(() {
      _isDistrictsLoading = true;
      _selectedDistrictId = null;
      _districts.clear();
    });

    try {
      final response = await http.get(
        Uri.parse('https://rozgaradda.com/api/districts/$stateId'),
      );
      _logger.i(
        'Districts response (${response.statusCode}): ${response.body}',
      );

      if (response.statusCode != 200) return;

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = json['data'] as List<dynamic>? ?? <dynamic>[];

      if (!mounted) return;
      setState(() {
        _districts
          ..clear()
          ..addAll(
            data.map((e) => _DropdownItem.fromJson(e as Map<String, dynamic>)),
          );
      });
    } catch (e) {
      _logger.e('Failed to fetch districts', error: e);
    } finally {
      if (mounted) {
        setState(() => _isDistrictsLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.removeListener(_onFormChanged);
    _phoneCtrl.removeListener(_onFormChanged);
    _emailCtrl.removeListener(_onFormChanged);
    _localityCtrl.removeListener(_onFormChanged);
    _pincodeCtrl.removeListener(_onFormChanged);
    _addressCtrl.removeListener(_onFormChanged);
    _usernameCtrl.removeListener(_onFormChanged);
    _passwordCtrl.removeListener(_onFormChanged);
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _localityCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.05;

    return Scaffold(
      backgroundColor: AC.scaffoldBg,
      // ── AppBar ──────────────────────────────
      appBar: AppBar(
        backgroundColor: AC.primaryBlue,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
        centerTitle: true,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rozgar Adda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            Text(
              'Join the Workforce',
              style: TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Progress bar row ───────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Registration Progress',
                        style: TextStyle(
                          color: AC.darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        child: const Text(
                          'Step 1 of 3',
                          style: TextStyle(
                            color: AC.primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: AC.lightGrey,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.33,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AC.yellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ════════════════════════════
                  // PERSONAL INFO
                  // ════════════════════════════
                  _sectionHeader(Icons.person_outline, 'Personal Info'),
                  const SizedBox(height: 14),

                  // Full Name
                  _fieldLabel('Full Name'),
                  const SizedBox(height: 6),
                  _inputField(
                    hint: 'Enter your full name',
                    controller: _fullNameCtrl,
                  ),

                  const SizedBox(height: 14),

                  // Phone Number
                  _fieldLabel('Phone Number'),
                  const SizedBox(height: 6),
                  _phoneField(),

                  const SizedBox(height: 10),

                  // OTP Box
                  _otpSection(size),

                  const SizedBox(height: 14),

                  // Email
                  _fieldLabel('Email Address'),
                  const SizedBox(height: 6),
                  _inputField(
                    hint: 'name@example.com',
                    keyboard: TextInputType.emailAddress,
                    controller: _emailCtrl,
                  ),

                  const SizedBox(height: 22),

                  // ════════════════════════════
                  // ADDRESS DETAILS
                  // ════════════════════════════
                  _sectionHeader(Icons.location_on_outlined, 'Address Details'),
                  const SizedBox(height: 14),

                  // State + District
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('State'),
                            const SizedBox(height: 6),
                            _stateDropdown(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('District'),
                            const SizedBox(height: 6),
                            _districtDropdown(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Area + Pincode
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Area / Locality'),
                            const SizedBox(height: 6),
                            _inputField(
                              hint: 'Area',
                              controller: _localityCtrl,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Pincode'),
                            const SizedBox(height: 6),
                            _inputField(
                              hint: '000000',
                              keyboard: TextInputType.number,
                              controller: _pincodeCtrl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Full Address
                  _fieldLabel('Full Address'),
                  const SizedBox(height: 6),
                  _multilineField(
                    'House no, Street name...',
                    controller: _addressCtrl,
                  ),

                  const SizedBox(height: 22),

                  // ════════════════════════════
                  // IDENTITY VERIFICATION
                  // ════════════════════════════
                  _sectionHeader(Icons.badge_outlined, 'Identity Verification'),
                  const SizedBox(height: 14),

                  _uploadBox(),

                  const SizedBox(height: 22),

                  // ════════════════════════════
                  // ACCOUNT CREDENTIALS
                  // ════════════════════════════
                  _sectionHeader(
                    Icons.lock_outline_rounded,
                    'Account Credentials',
                  ),
                  const SizedBox(height: 14),

                  _fieldLabel('Username'),
                  const SizedBox(height: 6),
                  _inputField(
                    hint: 'Choose a unique username',
                    controller: _usernameCtrl,
                  ),

                  const SizedBox(height: 14),

                  _fieldLabel('Password'),
                  const SizedBox(height: 6),
                  _passwordField(),

                  const SizedBox(height: 16),

                  // Terms checkbox
                  _termsRow(),

                  const SizedBox(height: 20),

                  // Create Account button
                  _createAccountBtn(),

                  const SizedBox(height: 14),

                  // Bottom login text
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: AC.greyText, fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              color: AC.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AC.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AC.sectionTitle,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: AC.darkText,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _inputField({
    required String hint,
    TextInputType keyboard = TextInputType.text,
    Widget? suffix,
    Widget? prefix,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: AC.darkText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AC.greyText, fontSize: 14),
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AC.borderColor, width: 1.2),
              ),
            ),
            child: const Text(
              '+91',
              style: TextStyle(
                color: AC.darkText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AC.darkText, fontSize: 14),
              decoration: const InputDecoration(
                hintText: '00000 00000',
                hintStyle: TextStyle(color: AC.greyText, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AC.yellow,
                foregroundColor: AC.darkText,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AC.darkText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpSection(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AC.otpBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter 4-digit OTP sent to phone',
            style: TextStyle(
              color: AC.greyText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AC.borderColor, width: 1.2),
                  ),
                  child: const TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AC.darkText,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _stateDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedStateId,
          isExpanded: true,
          hint: Text(
            _isStatesLoading ? 'Loading states...' : 'Select State',
            style: const TextStyle(color: AC.greyText, fontSize: 14),
          ),
          items: _states
              .map(
                (state) => DropdownMenuItem<int>(
                  value: state.id,
                  child: Text(state.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _isStatesLoading
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() => _selectedStateId = value);
                  _fetchDistricts(value);
                },
        ),
      ),
    );
  }

  Widget _districtDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDistrictId,
          isExpanded: true,
          hint: Text(
            _selectedStateId == null
                ? 'Select state first'
                : _isDistrictsLoading
                ? 'Loading districts...'
                : 'Select District',
            style: const TextStyle(color: AC.greyText, fontSize: 14),
          ),
          items: _districts
              .map(
                (district) => DropdownMenuItem<int>(
                  value: district.id,
                  child: Text(district.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (_selectedStateId == null || _isDistrictsLoading)
              ? null
              : (value) {
                  setState(() => _selectedDistrictId = value);
                },
        ),
      ),
    );
  }

  Widget _multilineField(String hint, {TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: AC.darkText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AC.greyText, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _uploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AC.uploadBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AC.primaryBlue,
          width: 1.5,
          // Dashed effect via custom painter below
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AC.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AC.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload Identity Proof',
            style: TextStyle(
              color: AC.darkText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aadhar Card, PAN, or Voter ID (JPG/PDF, max 2MB)',
            style: TextStyle(color: AC.greyText, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AC.primaryBlue, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            ),
            child: const Text(
              'Choose File',
              style: TextStyle(
                color: AC.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      child: TextField(
        controller: _passwordCtrl,
        obscureText: true,
        style: const TextStyle(color: AC.darkText, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Min 8 characters',
          hintStyle: TextStyle(color: AC.greyText, fontSize: 14),
          suffixIcon: Icon(
            Icons.remove_red_eye_outlined,
            color: AC.greyText,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _termsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _acceptedTerms ? AC.primaryBlue : Colors.transparent,
              border: Border.all(
                color: _acceptedTerms ? AC.primaryBlue : AC.greyText,
                width: 1.5,
              ),
            ),
            child: _acceptedTerms
                ? const Icon(Icons.check, color: Colors.white, size: 13)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(color: AC.greyText, fontSize: 12, height: 1.5),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AC.primaryBlue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AC.primaryBlue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: ' of Rozgar Adda.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _createAccountBtn() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: _isRegistrationEnabled
              ? const [AC.primaryBlue, Color(0xFF6644FF), AC.yellow]
              : const [Color(0xFFB8BCCD), Color(0xFFB8BCCD)],
          stops: _isRegistrationEnabled
              ? const [0.0, 0.6, 1.0]
              : const [0.0, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (_isRegistrationEnabled
                        ? AC.primaryBlue
                        : const Color(0xFFB8BCCD))
                    .withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _isRegistrationEnabled ? _submitRegistration : null,
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Account',
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

  Future<void> _submitRegistration() async {
    final fullName = _fullNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final locality = _localityCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        locality.isEmpty ||
        pincode.isEmpty ||
        address.isEmpty) {
      _showMessage('Please fill all required fields.');
      return;
    }

    if (_selectedStateId == null) {
      _showMessage('Please select a state.');
      return;
    }

    if (_selectedDistrictId == null) {
      _showMessage('Please select a district.');
      return;
    }
    if (!_acceptedTerms) {
      _showMessage('Please accept Terms and Privacy Policy to continue.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uri = Uri.parse('https://rozgaradda.com/api/candidate/register');
      final response = await http.post(
        uri,
        headers: const {'Accept': 'application/json'},
        body: {
          'full_name': fullName,
          'phone': phone,
          'email': email,
          'username': username,
          'password': password,
          'state': _selectedStateId.toString(),
          'district': _selectedDistrictId.toString(),
          'locality': locality,
          'pincode': pincode,
          'address': address,
        },
      );

      _logger.i('Register response (${response.statusCode}): ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        final bool status = json['status'] == true;
        final String message =
            json['message']?.toString() ?? 'Registration completed.';

        if (status) {
          final prefs = await SharedPreferences.getInstance();
          final dynamic rawId = json['candidate_id'];
          int? candidateId;
          if (rawId is int) {
            candidateId = rawId;
          } else if (rawId != null) {
            candidateId = int.tryParse(rawId.toString());
          }
          if (candidateId != null) {
            await prefs.setInt('candidate_id', candidateId);
          }

          if (!mounted) return;
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => HomeScreen(successMessage: email),
              ),
              (route) => false,
            );
          }
        } else {
          _showMessage(message);
        }
      } else {
        _showMessage(
          'Registration failed (code ${response.statusCode}). Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        'Something went wrong. Please check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

}

class _DropdownItem {
  final int id;
  final String name;

  const _DropdownItem({required this.id, required this.name});

  factory _DropdownItem.fromJson(Map<String, dynamic> json) {
    return _DropdownItem(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}
