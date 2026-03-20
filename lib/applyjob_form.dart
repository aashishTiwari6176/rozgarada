import 'package:flutter/material.dart';
import 'package:rojgar/localization/app_localizations.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color white = Colors.white;
  static const Color background = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF1A1AE6);
  static const Color darkBlue = Color(0xFF1010CC);
  static const Color stepLabel = Color(0xFF2222DD);
  static const Color darkText = Color(0xFF111122);
  static const Color greyText = Color(0xFF888899);
  static const Color inputBorder = Color(0xFFDDDDE8);
  static const Color inputBg = Color(0xFFFAFAFC);
  static const Color inputHint = Color(0xFFBBBBCC);
  static const Color progressBg = Color(0xFFEEEEF5);
  static const Color progressFill = Color(0xFF2222DD);
  static const Color sectionIcon = Color(0xFF2222DD);
  static const Color uploadBorder = Color(0xFF9999DD);
  static const Color uploadBg = Color(0xFFF8F8FE);
  static const Color uploadIconBg = Color(0xFFDDDDF8);
  static const Color checkBorder = Color(0xFFCCCCDD);
  static const Color linkBlue = Color(0xFF2222DD);
  static const Color footerText = Color(0xFFAAAAAB);
  static const Color agreeBg = Color(0xFFF4F4FA);
  static const Color cardShadow = Color(0x08000000);
}

void main() => runApp(const JobApplicationApp());

class JobApplicationApp extends StatelessWidget {
  const JobApplicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This secondary MaterialApp is mainly for preview; localization
    // from the root app will typically be used instead.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const JobApplicationScreen(),
    );
  }
}

class JobApplicationScreen extends StatefulWidget {
  const JobApplicationScreen({super.key});

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildProgressSection(l10n),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    Icons.person_outline_rounded,
                    l10n.text('apply_personal_info'),
                  ),
                  const SizedBox(height: 20),
                  _buildLabeledField(
                    l10n.text('apply_first_name'),
                    'John',
                  ),
                  const SizedBox(height: 16),
                  _buildLabeledField(
                    l10n.text('apply_last_name'),
                    'Doe',
                  ),
                  const SizedBox(height: 16),
                  _buildLabeledField(
                    l10n.text('apply_email'),
                    'john.doe@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    Icons.work_outline_rounded,
                    l10n.text('apply_professional_details'),
                  ),
                  const SizedBox(height: 20),
                  _buildLabeledField(
                    l10n.text('apply_current_position'),
                    'UI/UX Designer',
                  ),
                  const SizedBox(height: 16),
                  _buildLabeledField(
                    l10n.text('apply_linkedin'),
                    'linkedin.com/in/username',
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    Icons.upload_file_outlined,
                    l10n.text('apply_resume_upload'),
                  ),
                  const SizedBox(height: 16),
                  _buildUploadBox(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    Icons.edit_note_rounded,
                    l10n.text('apply_why_hire'),
                  ),
                  const SizedBox(height: 16),
                  _buildTextArea(l10n),
                  const SizedBox(height: 28),
                  _buildAgreementRow(l10n),
                  const SizedBox(height: 24),
                  _buildSubmitButton(l10n),
                  const SizedBox(height: 28),
                  _buildFooter(l10n),
                  SizedBox(height: bottomPad + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 14),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: AppColors.darkText,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Senior Product Designer',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const Icon(Icons.share_outlined, size: 22, color: AppColors.darkText),
        ],
      ),
    );
  }

  Widget _buildProgressSection(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.text('apply_step_label'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.stepLabel,
                letterSpacing: 0.4,
                height: 1.5,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '50%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  l10n.text('apply_complete'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 7,
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppColors.progressBg,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.progressFill,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.sectionIcon, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryBlue,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField(
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorder, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.uploadBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.uploadBorder,
          width: 1.5,
          // Flutter doesn't natively support dashed borders, so we use a solid
          // light border which closely matches the reference's dashed effect.
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.uploadIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Click to upload or drag and drop',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'PDF, DOCX up to 10MB',
            style: TextStyle(fontSize: 12, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        maxLines: 5,
        style: const TextStyle(fontSize: 14, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: l10n.text('apply_why_hire_hint'),
          hintStyle: const TextStyle(
            color: AppColors.greyText,
            fontSize: 14,
            height: 1.5,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAgreementRow(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.agreeBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _agreed ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _agreed
                      ? AppColors.primaryBlue
                      : AppColors.checkBorder,
                  width: 1.5,
                ),
              ),
              child: _agreed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.text('apply_agree'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1AE6), Color(0xFF3333FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.text('apply_submit'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFFFCC00),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.text('apply_footer'),
        style: const TextStyle(fontSize: 11, color: AppColors.footerText),
        textAlign: TextAlign.center,
      ),
    );
  }
}
