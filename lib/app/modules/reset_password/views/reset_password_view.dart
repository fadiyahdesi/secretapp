import 'package:bicaraku/app/modules/reset_password/controllers/reset_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordView extends StatelessWidget {
  ResetPasswordView({super.key});

  final ResetPasswordController controller =
      Get.find<ResetPasswordController>();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button di luar padding agar benar-benar di pojok kiri
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

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Masukkan email Anda untuk melakukan verifikasi terlebih dahulu\nagar bisa membuat kata sandi baru",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text("Email"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : controller.sendResetLink,
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
                            controller.isLoading.value
                                ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "Kirim",
                                  style: TextStyle(color: Colors.black),
                                ),
                      ),
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
