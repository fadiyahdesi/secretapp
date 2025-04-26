import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/looknhear_controller.dart';

class LooknhearDetectView extends StatefulWidget {
  const LooknhearDetectView({super.key});

  @override
  State<LooknhearDetectView> createState() => _LooknhearDetectViewState();
}

class _LooknhearDetectViewState extends State<LooknhearDetectView> {
  final lookController = Get.put(LooknhearController());
  CameraController? cameraController;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      Get.snackbar("Izin Ditolak", "Aplikasi membutuhkan akses kamera.");
      return;
    }

    try {
      final cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await cameraController!.initialize();
      setState(() {
        isCameraInitialized = true;
      });
    } catch (e) {
      Get.snackbar("Error", "Gagal mengakses kamera: $e");
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child:
            isCameraInitialized
                ? Stack(
                  children: [
                    // Kamera Preview
                    Positioned.fill(
                      top: 80,
                      child: CameraPreview(cameraController!),
                    ),

                    // Atas: Judul dan Deteksi Objek (dalam 1 kolom)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: () => Get.back(),
                              ),
                              const Text(
                                "Melihat dan Mendengar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ), // Untuk balance spacing kanan
                            ],
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final obj = lookController.detectedObject.value;
                            return Text(
                              obj.isNotEmpty
                                  ? "Objek: $obj"
                                  : "Arahkan Kamera ke Objek",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Tombol Mic
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.mic,
                                  size: 32,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  // TODO: Tambahkan fitur rekam suara
                                },
                              ),
                            ),
                            const SizedBox(width: 30),
                            // Tombol Refresh
                            Container(
                              width: 55,
                              height: 55,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 28,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  // TODO: Reset suara
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
      ),
    );
  }
}
