import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CariObjekController extends GetxController {
  late CameraController cameraController;
  final isCameraInitialized = false.obs;

  final instruksi = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Ambil instruksi dari argument saat navigasi (misalnya "Cari bola")
    if (Get.arguments != null && Get.arguments is String) {
      instruksi.value = Get.arguments;
    }

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void ambilGambar() async {
    if (!cameraController.value.isInitialized) return;

    try {
      final file = await cameraController.takePicture();
      debugPrint("Gambar diambil: ${file.path}");
      // Tambahkan logika selanjutnya di sini (misalnya analisis gambar)
    } catch (e) {
      debugPrint("Gagal ambil gambar: $e");
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
