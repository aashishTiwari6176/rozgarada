import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rojgar/floating_navbar.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFDDDDEE);
  static const Color uploadBg = Color(0xFFF0F0FF);
}

const String _sellProductApiUrl = 'https://rozgaradda.com/api/sell/add';
const String _sellProductBearerToken =
    '1|y1EzlPQqrGADDxsCP3upGTTFT0cTIlfIB1bAMEZNb65f5911';

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class SellProductFormScreen extends StatefulWidget {
  final int categoryId;
  final int subCategoryId;
  final String categoryName;
  final String subCategoryName;

  const SellProductFormScreen({
    super.key,
    required this.categoryId,
    required this.subCategoryId,
    required this.categoryName,
    required this.subCategoryName,
  });

  @override
  State<SellProductFormScreen> createState() => _SellProductFormScreenState();
}

class _SellProductFormScreenState extends State<SellProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _featuresCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0.00');
  final _discountCtrl = TextEditingController(text: '0');
  final _capacityCtrl = TextEditingController();
  final _warrantyCtrl = TextEditingController();

  XFile? _mainImage;
  final List<XFile> _galleryImages = [];
  bool _isActive = true;
  bool _isSaving = false;

  double get _totalCost {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    return price - (price * discount / 100);
  }

  Future<void> _pickMainImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _mainImage = picked);
  }

  Future<void> _pickGalleryImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(limit: 5);
    if (picked.isNotEmpty) {
      setState(() {
        _galleryImages.clear();
        _galleryImages.addAll(picked.take(5));
      });
    }
  }

  void _removeGalleryImage(int index) {
    setState(() => _galleryImages.removeAt(index));
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? _C.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mainImage == null) {
      _showSnackBar(
        'Please select a main product image.',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_sellProductApiUrl),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_sellProductBearerToken',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'category_id': widget.categoryId.toString(),
        'subcategory_id': widget.subCategoryId.toString(),
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': _priceCtrl.text.trim().isEmpty ? '0' : _priceCtrl.text.trim(),
        'discount':
            _discountCtrl.text.trim().isEmpty ? '0' : _discountCtrl.text.trim(),
        'features': _featuresCtrl.text.trim(),
        'capacity': _capacityCtrl.text.trim(),
        'warranty': _warrantyCtrl.text.trim(),
        'status': _isActive ? '1' : '0',
      });

      request.files.add(
        await http.MultipartFile.fromPath('meta_image', _mainImage!.path),
      );

      for (final image in _galleryImages) {
        request.files.add(
          await http.MultipartFile.fromPath('gallery_images[]', image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic>? jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        jsonResponse = null;
      }

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SellProductReviewScreen(),
          ),
        );
      } else {
        final message =
            jsonResponse?['message']?.toString() ??
            'Failed to save product. Please try again.';
        _showSnackBar(message, backgroundColor: Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Something went wrong while saving the product.',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _featuresCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _capacityCtrl.dispose();
    _warrantyCtrl.dispose();
    super.dispose();
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category info banner
                    _CategoryBanner(
                      categoryName: widget.categoryName,
                      subCategoryName: widget.subCategoryName,
                    ),
                    const SizedBox(height: 20),

                    // Product Title
                    _FieldLabel('Product Title'),
                    _InputField(
                      controller: _titleCtrl,
                      hint: 'Enter product name (e.g. BMW X5 2024)',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _FieldLabel('Description'),
                    _InputField(
                      controller: _descCtrl,
                      hint: 'Enter detailed description of the car...',
                      maxLines: 5,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Features
                    _FieldLabel('Features (Separate with commas)'),
                    _InputField(
                      controller: _featuresCtrl,
                      hint: 'Sunroof, Leather Seats, Autopilot...',
                    ),
                    const SizedBox(height: 16),

                    // Main Image
                    _FieldLabel('Main Product Image'),
                    _ImagePickerTile(
                      label: _mainImage == null
                          ? 'No file selected'
                          : _mainImage!.name,
                      onTap: _pickMainImage,
                      previewFile:
                          _mainImage != null ? File(_mainImage!.path) : null,
                    ),
                    const SizedBox(height: 16),

                    // Gallery Images
                    _FieldLabel('Gallery Images'),
                    _GalleryPickerTile(
                      images: _galleryImages,
                      onPickTap: _pickGalleryImages,
                      onRemove: _removeGalleryImage,
                    ),
                    const SizedBox(height: 16),

                    // Price & Discount row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Price (₹)'),
                              _InputField(
                                controller: _priceCtrl,
                                hint: '0.00',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Discount (%)'),
                              _InputField(
                                controller: _discountCtrl,
                                hint: '0',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Cost
                    _FieldLabel('Total Cost (₹)'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: _C.fieldBg,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: _C.borderColor, width: 1),
                      ),
                      child: Text(
                        _priceCtrl.text.isEmpty
                            ? 'Calculated total'
                            : '₹ ${_totalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _priceCtrl.text.isEmpty
                              ? _C.greyText
                              : _C.darkText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Capacity & Warranty row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Capacity'),
                              _InputField(
                                controller: _capacityCtrl,
                                hint: 'e.g. 5 Seater',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Warranty'),
                              _InputField(
                                controller: _warrantyCtrl,
                                hint: 'e.g. 3 Years',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Active Product toggle
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE8E8C0), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_rounded,
                              color: _C.primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Active Product',
                              style: TextStyle(
                                color: _C.darkText,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            activeColor: Colors.white,
                            activeTrackColor: _C.primaryBlue,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFCCCCCC),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _BottomActions(
        isSaving: _isSaving,
        onCancel: () => Navigator.maybePop(context),
        onSave: _saveProduct,
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
            child:
                const Icon(Icons.arrow_back, color: Colors.white, size: 24),
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
// STEP INDICATOR (4 steps)
// ─────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({this.currentStep = 3});

  @override
  Widget build(BuildContext context) {
    final bool isReviewStep = currentStep >= 4;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          _StepCircle(
              number: 1, label: 'Category', state: _StepState.done),
          _StepLine(active: true),
          _StepCircle(
              number: 2, label: 'Sub-Cat', state: _StepState.done),
          _StepLine(active: true),
          _StepCircle(
              number: 3,
              label: 'Details',
              state: isReviewStep ? _StepState.done : _StepState.active),
          _StepLine(active: isReviewStep),
          _StepCircle(
              number: 4,
              label: 'Review',
              state: isReviewStep ? _StepState.active : _StepState.inactive),
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isActive)
                ? _C.primaryBlue
                : const Color(0xFFE8E8F0),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16)
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive ? Colors.white : _C.greyText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: (isDone || isActive) ? _C.primaryBlue : _C.greyText,
            fontSize: 9,
            fontWeight:
                (isDone || isActive) ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.4,
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
// CATEGORY BANNER
// ─────────────────────────────────────────────
class _CategoryBanner extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;

  const _CategoryBanner({
    required this.categoryName,
    required this.subCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _C.uploadBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCCCCFF), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: _C.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category: $categoryName',
                style: const TextStyle(
                  color: _C.darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Sub Category: $subCategoryName',
                style: const TextStyle(
                  color: _C.greyText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FIELD LABEL
// ─────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _C.darkText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INPUT FIELD
// ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: _C.darkText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: _C.greyText, fontSize: 14),
        filled: true,
        fillColor: _C.fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// IMAGE PICKER TILE (single)
// ─────────────────────────────────────────────
class _ImagePickerTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final File? previewFile;

  const _ImagePickerTile({
    required this.label,
    required this.onTap,
    this.previewFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _C.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.borderColor, width: 1),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.image_outlined,
                  color: _C.greyText, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: _C.greyText, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Choose File',
                    style: TextStyle(
                      color: _C.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (previewFile != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              previewFile!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// GALLERY PICKER TILE (multiple)
// ─────────────────────────────────────────────
class _GalleryPickerTile extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPickTap;
  final void Function(int) onRemove;

  const _GalleryPickerTile({
    required this.images,
    required this.onPickTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _C.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _C.borderColor,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  color: _C.greyText, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  images.isEmpty
                      ? 'Max 5 images'
                      : '${images.length} image${images.length > 1 ? 's' : ''} selected',
                  style: const TextStyle(
                      color: _C.greyText, fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: onPickTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Choose File',
                    style: TextStyle(
                      color: _C.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(images[i].path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM ACTIONS
// ─────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _BottomActions({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Row(
        children: [
          // Cancel
          Expanded(
            child: GestureDetector(
              onTap: onCancel,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: const Color(0xFFDDDDEE), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: _C.darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Save Product
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: isSaving ? null : onSave,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: _C.primaryBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'SAVE PRODUCT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
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

class SellProductReviewScreen extends StatelessWidget {
  const SellProductReviewScreen({super.key});

  void _goToDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const FloatingNavbarScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              _TopBar(),
              const SizedBox(height: 24),
              const _StepIndicator(currentStep: 4),
              const Spacer(),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: _C.fieldBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.borderColor),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: _C.primaryBlue,
                      size: 56,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Your application is in review',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _C.darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'We have received your product details. Our team will review it shortly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _C.greyText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _goToDashboard(context),
                  child: const Text(
                    'GO TO DASHBOARD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
