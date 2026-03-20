import 'dart:convert';

class DashboardCategory {
  final int id;
  final String name;
  final String image; // image file name from API

  const DashboardCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  String get imageUrl {
    // Adjust base path here if backend changes
    return 'https://rozgaradda.com/assets/images/$image';
  }

  factory DashboardCategory.fromJson(Map<String, dynamic> json) {
    return DashboardCategory(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }

  static List<DashboardCategory> listFromResponseBody(String body) {
    final decoded = json.decode(body) as Map<String, dynamic>;
    final data =
        decoded['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final list = data['categories'] as List<dynamic>? ?? <dynamic>[];
    return list
        .map((e) => DashboardCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
