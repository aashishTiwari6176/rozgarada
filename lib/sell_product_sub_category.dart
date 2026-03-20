import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rojgar/sell_product_form.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class SubCategory {
  final int id;
  final String name;
  final String imageUrl;

  const SubCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class SellProductSubCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SellProductSubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SellProductSubCategoryScreen> createState() =>
      _SellProductSubCategoryScreenState();
}

class _SellProductSubCategoryScreenState
    extends State<SellProductSubCategoryScreen> {
  int? _selectedIndex;
  final List<SubCategory> _subCategories = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://rozgaradda.com/api/subcategories/${widget.categoryId}',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = (decoded['data'] as List?) ?? <dynamic>[];

        setState(() {
          _subCategories
            ..clear()
            ..addAll(
              data.map(
                (item) => SubCategory.fromJson(item as Map<String, dynamic>),
              ),
            );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Unable to load sub-categories.';
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Unable to load sub-categories.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: Column(
        children: [
          _TopBar(),
          _StepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.chevron_left_rounded,
                            color: _C.primaryBlue,
                            size: 22,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'BACK',
                            style: TextStyle(
                              color: _C.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    'SELECT SUB CATEGORY',
                    style: TextStyle(
                      color: _C.darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Selected category banner
                  _SelectedCategoryBanner(
                    categoryName: widget.categoryName,
                    onChangeTap: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: 20),

                  // Grid
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                            onPressed: _fetchSubCategories,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (_subCategories.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, i) => _SubCategoryCard(
                        subCategory: _subCategories[i],
                        isSelected: _selectedIndex == i,
                        onTap: () => setState(() => _selectedIndex = i),
                      ),
                    ),
                  if (!_isLoading && _error == null && _subCategories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No sub-categories found',
                        style: TextStyle(color: _C.greyText, fontSize: 14),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Hint
                  const Center(
                    child: Text(
                      'Choose the most relevant sub-category for your\nadvertisement to reach more buyers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _C.greyText,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _NextButton(
        enabled: _selectedIndex != null,
        onTap: _selectedIndex != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellProductFormScreen(
                      categoryId: widget.categoryId,
                      subCategoryId: _subCategories[_selectedIndex!].id,
                      categoryName: widget.categoryName,
                      subCategoryName: _subCategories[_selectedIndex!].name,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.primaryBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'POST YOUR AD',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP INDICATOR
// ─────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _StepCircle(number: 1, label: 'CATEGORY', state: _StepState.done),
          _StepLine(active: true),
          _StepCircle(
            number: 2,
            label: 'SUB CATEGORY',
            state: _StepState.active,
          ),
          _StepLine(active: false),
          _StepCircle(number: 3, label: 'DETAILS', state: _StepState.inactive),
        ],
      ),
    );
  }
}

enum _StepState { done, active, inactive }

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final _StepState state;

  const _StepCircle({
    required this.number,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = state == _StepState.done;
    final bool isActive = state == _StepState.active;

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isActive)
                ? _C.primaryBlue
                : const Color(0xFFE8E8F0),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive ? Colors.white : _C.greyText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: (isDone || isActive) ? _C.primaryBlue : _C.greyText,
            fontSize: 9,
            fontWeight: (isDone || isActive)
                ? FontWeight.w700
                : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? _C.primaryBlue : const Color(0xFFDDDDEE),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SELECTED CATEGORY BANNER
// ─────────────────────────────────────────────
class _SelectedCategoryBanner extends StatelessWidget {
  final String categoryName;
  final VoidCallback onChangeTap;

  const _SelectedCategoryBanner({
    required this.categoryName,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDDEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Category: $categoryName',
                  style: const TextStyle(
                    color: _C.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'You can change this by going back',
                  style: TextStyle(color: _C.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onChangeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _C.darkText,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'CHANGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUB-CATEGORY CARD
// ─────────────────────────────────────────────
class _SubCategoryCard extends StatelessWidget {
  final SubCategory subCategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryCard({
    required this.subCategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _C.primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with NEW badge
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    subCategory.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFEEEEF8),
                      child: const Icon(
                        Icons.image_rounded,
                        color: Color(0xFFAAAAAA),
                        size: 40,
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFEEEEF8),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _C.primaryBlue,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Name + arrow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      subCategory.name,
                      style: TextStyle(
                        color: _C.darkText,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isSelected ? _C.primaryBlue : _C.greyText,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NEXT BUTTON
// ─────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _NextButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? _C.yellow : const Color(0xFFEEEE99),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: const Text(
            'NEXT',
            style: TextStyle(
              color: _C.darkText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
