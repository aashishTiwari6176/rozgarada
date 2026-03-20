import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rojgar/dashboard_screen.dart';

// ─────────────────────────────────────────────
// COLOR CONSTANTS
// ─────────────────────────────────────────────
class AC {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF111111);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFDDDDEE);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color pendingBg = Color(0xFFFFF8DC);
  static const Color iconBg = Color(0xFFE8EAFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sectionBlue = Color(0xFF1400FF);
  static const Color successGreen = Color(0xFF1E9E5E);
  static const Color successBg = Color(0xFFD6F5E8);
}

// ─────────────────────────────────────────────
// UPLOAD DOCUMENT TYPE
// ─────────────────────────────────────────────
enum _UploadType { image, file }

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class EditKycScreen extends StatefulWidget {
  const EditKycScreen({super.key});

  @override
  State<EditKycScreen> createState() => _EditKycScreenState();
}

class _EditKycScreenState extends State<EditKycScreen> {
  // Controllers
  final _nameCtrl = TextEditingController(text: 'Johnathon Doe');
  final _phoneCtrl = TextEditingController(text: '+1 (555) 000-0000');
  final _emailCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController(text: '123456');
  final _addressCtrl = TextEditingController();

  // Upload state: key = slot id, value = picked file info
  final Map<String, _UploadedFile?> _uploads = {
    'identity': null,
    'resume': null,
    'photo': null,
  };

  bool _isLoading = false;
  int? _candidateId;
  int? _stateId;
  int? _districtId;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadCandidateId();
  }

  Future<void> _loadCandidateId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('candidate_id');
      if (!mounted) return;
      setState(() {
        _candidateId = id;
      });
      if (id != null) {
        await _fetchKycData(id);
      }
    } catch (_) {
      // ignore read errors
    }
  }

  Future<void> _fetchKycData(int candidateId) async {
    try {
      final uri = Uri.parse(
        'https://rozgaradda.com/api/candidate/kyc?id=$candidateId',
      );
      final response = await http.get(uri);
      _logger.i('KYC GET response (${response.statusCode}): ${response.body}');

      if (response.statusCode != 200) return;

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != true) return;

      final candidate =
          data['candidate'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final List<dynamic> states =
          data['states'] as List<dynamic>? ?? <dynamic>[];

      String stateName = '';
      String districtName = '';

      final dynamic rawStateId = candidate['state_id'];
      final dynamic rawDistrictId = candidate['district_id'];
      final int? stateId = rawStateId is int
          ? rawStateId
          : int.tryParse(rawStateId?.toString() ?? '');
      final int? districtId = rawDistrictId is int
          ? rawDistrictId
          : int.tryParse(rawDistrictId?.toString() ?? '');

      if (stateId != null) {
        for (final s in states) {
          final sm = s as Map<String, dynamic>;
          if (sm['id'] == stateId) {
            stateName = sm['name']?.toString() ?? '';
            if (districtId != null) {
              final List<dynamic> districts =
                  sm['districts'] as List<dynamic>? ?? <dynamic>[];
              for (final d in districts) {
                final dm = d as Map<String, dynamic>;
                if (dm['id'] == districtId) {
                  districtName = dm['name']?.toString() ?? '';
                  break;
                }
              }
            }
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _stateId = stateId;
        _districtId = districtId;
        _nameCtrl.text = candidate['full_name']?.toString() ?? '';
        _phoneCtrl.text = candidate['phone']?.toString() ?? '';
        _emailCtrl.text = candidate['email']?.toString() ?? '';
        _stateCtrl.text = stateName;
        _districtCtrl.text = districtName;
        _localityCtrl.text = candidate['locality']?.toString() ?? '';
        _pincodeCtrl.text = candidate['pincode']?.toString() ?? '';
        _addressCtrl.text = candidate['address']?.toString() ?? '';
      });
    } catch (e) {
      _logger.e('Error fetching KYC data', error: e);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _localityCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── Pick image from camera or gallery ───────
  Future<void> _pickImage(String slotId) async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _uploads[slotId] = _UploadedFile(
        name: picked.name,
        path: picked.path,
        isImage: true,
      );
    });
    _showSnackbar('Photo uploaded successfully!', isSuccess: true);
  }

  // ── Pick document file ───────────────────────
  Future<void> _pickFile(String slotId) async {
    final List<String> exts;
    if (slotId == 'resume') {
      exts = ['pdf', 'doc', 'docx'];
    } else {
      exts = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: exts,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    setState(() {
      _uploads[slotId] = _UploadedFile(
        name: file.name,
        path: file.path ?? '',
        isImage: [
          'jpg',
          'jpeg',
          'png',
        ].contains(file.extension?.toLowerCase() ?? ''),
        size: file.size,
      );
    });
    _showSnackbar('Document uploaded successfully!', isSuccess: true);
  }

  // ── Bottom sheet: Camera vs Gallery ─────────
  Future<ImageSource?> _showImageSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AC.lightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AC.darkText,
              ),
            ),
            const SizedBox(height: 16),
            _sourceOption(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              color: AC.primaryBlue,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _sourceOption(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              color: AC.primaryBlue,
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            _sourceOption(
              icon: Icons.close_rounded,
              label: 'Cancel',
              color: Colors.red,
              onTap: () => Navigator.pop(context, null),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color == Colors.red ? Colors.red : AC.darkText,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showSnackbar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, softWrap: true)),
          ],
        ),
        backgroundColor: isSuccess ? AC.successGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeUpload(String slotId) {
    setState(() => _uploads[slotId] = null);
    _showSnackbar('File removed.');
  }

  String? _validateTextFields() {
    final fullName = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final state = _stateCtrl.text.trim();
    final district = _districtCtrl.text.trim();
    final locality = _localityCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        state.isEmpty ||
        district.isEmpty ||
        locality.isEmpty ||
        pincode.isEmpty ||
        address.isEmpty) {
      return 'Please fill all required fields.';
    }

    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length != 10) {
      return 'Please enter a valid 10-digit phone number.';
    }

    final pinDigits = pincode.replaceAll(RegExp(r'\D'), '');
    if (pinDigits.length != 6) {
      return 'Please enter a valid 6-digit pincode.';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  Future<void> _onUpdateKyc() async {
    // Validate
    final missing = _uploads.entries
        .where((e) => e.value == null)
        .map((e) => e.key)
        .toList();
    if (missing.isNotEmpty) {
      _showSnackbar('Please upload all required documents.');
      return;
    }

    final fieldError = _validateTextFields();
    if (fieldError != null) {
      _showSnackbar(fieldError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final candidateId = _candidateId ?? prefs.getInt('candidate_id');
      final selectedStateId = prefs.getInt('selected_state_id');

      if (candidateId == null) {
        _showSnackbar('Candidate ID not found. Please login again.');
        setState(() => _isLoading = false);
        return;
      }

      final uri = Uri.parse('https://rozgaradda.com/api/candidate/kyc-update');
      final request = http.MultipartRequest('POST', uri)
        ..fields['id'] = candidateId.toString()
        ..fields['full_name'] = _nameCtrl.text.trim()
        ..fields['phone'] = _phoneCtrl.text.trim()
        ..fields['email'] = _emailCtrl.text.trim()
        ..fields['state'] = (_stateId ?? selectedStateId)?.toString() ?? ''
        ..fields['district'] = _districtId?.toString() ?? ''
        ..fields['locality'] = _localityCtrl.text.trim()
        ..fields['pincode'] = _pincodeCtrl.text.trim()
        ..fields['address'] = _addressCtrl.text.trim();

      final idProof = _uploads['identity'];
      final resume = _uploads['resume'];
      final photo = _uploads['photo'];

      Future<void> addFile(String field, _UploadedFile? file) async {
        if (file == null || file.path.isEmpty) return;
        final f = File(file.path);
        if (!await f.exists()) return;
        request.files.add(await http.MultipartFile.fromPath(field, f.path));
      }

      await addFile('id_proof', idProof);
      await addFile('resume', resume);
      await addFile('profile_photo', photo);

      _logger.i('KYC request fields: ${request.fields}');
      _logger.i(
        'KYC request files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}',
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logger.i('KYC response (${response.statusCode}): ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> json = response.body.isNotEmpty
              ? (jsonDecode(response.body) as Map<String, dynamic>)
              : <String, dynamic>{};
          final bool status = json['status'] == true;
          final String message =
              json['message']?.toString() ?? 'KYC updated successfully';
          if (status) {
            _showSnackbar(message, isSuccess: true);
            // Navigate back to dashboard after a short delay
            await Future.delayed(const Duration(milliseconds: 600));
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            }
          } else {
            _showSnackbar(message);
          }
        } catch (_) {
          _showSnackbar('KYC updated successfully!', isSuccess: true);
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      } else {
        _showSnackbar(
          'Failed to update KYC. Please try again (code ${response.statusCode}).',
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackbar(
        'Something went wrong while updating KYC. Please check your connection.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.05;

    return Scaffold(
      backgroundColor: AC.scaffoldBg,
      body: Column(
        children: [
          // ── Blue AppBar ─────────────────────
          _buildAppBar(context),

          // ── Scrollable Body ─────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // Status chip
                  _statusChip(),

                  const SizedBox(height: 22),

                  // ── Personal Information ──────
                  _sectionHeader('Personal Information'),
                  const SizedBox(height: 16),

                  _fieldLabel('Full Name'),
                  const SizedBox(height: 6),
                  _inputField(controller: _nameCtrl),

                  const SizedBox(height: 14),

                  _fieldLabel('Phone Number'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: _phoneCtrl,
                    keyboard: TextInputType.phone,
                  ),

                  const SizedBox(height: 14),

                  _fieldLabel('Email Address'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: _emailCtrl,
                    hint: 'email@example.com',
                    keyboard: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 26),

                  // ── Address Information ───────
                  _sectionHeader('Address Information'),
                  const SizedBox(height: 16),

                  // State + District
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('State'),
                            const SizedBox(height: 6),
                            _inputField(controller: _stateCtrl, hint: 'State'),
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
                            _inputField(
                              controller: _districtCtrl,
                              hint: 'District',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Locality + Pincode
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Locality/Area'),
                            const SizedBox(height: 6),
                            _inputField(
                              controller: _localityCtrl,
                              hint: 'Area',
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
                              controller: _pincodeCtrl,
                              keyboard: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _fieldLabel('Complete Address'),
                  const SizedBox(height: 6),
                  _multilineField(
                    controller: _addressCtrl,
                    hint: 'Flat No, Building, Street...',
                  ),

                  const SizedBox(height: 28),

                  // ── Documents Upload ──────────
                  _sectionHeader('Documents Upload'),
                  const SizedBox(height: 6),
                  Text(
                    'Upload clear, readable copies. Supported: JPG, PNG, PDF, DOC',
                    style: TextStyle(color: AC.greyText, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Identity Proof
                  _UploadCard(
                    slotId: 'identity',
                    icon: Icons.badge_outlined,
                    title: 'Identity Proof',
                    subtitle: 'Aadhar, PAN or Passport',
                    uploadType: _UploadType.file,
                    uploaded: _uploads['identity'],
                    onUpload: () => _pickFile('identity'),
                    onPickImage: () => _pickImage('identity'),
                    onRemove: () => _removeUpload('identity'),
                  ),

                  const SizedBox(height: 12),

                  // Resume / CV
                  _UploadCard(
                    slotId: 'resume',
                    icon: Icons.description_outlined,
                    title: 'Resume / CV',
                    subtitle: 'PDF or Word format',
                    uploadType: _UploadType.file,
                    uploaded: _uploads['resume'],
                    onUpload: () => _pickFile('resume'),
                    onPickImage: () {}, // no image upload for resume
                    onRemove: () => _removeUpload('resume'),
                  ),

                  const SizedBox(height: 12),

                  // Profile Photo
                  _UploadCard(
                    slotId: 'photo',
                    icon: Icons.person_outline_rounded,
                    title: 'Profile Photo',
                    subtitle: 'Recent passport size photo',
                    uploadType: _UploadType.image,
                    uploaded: _uploads['photo'],
                    onUpload: () => _pickFile('photo'),
                    onPickImage: () => _pickImage('photo'),
                    onRemove: () => _removeUpload('photo'),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ── Update KYC Button ───────────────
          _buildBottomButton(hPad, context),
        ],
      ),
    );
  }

  // ── Blue AppBar ──────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AC.primaryBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16,
        right: 16,
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit KYC Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _candidateId == null
                ? 'Update your KYC information'
                : 'Update your KYC information for candidate #$_candidateId',
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Status chip ──────────────────────────────
  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AC.pendingBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFDD88), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AC.yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'STATUS: PENDING',
            style: TextStyle(
              color: Color(0xFF886600),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ───────────────────────────
  static Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AC.sectionBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AC.sectionBlue,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AC.darkText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget _inputField({
    TextEditingController? controller,
    String? hint,
    TextInputType keyboard = TextInputType.text,
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  static Widget _multilineField({
    TextEditingController? controller,
    required String hint,
  }) {
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

  // ── Bottom button ────────────────────────────
  Widget _buildBottomButton(double hPad, BuildContext context) {
    return Container(
      color: AC.scaffoldBg,
      padding: EdgeInsets.fromLTRB(
        hPad,
        12,
        hPad,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: GestureDetector(
        onTap: _isLoading ? null : _onUpdateKyc,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _isLoading
                ? AC.primaryBlue.withOpacity(0.65)
                : AC.primaryBlue,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AC.primaryBlue.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Update KYC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPLOADED FILE MODEL
// ─────────────────────────────────────────────
class _UploadedFile {
  final String name;
  final String path;
  final bool isImage;
  final int? size; // bytes

  const _UploadedFile({
    required this.name,
    required this.path,
    required this.isImage,
    this.size,
  });

  String get sizeLabel {
    if (size == null) return '';
    if (size! < 1024) return '${size}B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)}KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// ─────────────────────────────────────────────
// UPLOAD CARD WIDGET
// ─────────────────────────────────────────────
class _UploadCard extends StatelessWidget {
  final String slotId;
  final IconData icon;
  final String title;
  final String subtitle;
  final _UploadType uploadType;
  final _UploadedFile? uploaded;
  final VoidCallback onUpload;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;

  const _UploadCard({
    required this.slotId,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.uploadType,
    required this.uploaded,
    required this.onUpload,
    required this.onPickImage,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = uploaded != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AC.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFile ? AC.successGreen.withOpacity(0.5) : AC.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasFile ? AC.successBg : AC.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle_rounded : icon,
                    color: hasFile ? AC.successGreen : AC.primaryBlue,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AC.darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasFile ? uploaded!.name : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasFile ? AC.successGreen : AC.greyText,
                          fontSize: 12,
                          fontWeight: hasFile
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (hasFile && uploaded!.sizeLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          uploaded!.sizeLabel,
                          style: const TextStyle(
                            color: AC.greyText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action buttons
                if (!hasFile)
                  _ActionButtons(
                    uploadType: uploadType,
                    onUpload: onUpload,
                    onPickImage: onPickImage,
                  )
                else
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Preview (if image uploaded) ────────
          if (hasFile && uploaded!.isImage && uploaded!.path.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(uploaded!.path),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: AC.lightGrey,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AC.greyText,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── PDF / Doc preview badge ────────────
          if (hasFile && !uploaded!.isImage) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.red,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          uploaded!.name.split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      uploaded!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AC.darkText, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final _UploadType uploadType;
  final VoidCallback onUpload;
  final VoidCallback onPickImage;

  const _ActionButtons({
    required this.uploadType,
    required this.onUpload,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    if (uploadType == _UploadType.image) {
      // Image-only: show camera + gallery
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBtn(icon: Icons.camera_alt_rounded, onTap: onPickImage),
          const SizedBox(width: 6),
          _iconBtn(icon: Icons.photo_library_rounded, onTap: onUpload),
        ],
      );
    }
    // File: show file picker + camera option
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconBtn(icon: Icons.camera_alt_rounded, onTap: onPickImage),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onUpload,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AC.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'UPLOAD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AC.iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AC.primaryBlue, size: 19),
      ),
    );
  }
}
