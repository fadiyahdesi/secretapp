import 'package:bicaraku/app/modules/f2.cariobjek/controllers/cariobjek_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CariobjekcamView extends GetView<CariObjekController> {
  const CariobjekcamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          // Tampilkan loading jika kamera belum siap
          if (!controller.isCameraInitialized.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            children: [
              // Kamera Preview
              Positioned.fill(
                top: 80,
                child: CameraPreview(controller.cameraController),
              ),

              // Judul
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: const Text(
                    "Mencari Benda Sekitar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Instruksi dari gambar yang diklik
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.instruksi.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Tombol kamera dan refresh
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tombol Kamera di tengah
                    GestureDetector(
                      onTap: controller.ambilGambar,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 3),
                        ),
                      ),
                    ),

                    // Tombol Refresh di kanan
                    Positioned(
                      right: 50,
                      child: GestureDetector(
                        onTap: controller.ambilGambar,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
