import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    final email = emailController.text;
    final password = passwordController.text;

    // Lakukan validasi/login di sini
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email dan password harus diisi");
    } else {
      Get.snackbar("Berhasil", "Selamat datang $email");
      Get.offAllNamed(Routes.HOME);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
