import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bicaraku/app/data/models/user_model.dart';
import 'package:bicaraku/app/data/repositories/auth_repository.dart';
import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bicaraku/app/data/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final UserController userController = Get.find<UserController>();
  final AuthRepository authRepo = Get.find<AuthRepository>();
  final box = GetStorage();

  var obscurePassword = true.obs;
  var isLoading = false.obs;

  /// Helper private untuk mendapatkan informasi perangkat.
  Future<Map<String, dynamic>> _getDeviceInfoMap() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        final info = await deviceInfoPlugin.webBrowserInfo;
        return {'platform': 'Web', 'browser': info.browserName.name};
      } else if (Platform.isAndroid) {
        final info = await deviceInfoPlugin.androidInfo;
        return {
          'platform': 'Android',
          'manufacturer': info.manufacturer,
          'model': info.model,
          'osVersion': 'Android ${info.version.release}',
        };
      } else if (Platform.isIOS) {
        final info = await deviceInfoPlugin.iosInfo;
        return {
          'platform': 'iOS',
          'name': info.name,
          'model': info.model,
          'osVersion': '${info.systemName} ${info.systemVersion}',
        };
      }
    } catch (e) {
      print("❌ ERROR GETTING DEVICE INFO: $e");
    }
    return {'platform': 'Unknown', 'model': 'Unknown Device'};
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email dan password harus diisi");
      return;
    }

    isLoading(true);
    try {
      // 1. Ambil info perangkat (KODE BARU)
      final deviceInfo = await _getDeviceInfoMap();

      // 2. Kirim info perangkat bersama data login ke repository (KODE DIMODIFIKASI)
      final response = await authRepo.login(email, password, deviceInfo);

      // (Sisa kode Anda tidak diubah)
      if (response['status'] == 'success') {
        await box.write('token', response['token']);

        userController.setUser(
          UserModel(
            id: response['user']['_id']?.toString() ?? '',
            name: response['user']['name'] ?? '',
            email: response['user']['email'] ?? '',
            provider: response['user']['provider'] ?? 'email',
            photoUrl: response['user']['photoUrl'] ?? '',
            lastLogin:
                response['user']['lastLogin'] ?? DateTime.now().toString(),
          ),
        );

        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar("Error", response['message'] ?? 'Login gagal');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceAll('Exception:', '').trim());
    } finally {
      isLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading(true);
    try {
      // (Logika Firebase Anda tidak diubah)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        signInOption: SignInOption.standard,
      );

      await googleSignIn.signOut(); // untuk memastikan dialog muncul
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar("Login Dibatalkan", "Pengguna membatalkan login Google.");
        isLoading(false); // Pastikan loading berhenti
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await userCredential.user!.getIdToken();
      print('🔥 FIREBASE_ID_TOKEN: $firebaseIdToken');

      // 1. Ambil info perangkat (KODE BARU)
      final deviceInfo = await _getDeviceInfoMap();

      // 2. Kirim info perangkat bersama token ke repository (KODE DIMODIFIKASI)
      final response = await authRepo.loginWithGoogle(
        firebaseIdToken!,
        deviceInfo,
      );

      // (Sisa kode Anda tidak diubah)
      if (response['status'] == 'success') {
        await box.write('token', response['token']);

        userController.setUser(
          UserModel(
            id: response['user']['_id']?.toString() ?? '',
            name: response['user']['name'] ?? googleUser.displayName ?? 'User',
            email: response['user']['email'] ?? googleUser.email,
            provider: response['user']['provider'] ?? 'google',
            photoUrl: response['user']['photoUrl'] ?? googleUser.photoUrl ?? '',
            lastLogin:
                response['user']['lastLogin'] ?? DateTime.now().toString(),
          ),
        );

        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar("Error", response['message'] ?? 'Google login failed');
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: ${e.toString()}");
      print('Google Sign-In Error: $e');
    } finally {
      isLoading(false);
    }
  }
}
