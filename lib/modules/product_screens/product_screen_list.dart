import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:rojgar/modules/product_screens/our_product.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
class _Category {
  final int id;
  final String name;
  final String image;

  const _Category({required this.id, required this.name, required this.image});

  factory _Category.fromJson(Map<String, dynamic> json) {
    return _Category(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }
}

class _SubCategory {
  final int id;
  final String name;
  final String imageUrl;

  const _SubCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory _SubCategory.fromJson(Map<String, dynamic> json) {
    return _SubCategory(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class ProductScreenList extends StatefulWidget {
  const ProductScreenList({super.key});

  @override
  State<ProductScreenList> createState() => _ProductScreenListState();
}

class _ProductScreenListState extends State<ProductScreenList> {
  final Logger _logger = Logger();
  static const Color _primary = Color(0xFF1400FF);
  static const Color _scaffoldBg = Color(0xFFF5F6FA);

  List<_Category> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  int? _expandedCategoryId;
  Map<int, List<_SubCategory>> _subCategoryCache = {};
  Map<int, bool> _loadingSubCategories = {};
  Map<int, String?> _subCategoryErrors = {};

  int? _selectedCategoryId;
  int? _selectedSubCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });
    try {
      const url = 'https://rozgaradda.com/api/categories';
      _logger.i('── FETCH CATEGORIES REQUEST ──\nURL: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      _logger.i(
        '── FETCH CATEGORIES RESPONSE ──\n'
        'Status : ${response.statusCode}\n'
        'Body   : ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final data = (json['data'] as List)
              .map((e) => _Category.fromJson(e as Map<String, dynamic>))
              .toList();
          _logger.d(
            'Parsed ${data.length} categor(ies): ${data.map((c) => '[id=${c.id}, name=${c.name}]').join(', ')}',
          );
          setState(() {
            _categories = data;
            _isLoadingCategories = false;
          });
        } else {
          _logger.w('Categories API returned success=false: ${response.body}');
          setState(() {
            _categoriesError = 'Failed to load categories.';
            _isLoadingCategories = false;
          });
        }
      } else {
        _logger.e('Categories fetch failed with status ${response.statusCode}');
        setState(() {
          _categoriesError =
              'Server error (${response.statusCode}). Please try again.';
          _isLoadingCategories = false;
        });
      }
    } catch (e, st) {
      if (!mounted) return;
      _logger.e('Categories network error', error: e, stackTrace: st);
      setState(() {
        _categoriesError = 'Network error. Please check your connection.';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _fetchSubCategories(int categoryId) async {
    if (_subCategoryCache.containsKey(categoryId)) {
      _logger.d(
        'SubCategories cache hit for categoryId=$categoryId — skipping fetch.',
      );
      return;
    }

    setState(() {
      _loadingSubCategories[categoryId] = true;
      _subCategoryErrors[categoryId] = null;
    });

    try {
      final url = 'https://rozgaradda.com/api/subcategories/$categoryId';
      _logger.i(
        '── FETCH SUBCATEGORIES REQUEST ──\n'
        'URL        : $url\n'
        'categoryId : $categoryId',
      );

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      _logger.i(
        '── FETCH SUBCATEGORIES RESPONSE ──\n'
        'Status : ${response.statusCode}\n'
        'Body   : ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final data = (json['data'] as List)
              .map((e) => _SubCategory.fromJson(e as Map<String, dynamic>))
              .toList();
          _logger.d(
            'Parsed ${data.length} subcategor(ies) for categoryId=$categoryId: '
            '${data.map((s) => '[id=${s.id}, name=${s.name}]').join(', ')}',
          );
          setState(() {
            _subCategoryCache[categoryId] = data;
            _loadingSubCategories[categoryId] = false;
          });
        } else {
          _logger.w(
            'SubCategories API returned success=false: ${response.body}',
          );
          setState(() {
            _subCategoryErrors[categoryId] = 'Failed to load subcategories.';
            _loadingSubCategories[categoryId] = false;
          });
        }
      } else {
        _logger.e(
          'SubCategories fetch failed with status ${response.statusCode}',
        );
        setState(() {
          _subCategoryErrors[categoryId] =
              'Server error (${response.statusCode}).';
          _loadingSubCategories[categoryId] = false;
        });
      }
    } catch (e, st) {
      if (!mounted) return;
      _logger.e('SubCategories network error', error: e, stackTrace: st);
      setState(() {
        _subCategoryErrors[categoryId] = 'Network error.';
        _loadingSubCategories[categoryId] = false;
      });
    }
  }

  void _onCategoryTap(_Category category) {
    setState(() {
      if (_expandedCategoryId == category.id) {
        _logger.d(
          'Category collapsed: id=${category.id}, name="${category.name}"',
        );
        _expandedCategoryId = null;
      } else {
        _logger.i(
          '── CATEGORY TAPPED ──\n'
          'id   : ${category.id}\n'
          'name : "${category.name}"\n'
          'Fetching subcategories...',
        );
        _expandedCategoryId = category.id;
        _selectedCategoryId = category.id;
        _selectedSubCategoryId = null;
        _fetchSubCategories(category.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Category & Sub Category',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : _categoriesError != null
          ? _buildErrorState(_categoriesError!, _fetchCategories)
          : _categories.isEmpty
          ? const Center(child: Text('No categories found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isExpanded = _expandedCategoryId == category.id;
                final isSelected = _selectedCategoryId == category.id;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryTile(
                      category: category,
                      isSelected: isSelected,
                      isExpanded: isExpanded,
                      onTap: () => _onCategoryTap(category),
                    ),
                    if (isExpanded) _buildSubCategorySection(category.id),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSubCategorySection(int categoryId) {
    final isLoading = _loadingSubCategories[categoryId] == true;
    final error = _subCategoryErrors[categoryId];
    final subCategories = _subCategoryCache[categoryId];

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 12),
        child: _buildErrorState(
          error,
          () => setState(() {
            _subCategoryCache.remove(categoryId);
            _fetchSubCategories(categoryId);
          }),
          compact: true,
        ),
      );
    }

    if (subCategories == null || subCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 20, bottom: 12),
        child: Text(
          'No subcategories available.',
          style: TextStyle(color: Color(0xFF8A8FA3), fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4, bottom: 12),
      child: Column(
        children: subCategories.map((sub) {
          final isSelected = _selectedSubCategoryId == sub.id;
          return _SubCategoryTile(
            subCategory: sub,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedSubCategoryId = sub.id;
              });
              _logger.i(
                '── NAVIGATE TO OurProductScreen ──\n'
                'SubCategory : id=${sub.id}, name="${sub.name}"\n'
                'Category    : id=$categoryId\n'
                'API body    : {"category_id": ${sub.id}}',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OurProductScreen(
                    title: sub.name,
                    categoryId: categoryId,
                    subcategoryId: sub.id,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    VoidCallback onRetry, {
    bool compact = false,
  }) {
    if (compact) {
      return Row(
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: Color(0xFF8A8FA3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8A8FA3), fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY TILE
// ─────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final _Category category;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EAFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1400FF)
                : const Color(0xFFE5E7F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: category.image.isNotEmpty
                  ? Image.network(
                      category.image,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackIcon(isSelected),
                    )
                  : _fallbackIcon(isSelected),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: isSelected
                  ? const Color(0xFF1400FF)
                  : const Color(0xFF8A8FA3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon(bool isSelected) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1400FF).withOpacity(0.12)
            : const Color(0xFFF1F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.category_rounded,
        color: isSelected ? const Color(0xFF1400FF) : const Color(0xFF4B5563),
        size: 26,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUBCATEGORY TILE
// ─────────────────────────────────────────────
class _SubCategoryTile extends StatelessWidget {
  final _SubCategory subCategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryTile({
    required this.subCategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1400FF).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1400FF)
                : const Color(0xFFE5E7F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: subCategory.imageUrl.isNotEmpty
                  ? Image.network(
                      subCategory.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _fallbackSubIcon(isSelected),
                    )
                  : _fallbackSubIcon(isSelected),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subCategory.name,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1400FF)
                      : const Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isSelected
                  ? const Color(0xFF1400FF)
                  : const Color(0xFF8A8FA3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackSubIcon(bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1400FF).withOpacity(0.1)
            : const Color(0xFFF1F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.subdirectory_arrow_right_rounded,
        size: 20,
        color: isSelected ? const Color(0xFF1400FF) : const Color(0xFF8A8FA3),
      ),
    );
  }
}
