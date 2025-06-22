import 'dart:io';
import 'package:bicaraku/app/modules/profil/controllers/profil_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicaraku/core/network/api_constant.dart';

class ProfilView extends StatelessWidget {
  ProfilView({super.key});
  final profilController = Get.find<ProfilController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text("")),
      body: Obx(() {
        if (profilController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // FOTO PROFIL DENGAN TOMBOL EDIT
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Obx(() {
                      final avatar = profilController.avatarPath.value;
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            avatar.isEmpty
                                ? const AssetImage("assets/images/iconuser.png")
                                    as ImageProvider
                                : avatar.startsWith('http')
                                ? NetworkImage(avatar)
                                : NetworkImage(
                                  '${ApiConstants.baseUrl}$avatar',
                                ),
                      );
                    }),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: profilController.pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Klik untuk ubah foto",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 24),

                // FIELD EMAIL, USERNAME, PASSWORD
                _buildTextField(
                  label: "Email",
                  controller: profilController.emailController,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Username",
                  controller: profilController.usernameController,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Kata sandi",
                  controller: profilController.passwordController,
                  isPassword: true,
                  obscureRx: profilController.obscurePassword,
                ),
                const SizedBox(height: 24),

                // TOMBOL UPDATE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: profilController.updateProfile,
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: const Text("Update"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // AKTIVITAS HARIAN
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Aktivitas Harian",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildActivityItem("Riwayat Login", "login"),
                      const Divider(height: 1),
                      _buildActivityItem(
                        "Riwayat Update Profil",
                        "update_profile",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text("Keluar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _confirmDeleteAccount,
                        icon: const Icon(Icons.delete_forever_rounded),
                        label: const Text("Hapus"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Colors.red.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    RxBool? obscureRx,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscureRx != null ? obscureRx.value : false,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon:
            isPassword && obscureRx != null
                ? Obx(
                  () => IconButton(
                    icon: Icon(
                      obscureRx.value ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => obscureRx.toggle(),
                  ),
                )
                : const Icon(Icons.edit, color: Colors.grey),
      ),
    );
  }

  Widget _buildActivityItem(String title, String activityType) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Get.toNamed("/history-activity", arguments: {'type': activityType});
      },
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.blue),
            SizedBox(width: 10),
            Text("Konfirmasi Keluar Akun"),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun ini?",
          style: TextStyle(fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // tutup dialog dulu
              profilController.logout(); // lalu logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Konfirmasi Hapus Akun"),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.",
          style: TextStyle(fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              profilController.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Hapus Akun",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
