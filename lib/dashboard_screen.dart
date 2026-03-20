import 'package:flutter/material.dart';
import 'package:rojgar/home.dart';
import 'package:rojgar/kyc_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/modules/product_screens/product_screen_list.dart';
import 'package:rojgar/modules/sell_product/sell_product_category.dart';

class AC {
  static const Color primaryPurple = Color(0xFF5B2BE0);
  static const Color lightPurple = Color(0xFFEDE8FF);
  static const Color darkText = Color(0xFF111111);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF2F3F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color searchBg = Color(0xFFEEEFF5);
  static const Color borderColor = Color(0xFFE0E0EE);
  static const Color navBg = Color(0xFFFFFFFF);

  // Quick link icon bg colors
  static const Color blueBg = Color(0xFFDEEAFF);
  static const Color greenBg = Color(0xFFD6F5E8);
  static const Color purpleBg = Color(0xFFEEDDFF);
  static const Color orangeBg = Color(0xFFFFEDD5);
  static const Color pinkBg = Color(0xFFFFDDDD);
  static const Color cyanBg = Color(0xFFD5F5FF);

  // Icon colors
  static const Color blueIcon = Color(0xFF2255DD);
  static const Color greenIcon = Color(0xFF1E9E5E);
  static const Color purpleIcon = Color(0xFF8833CC);
  static const Color orangeIcon = Color(0xFFDD6611);
  static const Color pinkIcon = Color(0xFFDD3366);
  static const Color cyanIcon = Color(0xFF0099CC);
}

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────
class QuickLink {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const QuickLink(this.label, this.icon, this.bgColor, this.iconColor);
}

const List<QuickLink> kQuickLinks = [
  QuickLink('Find Jobs', Icons.work_rounded, AC.blueBg, AC.blueIcon),
  QuickLink('KYC Status', Icons.verified_rounded, AC.greenBg, AC.greenIcon),
  QuickLink(
    'Sell Products',
    Icons.storefront_rounded,
    AC.greenBg,
    AC.greenIcon,
  ),
  QuickLink(
    'Marketplace',
    Icons.storefront_rounded,
    AC.purpleBg,
    AC.purpleIcon,
  ),
  QuickLink('Earnings', Icons.payments_rounded, AC.orangeBg, AC.orangeIcon),
  QuickLink('Support', Icons.support_agent_rounded, AC.pinkBg, AC.pinkIcon),
  QuickLink('Skill Up', Icons.school_rounded, AC.cyanBg, AC.cyanIcon),
];

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.successMessage});

  final String? successMessage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  bool _sidebarOpen = false;
  late AnimationController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRegistrationSuccessDialog(widget.successMessage!);
      });
    }
  }

  void _showRegistrationSuccessDialog(String email) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: Text('You registered successfully with this email: $email'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _openSidebar() {
    setState(() => _sidebarOpen = true);
    _sidebarController.forward();
  }

  void _closeSidebar() {
    _sidebarController.reverse().then((_) {
      if (mounted) setState(() => _sidebarOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.045;

    return Scaffold(
      backgroundColor: AC.scaffoldBg,
      body: Stack(
        children: [
          // ── Main content ──────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top Header ─────────────────────
                _buildHeader(hPad, l10n),

                // ── Search Bar ─────────────────────
                _buildSearchBar(hPad, l10n),

                const SizedBox(height: 4),

                // ── Scrollable Body ────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        // Quick Links header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.text('dashboard_quick_links'),
                                style: const TextStyle(
                                  color: AC.darkText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  l10n.text('view_all'),
                                  style: const TextStyle(
                                    color: AC.primaryPurple,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Quick Links Grid
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: kQuickLinks.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.22,
                                ),
                            itemBuilder: (context, i) =>
                                _QuickLinkCard(link: kQuickLinks[i]),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Recent Activity
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Text(
                            l10n.text('dashboard_recent_activity'),
                            style: const TextStyle(
                              color: AC.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Activity Card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: _buildActivityCard(size, l10n),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Sidebar Overlay ────────────────────
          if (_sidebarOpen)
            AnimatedBuilder(
              animation: _sidebarController,
              builder: (context, _) {
                return Stack(
                  children: [
                    // Dark scrim
                    GestureDetector(
                      onTap: _closeSidebar,
                      child: FadeTransition(
                        opacity: _sidebarController,
                        child: Container(color: Colors.black.withOpacity(0.45)),
                      ),
                    ),
                    // Sidebar panel
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _sidebarController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: _CollapsibleSidebar(onClose: _closeSidebar),
                    ),
                  ],
                );
              },
            ),
        ],
      ),

      // // ── Bottom Navigation ─────────────────
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader(double hPad, AppLocalizations l10n) {
    return Container(
      color: AC.scaffoldBg,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      child: Row(
        children: [
          // Hamburger — tappable
          GestureDetector(
            onTap: _openSidebar,
            child: const Icon(Icons.menu_rounded, color: AC.darkText, size: 26),
          ),

          const SizedBox(width: 10),

          // Location chip
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AC.lightPurple,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AC.primaryPurple,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.text('dashboard_location'),
                      style: const TextStyle(
                        color: AC.primaryPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AC.primaryPurple,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Language toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AC.borderColor, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_langBtn('EN', true), _langBtn('HI', false)],
            ),
          ),

          const SizedBox(width: 10),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AC.lightPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AC.primaryPurple,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langBtn(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AC.primaryPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AC.greyText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Search ───────────────────────────────────
  Widget _buildSearchBar(double hPad, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AC.searchBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          style: const TextStyle(color: AC.darkText, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.text('dashboard_search_hint'),
            hintStyle: const TextStyle(color: AC.greyText, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AC.greyText,
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Activity Card ────────────────────────────
  Widget _buildActivityCard(Size size, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: size.height * 0.25,
        color: const Color(0xFF8ED8D4),
        child: Stack(
          children: [
            // Background office scene illustration
            CustomPaint(
              size: Size(size.width, size.height * 0.25),
              painter: _OfficePainter(),
            ),

            // NEW JOB badge
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.text('dashboard_new_job_badge'),
                  style: const TextStyle(
                    color: AC.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      _NavItem(Icons.work_rounded, Icons.work_outline_rounded, 'Jobs'),
      _NavItem(Icons.storefront_rounded, Icons.storefront_outlined, 'Market'),
      _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AC.navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        i == _navIndex
                            ? items[i].activeIcon
                            : items[i].inactiveIcon,
                        color: i == _navIndex ? AC.primaryPurple : AC.greyText,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: i == _navIndex
                              ? AC.primaryPurple
                              : AC.greyText,
                          fontSize: 11,
                          fontWeight: i == _navIndex
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUICK LINK CARD
// ─────────────────────────────────────────────
class _QuickLinkCard extends StatelessWidget {
  final QuickLink link;
  const _QuickLinkCard({required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AC.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    link.label == 'KYC Status' || link.label == 'Sell Products'
                    ? link.label == 'KYC Status'
                          ? EditKycScreen()
                          : SellProductCategoryScreen()
                    : ExploreCareerScreen(),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: link.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(link.icon, color: link.iconColor, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                link.label,
                style: const TextStyle(
                  color: AC.darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OFFICE SCENE PAINTER
// ─────────────────────────────────────────────
class _OfficePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // Teal background
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF8ED8D4));

    // Floor
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
      Paint()..color = const Color(0xFF7BC8C4),
    );

    // Table
    final tablePaint = Paint()..color = const Color(0xFFE8C87A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.08,
          s.height * 0.58,
          s.width * 0.72,
          s.height * 0.06,
        ),
        const Radius.circular(4),
      ),
      tablePaint,
    );
    // Table legs
    for (final lx in [s.width * 0.12, s.width * 0.72]) {
      canvas.drawRect(
        Rect.fromLTWH(lx, s.height * 0.64, s.width * 0.03, s.height * 0.16),
        tablePaint,
      );
    }

    // Laptop on table
    final lapPaint = Paint()..color = const Color(0xFF9999BB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.35,
          s.height * 0.42,
          s.width * 0.18,
          s.height * 0.16,
        ),
        const Radius.circular(3),
      ),
      lapPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.32,
          s.height * 0.57,
          s.width * 0.24,
          s.height * 0.03,
        ),
        const Radius.circular(2),
      ),
      lapPaint,
    );

    // Screen glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.36,
          s.height * 0.43,
          s.width * 0.16,
          s.height * 0.13,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFCCDDFF),
    );

    // Blue divider / document
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.42,
          s.height * 0.38,
          s.width * 0.12,
          s.height * 0.22,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFAAAAAFF).withOpacity(0.5),
    );

    // Person 1 – left (leaning, yellow shirt)
    _drawPerson(
      canvas,
      s,
      cx: s.width * 0.14,
      topY: s.height * 0.2,
      bodyColor: const Color(0xFFE8A030),
      pantsColor: const Color(0xFF3355AA),
      skinColor: const Color(0xFFD4A080),
      leaning: true,
    );

    // Person 2 – center-left (sitting, pink shirt)
    _drawPerson(
      canvas,
      s,
      cx: s.width * 0.36,
      topY: s.height * 0.3,
      bodyColor: const Color(0xFFDDAACF),
      pantsColor: const Color(0xFF444466),
      skinColor: const Color(0xFFD4A080),
      sitting: true,
    );

    // Person 3 – center (standing, white shirt)
    _drawPerson(
      canvas,
      s,
      cx: s.width * 0.54,
      topY: s.height * 0.18,
      bodyColor: const Color(0xFFEEEEEE),
      pantsColor: const Color(0xFF223366),
      skinColor: const Color(0xFFD4A080),
    );

    // Person 4 – right (sitting, orange/rust shirt)
    _drawPerson(
      canvas,
      s,
      cx: s.width * 0.76,
      topY: s.height * 0.3,
      bodyColor: const Color(0xFFCC7755),
      pantsColor: const Color(0xFF334466),
      skinColor: const Color(0xFFD4A080),
      sitting: true,
    );

    // Hanging lamp 1
    _drawLamp(canvas, s, s.width * 0.3, const Color(0xFFFFEE88));
    // Hanging lamp 2
    _drawLamp(canvas, s, s.width * 0.55, const Color(0xFFFFEE88));

    // Plant (right side)
    _drawPlant(canvas, s, s.width * 0.9);
  }

  void _drawPerson(
    Canvas canvas,
    Size s, {
    required double cx,
    required double topY,
    required Color bodyColor,
    required Color pantsColor,
    required Color skinColor,
    bool leaning = false,
    bool sitting = false,
  }) {
    final skin = Paint()..color = skinColor;
    final body = Paint()..color = bodyColor;
    final pants = Paint()..color = pantsColor;
    final hair = Paint()..color = const Color(0xFF332211);

    final double headR = s.width * 0.045;
    final double bodyH = s.height * 0.22;
    final double bodyW = s.width * 0.1;

    // Head
    final headCx = cx + (leaning ? s.width * 0.05 : 0);
    final headCy = topY + headR;
    canvas.drawCircle(Offset(headCx, headCy), headR, skin);
    // Hair
    final hairP = Path();
    hairP.addArc(
      Rect.fromCircle(center: Offset(headCx, headCy), radius: headR),
      3.14,
      3.14,
    );
    canvas.drawPath(hairP, hair);

    if (sitting) {
      // Torso
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - bodyW / 2, topY + headR * 2, bodyW, bodyH * 0.38),
          const Radius.circular(4),
        ),
        body,
      );
      // Legs horizontal
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            cx - bodyW * 0.8,
            topY + headR * 2 + bodyH * 0.38,
            bodyW * 1.6,
            bodyH * 0.14,
          ),
          const Radius.circular(4),
        ),
        pants,
      );
    } else if (leaning) {
      // Torso angled
      final torsoPath = Path();
      torsoPath.moveTo(cx, topY + headR * 2);
      torsoPath.lineTo(cx + bodyW * 0.8, topY + headR * 2 + bodyH * 0.18);
      torsoPath.lineTo(
        cx + bodyW * 0.8 + bodyW * 0.6,
        topY + headR * 2 + bodyH * 0.18,
      );
      torsoPath.lineTo(cx + bodyW * 0.6, topY + headR * 2);
      torsoPath.close();
      canvas.drawPath(torsoPath, body);
      // Legs
      for (final lx in [cx - bodyW * 0.15, cx + bodyW * 0.35]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              lx,
              topY + headR * 2 + bodyH * 0.18,
              bodyW * 0.28,
              bodyH * 0.45,
            ),
            const Radius.circular(4),
          ),
          pants,
        );
      }
    } else {
      // Normal standing
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - bodyW / 2, topY + headR * 2, bodyW, bodyH * 0.38),
          const Radius.circular(4),
        ),
        body,
      );
      for (final lx in [cx - bodyW * 0.32, cx + bodyW * 0.04]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              lx,
              topY + headR * 2 + bodyH * 0.38,
              bodyW * 0.28,
              bodyH * 0.4,
            ),
            const Radius.circular(4),
          ),
          pants,
        );
      }
    }
  }

  void _drawLamp(Canvas canvas, Size s, double cx, Color lightColor) {
    final cord = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, 0), Offset(cx, s.height * 0.22), cord);

    final shade = Paint()..color = const Color(0xFFEEEECC);
    final shadePath = Path();
    shadePath.moveTo(cx - s.width * 0.04, s.height * 0.22);
    shadePath.lineTo(cx - s.width * 0.025, s.height * 0.32);
    shadePath.lineTo(cx + s.width * 0.025, s.height * 0.32);
    shadePath.lineTo(cx + s.width * 0.04, s.height * 0.22);
    shadePath.close();
    canvas.drawPath(shadePath, shade);

    // Light glow
    canvas.drawCircle(
      Offset(cx, s.height * 0.32),
      s.width * 0.04,
      Paint()
        ..color = lightColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawPlant(Canvas canvas, Size s, double cx) {
    // Pot
    final potPath = Path();
    potPath.moveTo(cx - s.width * 0.04, s.height * 0.72);
    potPath.lineTo(cx - s.width * 0.03, s.height * 0.84);
    potPath.lineTo(cx + s.width * 0.03, s.height * 0.84);
    potPath.lineTo(cx + s.width * 0.04, s.height * 0.72);
    potPath.close();
    canvas.drawPath(potPath, Paint()..color = const Color(0xFFDDDDDD));

    // Stem
    canvas.drawLine(
      Offset(cx, s.height * 0.72),
      Offset(cx, s.height * 0.3),
      Paint()
        ..color = const Color(0xFF44AA44)
        ..strokeWidth = 3,
    );

    // Leaves
    final leafPaint = Paint()..color = const Color(0xFF44BB44);
    for (int i = 0; i < 3; i++) {
      final leafY = s.height * (0.66 - i * 0.14);
      final side = i.isEven ? 1.0 : -1.0;

      final lp = Path();
      lp.moveTo(cx, leafY);
      lp.quadraticBezierTo(
        cx + side * s.width * 0.1,
        leafY - s.height * 0.04,
        cx + side * s.width * 0.08,
        leafY - s.height * 0.1,
      );
      lp.quadraticBezierTo(
        cx + side * s.width * 0.04,
        leafY - s.height * 0.07,
        cx,
        leafY,
      );
      canvas.drawPath(lp, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}

// ─────────────────────────────────────────────
// COLLAPSIBLE SIDEBAR
// ─────────────────────────────────────────────
class _SidebarMenuItem {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  const _SidebarMenuItem(this.icon, this.label, this.iconBg, this.iconColor);
}

const List<_SidebarMenuItem> _kSidebarItems = [
  _SidebarMenuItem(
    Icons.home_rounded,
    'Home',
    Color(0xFFDEEAFF),
    Color(0xFF2255DD),
  ),
  _SidebarMenuItem(
    Icons.storefront_rounded,
    'Products',
    Color(0xFFDEEAFF),
    Color(0xFF2255DD),
  ),
  _SidebarMenuItem(
    Icons.work_rounded,
    'Find Jobs',
    Color(0xFFD6F5E8),
    Color(0xFF1E9E5E),
  ),
  _SidebarMenuItem(
    Icons.verified_rounded,
    'KYC Status',
    Color(0xFFEEDDFF),
    Color(0xFF8833CC),
  ),
  _SidebarMenuItem(
    Icons.sell_rounded,
    'Sell Products',
    Color(0xFFFFEDD5),
    Color(0xFFDD6611),
  ),
  _SidebarMenuItem(
    Icons.storefront_rounded,
    'Marketplace',
    Color(0xFFFFEDD5),
    Color(0xFFDD6611),
  ),
  _SidebarMenuItem(
    Icons.payments_rounded,
    'Earnings',
    Color(0xFFFFDDDD),
    Color(0xFFDD3366),
  ),
  _SidebarMenuItem(
    Icons.school_rounded,
    'Skill Up',
    Color(0xFFD5F5FF),
    Color(0xFF0099CC),
  ),
  _SidebarMenuItem(
    Icons.support_agent_rounded,
    'Support',
    Color(0xFFEDE8FF),
    Color(0xFF5B2BE0),
  ),
  _SidebarMenuItem(
    Icons.settings_rounded,
    'Settings',
    Color(0xFFF0F0F0),
    Color(0xFF555577),
  ),
];

class _CollapsibleSidebar extends StatefulWidget {
  final VoidCallback onClose;
  const _CollapsibleSidebar({required this.onClose});

  @override
  State<_CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<_CollapsibleSidebar> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width * 0.78;
    return Container(
      width: sw,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 32,
            offset: Offset(8, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo / brand
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B2BE0), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Rojgar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AC.darkText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Close button
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AC.searchBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AC.darkText,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Profile Card ─────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B2BE0), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rahul Sharma',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Worker • KYC Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section label ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'MENU',
                style: TextStyle(
                  color: AC.greyText.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Menu Items ────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                itemCount: _kSidebarItems.length,
                itemBuilder: (context, i) {
                  final item = _kSidebarItems[i];
                  final isActive = _selected == i;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selected = i;
                          });
                          if (item.label == 'Products') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProductScreenList(),
                              ),
                            );
                          }
                          if (item.label == 'KYC Status') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditKycScreen(),
                              ),
                            );
                          } else if (item.label == 'Sell Products') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SellProductCategoryScreen(),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AC.primaryPurple.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AC.primaryPurple.withOpacity(0.15)
                                      : item.iconBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: isActive
                                      ? AC.primaryPurple
                                      : item.iconColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isActive
                                        ? AC.primaryPurple
                                        : AC.darkText,
                                    fontSize: 15,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AC.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Logout ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDD3344),
                        size: 22,
                      ),
                      SizedBox(width: 14),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFDD3344),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
