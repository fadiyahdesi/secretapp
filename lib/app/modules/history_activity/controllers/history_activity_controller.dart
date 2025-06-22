import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:bicaraku/core/network/api_constant.dart';

class HistoryActivityController extends GetxController {
  var isLoading = true.obs;
  var activityList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    final args = Get.arguments;
    final type = args?['type'];
    fetchActivity(type);
    super.onInit();
  }

  Future<void> fetchActivity(String? type) async {
    try {
      isLoading(true);
      final token = GetStorage().read('token');

      final uri =
          type != null
              ? Uri.parse(
                '${ApiConstants.baseUrl}/api/history-activity?type=$type',
              )
              : Uri.parse('${ApiConstants.baseUrl}/api/history-activity');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        activityList.value = List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        Get.snackbar("Gagal", "Tidak bisa mengambil data aktivitas");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading(false);
    }
  }
}
