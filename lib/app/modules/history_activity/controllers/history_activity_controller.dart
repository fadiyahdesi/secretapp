import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:bicaraku/core/network/api_constant.dart';

/// Controller ini HANYA bertanggung jawab untuk mengambil dan mengelola
/// data riwayat aktivitas pengguna.
class HistoryActivityController extends GetxController {
  var isLoading = true.obs;
  var activityList = <Map<String, dynamic>>[].obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final type = args?['type']; // Mengambil tipe dari argumen navigasi jika ada
    fetchActivity(type);
  }

  /// Mengambil data riwayat aktivitas dari server.
  Future<void> fetchActivity(String? type) async {
    isLoading(true);
    try {
      final token = storage.read('token');
      if (token == null) {
        // Jika tidak ada token, tidak perlu lanjut dan berhenti loading.
        isLoading(false);
        return;
      }

      // URL sudah benar sesuai dengan definisi rute di Flask: /api/history-activity
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/history-activity',
      ).replace(queryParameters: type != null ? {'type': type} : null);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Penanganan response yang aman untuk menghindari FormatException
      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          if (jsonData['data'] is List) {
            activityList.value = List<Map<String, dynamic>>.from(
              jsonData['data'],
            );
          }
        } else {
          final errorData = json.decode(response.body);
          Get.snackbar(
            "Gagal",
            errorData['message'] ?? "Gagal mengambil data riwayat.",
          );
        }
      } else {
        Get.snackbar(
          "Error Server",
          "Server memberikan respon yang tidak valid. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Menghapus semua riwayat aktivitas berdasarkan tipenya.
  Future<void> deleteHistoryByType(String type) async {
    final token = storage.read('token');
    if (token == null) {
      Get.snackbar('Gagal', 'Anda harus login untuk melakukan aksi ini.');
      return;
    }

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/history-activity');
      final body = jsonEncode({'type': type});

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Hapus item dari list lokal agar UI langsung update
        activityList.removeWhere((item) => item['type'] == type);
        Get.snackbar("Berhasil", "Semua riwayat '$type' berhasil dihapus");
      } else {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final errorData = json.decode(response.body);
          Get.snackbar(
            "Gagal",
            errorData['message'] ?? "Gagal menghapus riwayat.",
          );
        } else {
          Get.snackbar(
            "Error Server",
            "Gagal menghapus riwayat. Status: ${response.statusCode}",
          );
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }
}
