import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AC {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color darkText = Color(0xFF111111);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color lightGrey = Color(0xFFE4E4E4);
  static const Color scaffoldBg = Color(0xFFFFFFFF);
  static const Color searchBg = Color(0xFFF4F4F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color hindiBlue = Color(0xFF1400FF);
}

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────
class StateItem {
  final String english;
  final String hindi;
  // Currently unused on this page.
  // final String imagePlaceholder;
  // final Color landmarkColor;

  const StateItem({
    required this.english,
    required this.hindi,
    // required this.imagePlaceholder,
    // required this.landmarkColor,
  });
}

const List<StateItem> kStates = [
  StateItem(
    english: 'Uttar Pradesh',
    hindi: 'उत्तर प्रदेश',
    // imagePlaceholder: 'taj',
    // landmarkColor: Color(0xFF87CEEB),
  ),
  StateItem(
    english: 'Maharashtra',
    hindi: 'महाराष्ट्र',
    // imagePlaceholder: 'gateway',
    // landmarkColor: Color(0xFF6B9BD2),
  ),
  StateItem(
    english: 'Bihar',
    hindi: 'बिहार',
    // imagePlaceholder: 'nalanda',
    // landmarkColor: Color(0xFFC8860A),
  ),
  StateItem(
    english: 'Rajasthan',
    hindi: 'राजस्थान',
    // imagePlaceholder: 'hawa',
    // landmarkColor: Color(0xFFE8A95C),
  ),
  StateItem(
    english: 'West Bengal',
    hindi: 'पश्चिम बंगाल',
    // imagePlaceholder: 'victoria',
    // landmarkColor: Color(0xFF4A8C5C),
  ),
  StateItem(
    english: 'Madhya Pradesh',
    hindi: 'मध्य प्रदेश',
    // imagePlaceholder: 'khajuraho',
    // landmarkColor: Color(0xFF8B6914),
  ),
];

class ApiState {
  final int id;
  final String name;
  final String language;
  final String imageUrl;

  const ApiState({
    required this.id,
    required this.name,
    required this.language,
    required this.imageUrl,
  });

  factory ApiState.fromJson(Map<String, dynamic> json) {
    return ApiState(
      id: (json['s_id'] ?? 0) is int
          ? json['s_id'] as int
          : int.tryParse(json['s_id'].toString()) ?? 0,
      name: (json['s_name'] ?? '').toString(),
      language: (json['s_language'] ?? '').toString(),
      imageUrl: (json['s_image'] ?? '').toString(),
    );
  }
}

const String kStatesEndpoint = 'https://rozgaradda.com/api/states-images';

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class SelectStateScreen extends StatefulWidget {
  const SelectStateScreen({super.key, this.successMessage});

  final String? successMessage;

  @override
  State<SelectStateScreen> createState() => _SelectStateScreenState();
}

class _SelectStateScreenState extends State<SelectStateScreen> {
  final List<ApiState> _states = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedStateId;

  @override
  void initState() {
    super.initState();
    _fetchStates();
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginSuccessDialog(widget.successMessage!);
      });
    }
  }

  void _showLoginSuccessDialog(String username) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Login Successful'),
          content: Text(
            'You logged in successfully with this email: $username',
          ),
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

  Future<void> _fetchStates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(kStatesEndpoint));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = (decoded['data'] as List?) ?? <dynamic>[];

        final fetchedStates = data
            .map((e) => ApiState.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _states
            ..clear()
            ..addAll(fetchedStates);
          _isLoading = false;
          if (_states.isNotEmpty) {
            _selectedStateId = _states.first.id;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Unable to load states. Please try again.';
        });
        // _loadFallbackStates();
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Unable to load states. Please check your connection.';
      });
      // _loadFallbackStates();
    }
  }

  /*
  // Dummy fallback data is intentionally disabled on this screen.
  void _loadFallbackStates() {
    if (_states.isNotEmpty) return;

    final fallback = <ApiState>[];
    for (var i = 0; i < kStates.length; i++) {
      final s = kStates[i];
      fallback.add(
        ApiState(id: i + 1, name: s.english, language: s.hindi, imageUrl: ''),
      );
    }

    setState(() {
      _states
        ..clear()
        ..addAll(fallback);
      if (_states.isNotEmpty) {
        _selectedStateId = _states.first.id;
      }
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.045;
    final l10n = context.l10n;
    final filteredStates = _searchQuery.isEmpty
        ? _states
        : _states.where((s) {
            final q = _searchQuery.toLowerCase();
            return s.name.toLowerCase().contains(q) ||
                s.language.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: AC.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AC.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AC.darkText, size: 24),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        centerTitle: true,
        title: Text(
          l10n.text('select_state_appbar'),
          style: const TextStyle(
            color: AC.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AC.lightGrey),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // ── Progress row ──────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.text('select_state_step_label'),
                        style: const TextStyle(
                          color: AC.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        l10n.text('select_state_progress'),
                        style: const TextStyle(
                          color: AC.greyText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: AC.lightGrey,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.66,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AC.yellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Heading ───────────────────
                  Text(
                    l10n.text('select_state_heading'),
                    style: const TextStyle(
                      color: AC.darkText,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    l10n.text('select_state_subheading'),
                    style: const TextStyle(
                      color: AC.greyText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 22),

                  // ── Search ────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AC.searchBg,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AC.lightGrey, width: 1.2),
                    ),
                    child: TextField(
                      style: const TextStyle(color: AC.darkText, fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: l10n.text('select_state_search_hint'),
                        hintStyle: const TextStyle(
                          color: AC.greyText,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AC.greyText,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── State list (from API) ─────
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: AC.primaryBlue),
                      ),
                    )
                  else if (_error != null && _states.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _fetchStates,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (filteredStates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'No states found',
                        style: TextStyle(color: AC.greyText, fontSize: 14),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStates.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final state = filteredStates[index];
                        final selected = state.id == _selectedStateId;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedStateId = state.id),
                          child: _StateCard(state: state, selected: selected),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Continue Button ────────────────
          Container(
            color: AC.scaffoldBg,
            padding: EdgeInsets.fromLTRB(
              hPad,
              12,
              hPad,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AC.primaryBlue,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AC.primaryBlue.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _showLanguageDialogAndContinue(context, _selectedStateId);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.text('continue'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showLanguageDialogAndContinue(
  BuildContext context,
  int? selectedStateId,
) async {
  final l10n = context.l10n;
  final currentCode = Localizations.localeOf(context).languageCode;
  String selectedCode = currentCode == 'hi' ? 'hi' : 'en';

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.text('language_dialog_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.text('language_dialog_message')),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text(l10n.text('language_english')),
                      value: 'en',
                      groupValue: selectedCode,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => selectedCode = v);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.text('language_hindi')),
                      value: 'hi',
                      groupValue: selectedCode,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => selectedCode = v);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final locale = Locale(selectedCode);
              final appState = MyApp.of(context);
              await appState?.setLocale(locale);
              if (selectedStateId != null) {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('selected_state_id', selectedStateId);
                } catch (_) {
                  // ignore write errors
                }
              }
              if (context.mounted) {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FloatingNavbarScreen(),
                  ),
                );
              }
            },
            child: Text(l10n.text('continue')),
          ),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────
// STATE CARD
// ─────────────────────────────────────────────
class _StateCard extends StatelessWidget {
  final ApiState state;
  final bool selected;

  const _StateCard({required this.state, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 80,
      decoration: BoxDecoration(
        color: AC.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AC.yellow : AC.lightGrey,
          width: selected ? 2.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: SizedBox(
              width: 80,
              height: 80,
              child: state.imageUrl.isEmpty
                  ? const _LandmarkIllustration(
                      stateKey: 'taj',
                      skyColor: AC.primaryBlue,
                    )
                  : Image.network(
                      state.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const _LandmarkIllustration(
                          stateKey: 'gateway',
                          skyColor: AC.primaryBlue,
                        );
                      },
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AC.darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.language,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AC.hindiBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AC.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LANDMARK ILLUSTRATION (CustomPainter per state)
// ─────────────────────────────────────────────
class _LandmarkIllustration extends StatelessWidget {
  final String stateKey;
  final Color skyColor;

  const _LandmarkIllustration({required this.stateKey, required this.skyColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _LandmarkPainter(stateKey: stateKey, skyColor: skyColor),
      ),
    );
  }
}

class _LandmarkPainter extends CustomPainter {
  final String stateKey;
  final Color skyColor;

  const _LandmarkPainter({required this.stateKey, required this.skyColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Sky background
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyColor, skyColor.withOpacity(0.7)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    switch (stateKey) {
      case 'taj':
        _drawTaj(canvas, size);
        break;
      case 'gateway':
        _drawGateway(canvas, size);
        break;
      // Currently unused on this page.
      // case 'nalanda':
      //   _drawNalanda(canvas, size);
      //   break;
      // case 'hawa':
      //   _drawHawa(canvas, size);
      //   break;
      // case 'victoria':
      //   _drawVictoria(canvas, size);
      //   break;
      // case 'khajuraho':
      //   _drawKhajuraho(canvas, size);
      //   break;
    }
  }

  // ── TAJ MAHAL ──
  void _drawTaj(Canvas canvas, Size s) {
    final p = Paint()..color = const Color(0xFFF5F0E8);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28),
      Paint()..color = const Color(0xFF90C878),
    );

    // Reflecting pool
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.35,
          s.height * 0.6,
          s.width * 0.3,
          s.height * 0.12,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF7ABCE0),
    );

    // Main dome
    final domePath = Path();
    domePath.moveTo(s.width * 0.3, s.height * 0.6);
    domePath.lineTo(s.width * 0.3, s.height * 0.42);
    domePath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.18,
      s.width * 0.7,
      s.height * 0.42,
    );
    domePath.lineTo(s.width * 0.7, s.height * 0.6);
    domePath.close();
    canvas.drawPath(domePath, p);

    // Small dome top spire
    canvas.drawLine(
      Offset(s.width * 0.5, s.height * 0.18),
      Offset(s.width * 0.5, s.height * 0.08),
      Paint()
        ..color = const Color(0xFFF5F0E8)
        ..strokeWidth = 2.5,
    );

    // Side minarets
    for (final x in [s.width * 0.12, s.width * 0.88]) {
      final mRect = Rect.fromLTWH(
        x - s.width * 0.04,
        s.height * 0.32,
        s.width * 0.08,
        s.height * 0.3,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(mRect, const Radius.circular(4)),
        p,
      );
      // Minaret dome
      final mp = Path();
      mp.moveTo(x - s.width * 0.04, s.height * 0.32);
      mp.quadraticBezierTo(
        x,
        s.height * 0.2,
        x + s.width * 0.04,
        s.height * 0.32,
      );
      mp.close();
      canvas.drawPath(mp, p);
    }

    // Trees
    final treePaint = Paint()..color = const Color(0xFF2D7A3A);
    for (final tx in [
      s.width * 0.1,
      s.width * 0.22,
      s.width * 0.78,
      s.width * 0.9,
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(tx - 3, s.height * 0.55, 6, s.height * 0.18),
        treePaint,
      );
      canvas.drawOval(
        Rect.fromLTWH(tx - 8, s.height * 0.44, 16, s.height * 0.14),
        treePaint,
      );
    }
  }

  // ── GATEWAY OF INDIA ──
  void _drawGateway(Canvas canvas, Size s) {
    final stone = Paint()..color = const Color(0xFFD4A96A);
    final dark = Paint()..color = const Color(0xFF8B6914);

    // Water
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
      Paint()..color = const Color(0xFF4A90D9),
    );

    // Base platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.1,
          s.height * 0.7,
          s.width * 0.8,
          s.height * 0.1,
        ),
        const Radius.circular(2),
      ),
      stone,
    );

    // Main arch
    final archPath = Path();
    archPath.moveTo(s.width * 0.22, s.height * 0.7);
    archPath.lineTo(s.width * 0.22, s.height * 0.44);
    archPath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.22,
      s.width * 0.78,
      s.height * 0.44,
    );
    archPath.lineTo(s.width * 0.78, s.height * 0.7);
    canvas.drawPath(archPath, stone);

    // Arch opening
    final openPath = Path();
    openPath.moveTo(s.width * 0.32, s.height * 0.7);
    openPath.lineTo(s.width * 0.32, s.height * 0.5);
    openPath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.35,
      s.width * 0.68,
      s.height * 0.5,
    );
    openPath.lineTo(s.width * 0.68, s.height * 0.7);
    canvas.drawPath(openPath, Paint()..color = skyColor.withOpacity(0.9));

    // Side towers
    for (final tx in [s.width * 0.12, s.width * 0.80]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx, s.height * 0.44, s.width * 0.08, s.height * 0.28),
          const Radius.circular(3),
        ),
        stone,
      );
      // Tower dome
      final td = Path();
      td.moveTo(tx, s.height * 0.44);
      td.quadraticBezierTo(
        tx + s.width * 0.04,
        s.height * 0.32,
        tx + s.width * 0.08,
        s.height * 0.44,
      );
      td.close();
      canvas.drawPath(td, dark);
    }
  }

  /*
  // ── NALANDA (Bihar) ──
  // Currently unused on this page.
  void _drawNalanda(Canvas canvas, Size s) {
    final brick = Paint()..color = const Color(0xFFB5651D);
    final dark = Paint()..color = const Color(0xFF8B4513);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28),
      Paint()..color = const Color(0xFFD2A679),
    );

    // Steps
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          s.width * (0.1 + i * 0.025),
          s.height * (0.72 - i * 0.04),
          s.width * (0.8 - i * 0.05),
          s.height * 0.04,
        ),
        brick,
      );
    }

    // Main structure
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.2,
          s.height * 0.36,
          s.width * 0.6,
          s.height * 0.36,
        ),
        const Radius.circular(4),
      ),
      brick,
    );

    // Arched openings
    for (int i = 0; i < 3; i++) {
      final ax = s.width * (0.26 + i * 0.18);
      final archP = Path();
      archP.moveTo(ax, s.height * 0.72);
      archP.lineTo(ax, s.height * 0.56);
      archP.quadraticBezierTo(
        ax + s.width * 0.07,
        s.height * 0.46,
        ax + s.width * 0.14,
        s.height * 0.56,
      );
      archP.lineTo(ax + s.width * 0.14, s.height * 0.72);
      archP.close();
      canvas.drawPath(archP, dark);
    }

    // Top decorative row
    canvas.drawRect(
      Rect.fromLTWH(
        s.width * 0.18,
        s.height * 0.3,
        s.width * 0.64,
        s.height * 0.06,
      ),
      dark,
    );
  }
  */

  /*
  // ── HAWA MAHAL (Rajasthan) ──
  // Currently unused on this page.
  void _drawHawa(Canvas canvas, Size s) {
    final pink = Paint()..color = const Color(0xFFE8836A);
    final dark = Paint()..color = const Color(0xFFC0603A);
    final window = Paint()..color = const Color(0xFF8B4513);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
      Paint()..color = const Color(0xFFDEB887),
    );

    // Main facade
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.08,
          s.height * 0.22,
          s.width * 0.84,
          s.height * 0.56,
        ),
        const Radius.circular(2),
      ),
      pink,
    );

    // Rows of windows/arches
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        final wx = s.width * (0.14 + col * 0.155);
        final wy = s.height * (0.3 + row * 0.12);
        final archW = s.width * 0.1;
        final archH = s.height * 0.09;

        final wp = Path();
        wp.moveTo(wx, wy + archH);
        wp.lineTo(wx, wy + archH * 0.4);
        wp.quadraticBezierTo(wx + archW / 2, wy, wx + archW, wy + archH * 0.4);
        wp.lineTo(wx + archW, wy + archH);
        wp.close();
        canvas.drawPath(wp, dark);
        canvas.drawPath(
          wp,
          window
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }

    // Top decorative kiosks
    for (int i = 0; i < 5; i++) {
      final kx = s.width * (0.12 + i * 0.16);
      final kp = Path();
      kp.moveTo(kx, s.height * 0.22);
      kp.quadraticBezierTo(
        kx + s.width * 0.07,
        s.height * 0.1,
        kx + s.width * 0.14,
        s.height * 0.22,
      );
      kp.close();
      canvas.drawPath(kp, dark);
    }
  }
  */

  /*
  // ── VICTORIA MEMORIAL (West Bengal) ──
  // Currently unused on this page.
  void _drawVictoria(Canvas canvas, Size s) {
    final white = Paint()..color = const Color(0xFFF8F4EC);
    final grey = Paint()..color = const Color(0xFFD0C8B8);

    // Garden
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.7, s.width, s.height * 0.3),
      Paint()..color = const Color(0xFF5A9E5A),
    );

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.08,
          s.height * 0.6,
          s.width * 0.84,
          s.height * 0.12,
        ),
        const Radius.circular(3),
      ),
      white,
    );

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.18,
          s.height * 0.38,
          s.width * 0.64,
          s.height * 0.24,
        ),
        const Radius.circular(4),
      ),
      white,
    );

    // Central dome
    final domePath = Path();
    domePath.moveTo(s.width * 0.32, s.height * 0.38);
    domePath.lineTo(s.width * 0.32, s.height * 0.28);
    domePath.quadraticBezierTo(
      s.width * 0.5,
      s.height * 0.12,
      s.width * 0.68,
      s.height * 0.28,
    );
    domePath.lineTo(s.width * 0.68, s.height * 0.38);
    domePath.close();
    canvas.drawPath(domePath, white);

    // Dome spire
    canvas.drawLine(
      Offset(s.width * 0.5, s.height * 0.12),
      Offset(s.width * 0.5, s.height * 0.04),
      Paint()
        ..color = const Color(0xFFD4C090)
        ..strokeWidth = 2,
    );

    // Side towers
    for (final tx in [s.width * 0.14, s.width * 0.78]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx, s.height * 0.46, s.width * 0.08, s.height * 0.16),
          const Radius.circular(3),
        ),
        white,
      );
      final td = Path();
      td.moveTo(tx, s.height * 0.46);
      td.quadraticBezierTo(
        tx + s.width * 0.04,
        s.height * 0.36,
        tx + s.width * 0.08,
        s.height * 0.46,
      );
      td.close();
      canvas.drawPath(td, grey);
    }

    // Trees
    final treePaint = Paint()..color = const Color(0xFF2D5A2D);
    for (final tx in [s.width * 0.04, s.width * 0.92]) {
      canvas.drawRect(
        Rect.fromLTWH(tx - 3, s.height * 0.58, 6, s.height * 0.14),
        treePaint,
      );
      canvas.drawOval(
        Rect.fromLTWH(tx - 12, s.height * 0.46, 24, s.height * 0.15),
        treePaint,
      );
    }
  }
  */

  /*
  // ── KHAJURAHO (MP) ──
  // Currently unused on this page.
  void _drawKhajuraho(Canvas canvas, Size s) {
    final sand = Paint()..color = const Color(0xFFD4AA70);
    final dark = Paint()..color = const Color(0xFF8B6914);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
      Paint()..color = const Color(0xFFB8985A),
    );

    // Base platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.06,
          s.height * 0.7,
          s.width * 0.88,
          s.height * 0.1,
        ),
        const Radius.circular(2),
      ),
      sand,
    );

    // Temple shikhara (spire)
    void drawShikhara(double cx, double baseY, double w, double h) {
      for (int i = 0; i < 5; i++) {
        final ratio = 1.0 - i * 0.16;
        final rx = cx - (w * ratio) / 2;
        final ry = baseY - i * (h / 5);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(rx, ry, w * ratio, h / 5),
            const Radius.circular(2),
          ),
          i.isEven ? sand : dark,
        );
      }
      // Spire tip
      final tipPath = Path();
      tipPath.moveTo(cx - w * 0.08, baseY - h);
      tipPath.quadraticBezierTo(cx, baseY - h * 1.2, cx + w * 0.08, baseY - h);
      tipPath.close();
      canvas.drawPath(tipPath, dark);
    }

    drawShikhara(
      s.width * 0.5,
      s.height * 0.7,
      s.width * 0.38,
      s.height * 0.48,
    );
    drawShikhara(s.width * 0.2, s.height * 0.7, s.width * 0.2, s.height * 0.3);
    drawShikhara(s.width * 0.8, s.height * 0.7, s.width * 0.2, s.height * 0.3);

    // Decorative band
    canvas.drawRect(
      Rect.fromLTWH(
        s.width * 0.06,
        s.height * 0.66,
        s.width * 0.88,
        s.height * 0.04,
      ),
      dark,
    );
  }
  */

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
