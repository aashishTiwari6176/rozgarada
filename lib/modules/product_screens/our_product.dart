import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:rojgar/modules/product_screens/product_detailscreen.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color priceGreen = Color(0xFF1E9E5E);
  static const Color discountRed = Color(0xFFDD0000);
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class ApiProduct {
  final int id;
  final String title;
  final String description;
  final String metaImage;
  final List<String> galleryImages;
  final double price;
  final double discount;
  final double totalCost;
  final String features;
  final String warranty;

  const ApiProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.metaImage,
    required this.galleryImages,
    required this.price,
    required this.discount,
    required this.totalCost,
    required this.features,
    required this.warranty,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    final rawGallery = json['gallery_images'];
    final List<String> gallery = rawGallery is List
        ? rawGallery.map((e) => e.toString()).toList()
        : [];

    return ApiProduct(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      metaImage: (json['meta_image'] ?? '').toString(),
      galleryImages: gallery,
      price: parseDouble(json['price']),
      discount: parseDouble(json['discount']),
      totalCost: parseDouble(json['total_cost']),
      features: (json['features'] ?? '').toString(),
      warranty: (json['warranty'] ?? '').toString(),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class OurProductScreen extends StatefulWidget {
  final String? title;
  final int? categoryId;
  final int? subcategoryId;

  const OurProductScreen({
    super.key,
    this.title,
    this.categoryId,
    this.subcategoryId,
  });

  @override
  State<OurProductScreen> createState() => _OurProductScreenState();
}

class _OurProductScreenState extends State<OurProductScreen> {
  final Logger _logger = Logger();
  List<ApiProduct> _products = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      const url = 'https://rozgaradda.com/api/get-products';

      // When subcategoryId is provided, pass it as category_id (API field name)
      // When only categoryId is provided, pass category_id
      final Map<String, dynamic> body = widget.subcategoryId != null
          ? {'category_id': widget.subcategoryId}
          : {'category_id': widget.categoryId};

      final encodedBody = jsonEncode(body);

      _logger.i(
        '── GET PRODUCTS REQUEST ──\n'
        'URL    : $url\n'
        'Body   : $encodedBody\n'
        '(subcategoryId=${widget.subcategoryId}, categoryId=${widget.categoryId})',
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      _logger.i(
        '── GET PRODUCTS RESPONSE ──\n'
        'Status : ${response.statusCode}\n'
        'Body   : ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final data = (json['data'] as List)
              .map((e) => ApiProduct.fromJson(e as Map<String, dynamic>))
              .toList();
          _logger.d('Parsed ${data.length} product(s).');
          setState(() {
            _products = data;
            _isLoading = false;
          });
        } else {
          _logger.w('API returned success=false: ${response.body}');
          setState(() {
            _error = 'No products found.';
            _isLoading = false;
          });
        }
      } else {
        _logger.e('Unexpected status ${response.statusCode}: ${response.body}');
        setState(() {
          _error = 'Server error (${response.statusCode}). Please try again.';
          _isLoading = false;
        });
      }
    } catch (e, st) {
      if (!mounted) return;
      _logger.e('Network/parse error', error: e, stackTrace: st);
      setState(() {
        _error = 'Network error. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _C.darkText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          _Header(title: widget.title),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 52,
                color: Color(0xFF8A8FA3),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8A8FA3), fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
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

    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 52, color: Color(0xFF8A8FA3)),
              SizedBox(height: 12),
              Text(
                'No products available in this category.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8A8FA3), fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 14,
          childAspectRatio: 0.52,
        ),
        itemBuilder: (context, i) => _ProductCard(product: _products[i]),
      ),
    );
  }
}

// HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String? title;
  const _Header({this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        children: [
          Text(
            title != null ? '$title Products' : 'Our Products',
            style: const TextStyle(
              color: _C.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Browse through our wide range of products',
            style: TextStyle(color: _C.greyText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT CARD
// ─────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ApiProduct product;
  const _ProductCard({required this.product});

  String _formatPrice(double price) {
    return '₹${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: product.metaImage.isNotEmpty
                      ? Image.network(
                          product.metaImage,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _PlaceholderImage(),
                        )
                      : _PlaceholderImage(),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _C.discountRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discount.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Content ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.greyText,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Discounted price
                  Text(
                    _formatPrice(product.totalCost),
                    style: const TextStyle(
                      color: _C.priceGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        color: _C.greyText,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _openDetail(context),
                      child: const Text('View Details'),
                    ),
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
// PLACEHOLDER IMAGE
// ─────────────────────────────────────────────
class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      color: const Color(0xFFEEEFF5),
      child: const Icon(
        Icons.image_outlined,
        size: 48,
        color: Color(0xFFBBBBCC),
      ),
    );
  }
}
