import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _DC {
  static const Color primary = Color(0xFF1400FF);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color strikePrice = Color(0xFF9A9A9A);
  static const Color saveBadgeBg = Color(0xFFDD0000);
  static const Color offBadgeBg = Color(0xFFDD0000);
  static const Color divider = Color(0xFFEEEFF5);
  static const Color greenCheck = Color(0xFF1E9E5E);
  static const Color priceGreen = Color(0xFF1E9E5E);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
class _ProductData {
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
  final String capacity;

  const _ProductData({
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
    required this.capacity,
  });

  factory _ProductData.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    final rawGallery = json['gallery_images'];
    final List<String> gallery = rawGallery is List
        ? rawGallery.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : [];

    return _ProductData(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      metaImage: (json['meta_image'] ?? '').toString(),
      galleryImages: gallery,
      price: _d(json['price']),
      discount: _d(json['discount']),
      totalCost: _d(json['total_cost']),
      features: (json['features'] ?? '').toString(),
      warranty: (json['warranty'] ?? '').toString(),
      capacity: (json['capacity'] ?? '').toString(),
    );
  }

  List<String> get allImages => [
        if (metaImage.isNotEmpty) metaImage,
        ...galleryImages,
      ];

  List<String> get featureList {
    final list = features
        .split(',')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();
    return list.isEmpty && features.isNotEmpty ? [features] : list;
  }
}

class _RelatedProduct {
  final int id;
  final String title;
  final String description;
  final String metaImage;
  final double price;
  final double discount;
  final double totalCost;

  const _RelatedProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.metaImage,
    required this.price,
    required this.discount,
    required this.totalCost,
  });

  factory _RelatedProduct.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    return _RelatedProduct(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      metaImage: (json['meta_image'] ?? '').toString(),
      price: _d(json['price']),
      discount: _d(json['discount']),
      totalCost: _d(json['total_cost']),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  _ProductData? _product;
  List<_RelatedProduct> _relatedProducts = [];
  bool _isLoading = false;
  String? _error;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedImageIndex = 0;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://rozgaradda.com/api/product-details/${widget.productId}',
            ),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final product = _ProductData.fromJson(
            json['data'] as Map<String, dynamic>,
          );

          final rawRelated = json['related_products'];
          final related = rawRelated is List
              ? rawRelated
                  .map((e) =>
                      _RelatedProduct.fromJson(e as Map<String, dynamic>))
                  .toList()
              : <_RelatedProduct>[];

          setState(() {
            _product = product;
            _relatedProducts = related;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Product not found.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error =
              'Server error (${response.statusCode}). Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Network error. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DC.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _DC.darkText,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _product?.title ?? 'Product Detail',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _buildBody(),
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
              const Icon(Icons.wifi_off_rounded,
                  size: 52, color: Color(0xFF8A8FA3)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Color(0xFF8A8FA3), fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchDetail,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _DC.primary,
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

    if (_product == null) return const SizedBox.shrink();

    final product = _product!;
    final images = product.allImages;
    final currentImage =
        images.isNotEmpty && _selectedImageIndex < images.length
            ? images[_selectedImageIndex]
            : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + info card ──────────────────────
          Container(
            color: _DC.cardBg,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main image
                _MainImage(imageUrl: currentImage),
                const SizedBox(height: 12),

                // Thumbnails row
                if (images.length > 1)
                  _ThumbnailRow(
                    images: images,
                    selectedIndex: _selectedImageIndex,
                    onTap: (i) => setState(() => _selectedImageIndex = i),
                  ),

                const SizedBox(height: 18),

                // Title
                Text(
                  product.title,
                  style: const TextStyle(
                    color: _DC.darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),

                // Price row
                _PriceRow(
                  discountedPrice: product.totalCost,
                  originalPrice: product.price,
                  discount: product.discount,
                ),
                const SizedBox(height: 18),

                // Description
                _SectionTitle(title: 'Description'),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: _DC.greyText,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Specs row
                _SpecsRow(
                  warranty: product.warranty,
                  capacity: product.capacity,
                ),
                const SizedBox(height: 18),

                // Key Features
                if (product.featureList.isNotEmpty) ...[
                  _SectionTitle(title: 'Key Features'),
                  const SizedBox(height: 8),
                  ...product.featureList.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_rounded,
                              color: _DC.greenCheck, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                color: _DC.greenCheck,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DC.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Chat with Seller'),
                  ),
                ),
              ],
            ),
          ),

          // ── Related Products ────────────────────────
          if (_relatedProducts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: _DC.divider, thickness: 1),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Related Products',
                style: TextStyle(
                  color: _DC.darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _RelatedProductsGrid(
              products: _relatedProducts,
              onProductTap: (id) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: id),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN IMAGE
// ─────────────────────────────────────────────
class _MainImage extends StatelessWidget {
  final String? imageUrl;
  const _MainImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0EE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: 64,
        color: Color(0xFFBBBBDD),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// THUMBNAIL ROW
// ─────────────────────────────────────────────
class _ThumbnailRow extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _ThumbnailRow({
    required this.images,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(images.length, (i) {
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 72,
              height: 58,
              margin: EdgeInsets.only(right: i < images.length - 1 ? 10 : 0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected ? _DC.primary : const Color(0xFFDDDDEE),
                  width: isSelected ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_outlined,
                  size: 24,
                  color: Color(0xFFBBBBCC),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRICE ROW
// ─────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final double discountedPrice;
  final double originalPrice;
  final double discount;

  const _PriceRow({
    required this.discountedPrice,
    required this.originalPrice,
    required this.discount,
  });

  String _fmt(double price) {
    return '₹${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text(
          _fmt(discountedPrice),
          style: const TextStyle(
            color: _DC.darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (discount > 0) ...[
          Text(
            _fmt(originalPrice),
            style: const TextStyle(
              color: _DC.strikePrice,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _DC.saveBadgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Save ${discount.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SPECS ROW (warranty + capacity)
// ─────────────────────────────────────────────
class _SpecsRow extends StatelessWidget {
  final String warranty;
  final String capacity;

  const _SpecsRow({required this.warranty, required this.capacity});

  @override
  Widget build(BuildContext context) {
    final List<_SpecItem> specs = [
      if (warranty.isNotEmpty) _SpecItem(icon: Icons.verified_rounded, label: 'Warranty', value: warranty),
      if (capacity.isNotEmpty) _SpecItem(icon: Icons.people_rounded, label: 'Capacity', value: capacity),
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    return Row(
      children: specs
          .map(
            (s) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDDFFF)),
                ),
                child: Row(
                  children: [
                    Icon(s.icon, size: 18, color: _DC.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.label,
                            style: const TextStyle(
                              color: _DC.greyText,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            s.value,
                            style: const TextStyle(
                              color: _DC.darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem({required this.icon, required this.label, required this.value});
}

// ─────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _DC.darkText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RELATED PRODUCTS GRID
// ─────────────────────────────────────────────
class _RelatedProductsGrid extends StatelessWidget {
  final List<_RelatedProduct> products;
  final ValueChanged<int> onProductTap;

  const _RelatedProductsGrid({
    required this.products,
    required this.onProductTap,
  });

  String _fmt(double price) {
    return '₹${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, i) {
        final p = products[i];
        return GestureDetector(
          onTap: () => onProductTap(p.id),
          child: Container(
            decoration: BoxDecoration(
              color: _DC.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with OFF badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: const Color(0xFFEEEFF8),
                        child: p.metaImage.isNotEmpty
                            ? Image.network(
                                p.metaImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.directions_car_filled_rounded,
                                  size: 48,
                                  color: Color(0xFFBBBBDD),
                                ),
                              )
                            : const Icon(
                                Icons.directions_car_filled_rounded,
                                size: 48,
                                color: Color(0xFFBBBBDD),
                              ),
                      ),
                    ),
                    if (p.discount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _DC.offBadgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${p.discount.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _DC.darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _DC.greyText,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (p.discount > 0)
                          Text(
                            _fmt(p.price),
                            style: const TextStyle(
                              color: _DC.strikePrice,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmt(p.totalCost),
                              style: const TextStyle(
                                color: _DC.priceGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              'View',
                              style: TextStyle(
                                color: _DC.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
