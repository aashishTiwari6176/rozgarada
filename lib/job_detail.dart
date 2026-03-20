import 'package:flutter/material.dart';
import 'package:rojgar/applyjob_form.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color white = Colors.white;
  static const Color background = Color(0xFFFAFAFC);
  static const Color primaryBlue = Color(0xFF2222DD);
  static const Color titleBlue = Color(0xFF1A1AE6);
  static const Color sectionBlue = Color(0xFF2222DD);
  static const Color darkText = Color(0xFF222233);
  static const Color greyText = Color(0xFF777788);
  static const Color lightLabel = Color(0xFF9999AA);
  static const Color cardBg = Color(0xFFF4F4FA);
  static const Color cardShadow = Color(0x0C000000);
  static const Color tagBg = Color(0xFFEAEAF8);
  static const Color tagText = Color(0xFF3333CC);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color logoGreen = Color(0xFF4A7C6F);
  static const Color mapTeal = Color(0xFF5BA8A0);
  static const Color checkBlue = Color(0xFF3333CC);
  static const Color borderLight = Color(0xFFEEEEF4);
  static const Color locationPin = Color(0xFF777788);
}

void main() => runApp(const JobDetailApp());

class JobDetailApp extends StatelessWidget {
  const JobDetailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const JobDetailScreen(),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _buildHeader(topPad),
          // ── Scrollable Content ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildCompanySection(),
                  const SizedBox(height: 24),
                  _buildInfoCards(),
                  const SizedBox(height: 32),
                  _buildRoleDescription(),
                  const SizedBox(height: 32),
                  _buildRequirements(),
                  const SizedBox(height: 32),
                  _buildLocation(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // ── Bottom Action Bar ────────────────────────────────────────────────
          _buildBottomBar(bottomPad, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JobApplicationScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 14),
      child: Row(
        children: [
          _iconBtn(Icons.close_rounded),
          const Expanded(
            child: Center(
              child: Text(
                'Job Opportunity',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          _iconBtn(Icons.share_outlined),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Icon(icon, size: 22, color: AppColors.darkText);
  }

  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.logoGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text(
              'MIM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Job title
        const Text(
          'Senior Product Designer',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.titleBlue,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        // Company + type
        Row(
          children: const [
            Text(
              'TechFlow Inc.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '·',
                style: TextStyle(color: AppColors.greyText, fontSize: 16),
              ),
            ),
            Text(
              'Full-time',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Location
        Row(
          children: const [
            Icon(
              Icons.location_on_outlined,
              size: 15,
              color: AppColors.locationPin,
            ),
            SizedBox(width: 4),
            Text(
              'San Francisco, CA (Remote Friendly)',
              style: TextStyle(fontSize: 13, color: AppColors.greyText),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _infoCard('ANNUAL SALARY', '\$140k - \$180k', isBlue: true),
        const SizedBox(height: 12),
        _infoCard('EXPERIENCE', '5+ years', isBlue: false),
        const SizedBox(height: 12),
        _infoCard('APPLICANTS', '124 Applied', isBlue: true),
      ],
    );
  }

  Widget _infoCard(String label, String value, {required bool isBlue}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.lightLabel,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isBlue ? AppColors.titleBlue : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDescription() {
    const bullets = [
      'Lead end-to-end design process from discovery to high-fidelity handoffs.',
      'Collaborate with product managers and engineers to define requirements.',
      'Mentor junior designers and contribute to our design system.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Role Description'),
        const SizedBox(height: 12),
        const Text(
          'We are looking for a Senior Product Designer to join our core product team. You will be responsible for leading the design direction of our flagship mobile and web applications, ensuring a seamless user experience for millions of users worldwide.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.greyText,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        ...bullets.map((b) => _bulletItem(b)),
      ],
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppColors.checkBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkText,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    const tags = [
      'Figma Expertise',
      'UI/UX Strategy',
      'Prototyping',
      'Design Systems',
      'User Research',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Requirements'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.map((t) => _tag(t)).toList(),
        ),
      ],
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.tagText,
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Location'),
        const SizedBox(height: 14),
        // Map placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(painter: _MapPainter()),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'Main headquarters located in the Mission District, SF.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.greyText,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.sectionBlue,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildBottomBar(double bottomPad, VoidCallback onApplyTap) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 14),
      child: Row(
        children: [
          // Apply Now button
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: onApplyTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.darkText,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Apply Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Bookmark button
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.greyText,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Map Painter ────────────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF5BA8A0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Road grid lines
    final road = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Horizontal roads
    for (double y = 20; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
    // Vertical roads
    for (double x = 20; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }

    // Highlight main roads
    final mainRoad = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      mainRoad,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      mainRoad,
    );

    // City blocks (rectangles)
    final block = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final blockPositions = [
      Rect.fromLTWH(40, 30, 80, 45),
      Rect.fromLTWH(145, 30, 60, 45),
      Rect.fromLTWH(230, 30, 90, 45),
      Rect.fromLTWH(40, 100, 70, 50),
      Rect.fromLTWH(145, 100, 80, 50),
      Rect.fromLTWH(250, 100, 70, 50),
    ];

    for (final r in blockPositions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        block,
      );
    }

    // Location pin
    final cx = size.width * 0.45;
    final cy = size.height * 0.6;

    final pinShadow = Paint()..color = Colors.black.withOpacity(0.2);
    canvas.drawCircle(
      Offset(cx, cy + 18),
      10,
      pinShadow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final pinOuter = Paint()..color = const Color(0xFFCC2222);
    canvas.drawCircle(Offset(cx, cy), 12, pinOuter);

    final pinInner = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 5, pinInner);

    // Pin tail
    final path = Path()
      ..moveTo(cx - 6, cy + 8)
      ..lineTo(cx + 6, cy + 8)
      ..lineTo(cx, cy + 22)
      ..close();
    canvas.drawPath(path, pinOuter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
