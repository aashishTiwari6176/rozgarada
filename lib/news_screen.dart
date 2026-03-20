import 'package:flutter/material.dart';

// ─── Colours ────────────────────────────────────────────────────────────────
class _NC {
  static const Color bg = Color(0xFFF4F5F9);
  static const Color navy = Color(0xFF1A1E3C);
  static const Color gold = Color(0xFFD4A017);
  static const Color accent = Color(0xFF2255DD);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF8A8FA3);
  static const Color tagNew = Color(0xFFFFD600);
}

// ─── Models ──────────────────────────────────────────────────────────────────
class _NewsArticle {
  final String tag;
  final String title;
  final String excerpt;
  final String readTime;
  final String? timeAgo;
  final bool hasBigImage;
  final bool hasVideo;
  final bool isNew;
  final bool isSaved;
  final Color? leftBorderColor;

  const _NewsArticle({
    required this.tag,
    required this.title,
    this.excerpt = '',
    this.readTime = '',
    this.timeAgo,
    this.hasBigImage = false,
    this.hasVideo = false,
    this.isNew = false,
    this.isSaved = false,
    this.leftBorderColor,
  });
}

// ─── Sample data ─────────────────────────────────────────────────────────────
const List<_NewsArticle> _articles = [
  _NewsArticle(
    tag: 'TRENDING',
    title: 'The 2024 Tech Hiring Boom: What You Need to Know',
    excerpt:
        'Leading industry experts project a 15% increase in specialist roles within the first...',
    readTime: '5 MINS READ',
    hasBigImage: true,
    hasVideo: false,
  ),
  _NewsArticle(
    tag: 'EXCLUSIVE INTERVIEW',
    title: 'Mastering Remote Negotiations with Fortune 500 HRs',
    excerpt: '',
    readTime: '',
    hasBigImage: false,
    hasVideo: true,
  ),
  _NewsArticle(
    tag: 'NEW',
    title: 'Public Sector Job Openings Increase by 20% This Month',
    excerpt:
        'Recent government mandates aim to fill over 50,000 vacancies in regional administrative offices by the end of summer.',
    readTime: '',
    timeAgo: '12 minutes ago',
    isNew: true,
    isSaved: false,
    leftBorderColor: _NC.gold,
  ),
  _NewsArticle(
    tag: 'CAREER ADVICE',
    title: '5 Essential Skills for the Future of AI-Driven Work',
    excerpt:
        'As automation reshapes roles, soft skills like empathy and critical thinking are becoming the new gold standard.',
    readTime: '',
    timeAgo: '2 hours ago',
    isNew: false,
    isSaved: false,
    leftBorderColor: _NC.accent,
  ),
];

// ─── Screen ──────────────────────────────────────────────────────────────────
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final Set<int> _saved = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _NC.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildBigImageCard(_articles[0]),
                    const SizedBox(height: 16),
                    _buildVideoCard(_articles[1]),
                    const SizedBox(height: 16),
                    _buildCompactCard(_articles[2], 2),
                    const SizedBox(height: 12),
                    _buildCompactCard(_articles[3], 3),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: _NC.navy,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.menu, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          const Text(
            'Rozgar News',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          const Icon(Icons.search, color: Colors.white, size: 24),
          const SizedBox(width: 14),
          _avatar(),
        ],
      ),
    );
  }

  Widget _avatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.deepOrangeAccent,
      child: const Text(
        'A',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Hero header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 32, height: 2.5, color: _NC.gold),
            const SizedBox(width: 8),
            const Text(
              'TRENDING NOW',
              style: TextStyle(
                color: _NC.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Career Insights for the\nModern Workforce',
          style: TextStyle(
            color: _NC.navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  // ── Big image card ────────────────────────────────────────────────────────
  Widget _buildBigImageCard(_NewsArticle article) {
    return Container(
      decoration: BoxDecoration(
        color: _NC.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Container(
              height: 190,
              width: double.infinity,
              color: const Color(0xFFB8CCE8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Building image placeholder
                  _buildingPlaceholder(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    color: _NC.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  article.excerpt,
                  style: const TextStyle(
                    color: _NC.grey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: const [
                          Text(
                            'Read More ',
                            style: TextStyle(
                              color: _NC.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: _NC.accent,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time, color: _NC.grey, size: 13),
                    const SizedBox(width: 4),
                    const Text(
                      '5 MINS READ',
                      style: TextStyle(
                        color: _NC.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildingPlaceholder() {
    return CustomPaint(painter: _BuildingPainter());
  }

  // ── Video card ────────────────────────────────────────────────────────────
  Widget _buildVideoCard(_NewsArticle article) {
    return Container(
      decoration: BoxDecoration(
        color: _NC.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFD8E8F0),
                  child: CustomPaint(painter: _MeetingPainter()),
                ),
                // Play button
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: _NC.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Edit/pencil FAB
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: _NC.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
                // Tag badge
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _NC.navy.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'EXCLUSIVE INTERVIEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Text(
              article.title,
              style: const TextStyle(
                color: _NC.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Compact (left-border) card ────────────────────────────────────────────
  Widget _buildCompactCard(_NewsArticle article, int index) {
    final isSaved = _saved.contains(index);
    return Container(
      decoration: BoxDecoration(
        color: _NC.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: article.leftBorderColor ?? _NC.accent,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _NC.tagNew,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _NC.navy,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Text(
                  article.tag,
                  style: const TextStyle(
                    color: _NC.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSaved) {
                      _saved.remove(index);
                    } else {
                      _saved.add(index);
                    }
                  });
                },
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _NC.grey,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            style: const TextStyle(
              color: _NC.navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article.excerpt,
            style: const TextStyle(color: _NC.grey, fontSize: 13, height: 1.5),
          ),
          if (article.timeAgo != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: _NC.grey, size: 13),
                const SizedBox(width: 4),
                Text(
                  article.timeAgo!,
                  style: const TextStyle(color: _NC.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────

class _BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sky);

    // Ground
    final ground = Paint()..color = const Color(0xFF6CA06C);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
      ground,
    );

    // Main building
    final bldg = Paint()..color = const Color(0xFFF0F0F0);
    final bldgRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bldgRect, const Radius.circular(4)),
      bldg,
    );

    // Windows
    final win = Paint()..color = const Color(0xFF4A90D9);
    const cols = 4;
    const rows = 5;
    final wW = bldgRect.width / (cols * 2 + 1);
    final wH = bldgRect.height / (rows * 2 + 1);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final wx = bldgRect.left + wW * (c * 2 + 1);
        final wy = bldgRect.top + wH * (r * 2 + 1);
        canvas.drawRect(Rect.fromLTWH(wx, wy, wW, wH), win);
      }
    }

    // Tree left
    final tree = Paint()..color = const Color(0xFF3A8A3A);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.68),
      size.width * 0.07,
      tree,
    );
    final trunk = Paint()..color = const Color(0xFF8B5E3C);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.087,
        size.height * 0.72,
        size.width * 0.025,
        size.height * 0.08,
      ),
      trunk,
    );

    // Tree right
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.67),
      size.width * 0.06,
      tree,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.868,
        size.height * 0.71,
        size.width * 0.022,
        size.height * 0.07,
      ),
      trunk,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MeetingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bg = Paint()..color = const Color(0xFFD0E4EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Table
    final table = Paint()..color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.45,
          size.width * 0.8,
          size.height * 0.2,
        ),
        const Radius.circular(8),
      ),
      table,
    );

    // People silhouettes
    final body = Paint()..color = const Color(0xFF555577);
    final head = Paint()..color = const Color(0xFFFFCBA4);

    // Person 1 (left)
    _drawPerson(
      canvas,
      size,
      size.width * 0.18,
      size.height * 0.35,
      body,
      head,
    );
    // Person 2 (center-left)
    _drawPerson(canvas, size, size.width * 0.38, size.height * 0.3, body, head);
    // Person 3 (center-right)
    _drawPerson(canvas, size, size.width * 0.58, size.height * 0.3, body, head);
    // Person 4 (right)
    _drawPerson(
      canvas,
      size,
      size.width * 0.78,
      size.height * 0.35,
      body,
      head,
    );
  }

  void _drawPerson(
    Canvas canvas,
    Size size,
    double x,
    double y,
    Paint body,
    Paint head,
  ) {
    final r = size.width * 0.035;
    canvas.drawCircle(Offset(x, y), r, head);
    final bodyPath = Path()
      ..moveTo(x - r * 0.8, y + r)
      ..lineTo(x + r * 0.8, y + r)
      ..lineTo(x + r * 0.6, y + r * 3.5)
      ..lineTo(x - r * 0.6, y + r * 3.5)
      ..close();
    canvas.drawPath(bodyPath, body);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
