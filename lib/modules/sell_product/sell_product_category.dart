import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rojgar/sell_product_sub_category.dart';

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
  static const Color iconBg = Color(0xFFEEEEF8);
  static const Color selectedIconBg = Color(0xFFE8EAFF);
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class ProductCategory {
  final String name;
  final String subtitle;
  final IconData icon;

  const ProductCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}

class productcategory {
  bool? success;
  List<Data>? data;

  productcategory({this.success, this.data});

  productcategory.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? image;

  Data({this.id, this.name, this.image});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class SellProductCategoryScreen extends StatefulWidget {
  const SellProductCategoryScreen({super.key});

  @override
  State<SellProductCategoryScreen> createState() =>
      _SellProductCategoryScreenState();
}

class _SellProductCategoryScreenState extends State<SellProductCategoryScreen> {
  final List<Data> _apiCategories = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedIndex;

  Future<void> getProductCategory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://rozgaradda.com/api/categories'),
      );

      if (response.statusCode == 200) {
        final result = productcategory.fromJson(jsonDecode(response.body));

        setState(() {
          _apiCategories
            ..clear()
            ..addAll(result.data ?? <Data>[]);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Unable to load categories.';
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Unable to load categories.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProductCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: Column(
        children: [
          _TopBar(),
          _StepIndicator(currentStep: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: getProductCategory,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (_apiCategories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No categories found',
                        style: TextStyle(color: _C.greyText),
                      ),
                    )
                  else
                    ...List.generate(_apiCategories.length, (i) {
                      final item = _apiCategories[i];
                      return _CategoryTile(
                        category: ProductCategory(
                          name: item.name ?? '',
                          subtitle: '',
                          icon: Icons.category,
                        ),
                        isSelected: _selectedIndex == i,
                        onTap: () {
                          setState(() => _selectedIndex = i);
                          Future.delayed(const Duration(milliseconds: 180), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SellProductSubCategoryScreen(
                                categoryId: item.id ?? 0,
                                  categoryName: item.name ?? '',
                                ),
                              ),
                            );
                          });
                        },
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _NextButton(
        enabled: _selectedIndex != null && _apiCategories.isNotEmpty,
        onTap: _selectedIndex != null && _apiCategories.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellProductSubCategoryScreen(
                      categoryId: _apiCategories[_selectedIndex!].id ?? 0,
                      categoryName: _apiCategories[_selectedIndex!].name ?? '',
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
            child: const Icon(Icons.add, color: Colors.white, size: 26),
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
            child: const Icon(Icons.close, color: Colors.white, size: 26),
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
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _StepCircle(number: 1, label: 'CATEGORY', active: currentStep >= 1),
          _StepLine(active: currentStep >= 2),
          _StepCircle(
            number: 2,
            label: 'SUB CATEGORY',
            active: currentStep >= 2,
          ),
          _StepLine(active: currentStep >= 3),
          _StepCircle(number: 3, label: 'DETAILS', active: currentStep >= 3),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final bool active;

  const _StepCircle({
    required this.number,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? _C.primaryBlue : const Color(0xFFE8E8F0),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: active ? Colors.white : _C.greyText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? _C.primaryBlue : _C.greyText,
            fontSize: 9,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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
// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHOOSE A CATEGORY',
          style: TextStyle(
            color: _C.primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: _C.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY TILE
// ─────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final ProductCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _C.primaryBlue : Colors.transparent,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? _C.selectedIconBg : _C.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category.icon,
                color: isSelected ? _C.primaryBlue : const Color(0xFF5A6070),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: _C.darkText,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isSelected ? _C.primaryBlue : _C.greyText,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NEXT BUTTON (bottom sheet)
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
