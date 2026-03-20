import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rojgar/models/explore_model.dart';

class DashboardController extends GetxController {
  static const String _endpoint =
      'https://rozgaradda.com/api/candidate/dashboard';

  final isLoading = false.obs;
  final error = RxnString();
  final categories = <DashboardCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await http.get(Uri.parse(_endpoint));

      if (response.statusCode == 200) {
        final items = DashboardCategory.listFromResponseBody(response.body);
        categories
          ..clear()
          ..addAll(items);
      } else {
        error.value = 'Unable to load dashboard. Please try again.';
      }
    } catch (_) {
      error.value = 'Unable to load dashboard. Please check your connection.';
    } finally {
      isLoading.value = false;
    }
  }
}
