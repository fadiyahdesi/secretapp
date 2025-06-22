import 'package:bicaraku/core/network/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreatePasswordView extends StatefulWidget {
  const CreatePasswordView({super.key});

  @override
  State<CreatePasswordView> createState() => _CreatePasswordViewState();
}

class _CreatePasswordViewState extends State<CreatePasswordView> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  String? token;

  @override
  void initState() {
    super.initState();
    token = Get.parameters['token']; // Ambil token dari URL
  }

  Future<void> updatePassword() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("Error", "Semua kolom wajib diisi");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Password dan konfirmasi tidak cocok");
      return;
    }

    if (token == null || token!.isEmpty) {
      Get.snackbar("Error", "Token tidak ditemukan di URL");
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/create-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'new_password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Password Berhasil Diubah"),
                content: const Text("Silakan klik tombol Login untuk masuk."),
                actions: [
                  TextButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: const Text("Login"),
                  ),
                ],
              ),
        );
      } else {
        Get.snackbar("Gagal", data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      Get.snackbar("Error", "Tidak dapat terhubung ke server");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 9.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Buat Password Baru",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Pastikan Email Anda telah diverifikasi. Sekarang buat kata sandi baru Anda.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      const Text("Password"),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextField(
                          controller: passwordController,
                          obscureText: obscurePassword.value,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                obscurePassword.value = !obscurePassword.value;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Konfirmasi Password"),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword.value,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                obscureConfirmPassword.value =
                                    !obscureConfirmPassword.value;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Update Password di sebelah kiri
                      Obx(
                        () => Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: isLoading.value ? null : updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE7A6F9),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child:
                                isLoading.value
                                    ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      "Update Password",
                                      style: TextStyle(color: Colors.black),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
