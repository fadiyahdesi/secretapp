import 'package:bicaraku/core/network/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordController extends GetxController {
  final emailController = TextEditingController();
  var isLoading = false.obs;

  // ResetPasswordController (sendResetLink)
  Future<void> sendResetLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Error", "Email tidak boleh kosong");
      return;
    }
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.resetpassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == 'success') {
        Get.snackbar("Sukses", "Cek email untuk verifikasi dulu");
        // Pindah ke CreatePasswordView dengan membawa email
        Get.toNamed('/create-password', parameters: {'email': email});
      } else {
        Get.snackbar("Gagal", body['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
