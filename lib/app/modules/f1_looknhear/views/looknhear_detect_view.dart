import 'package:bicaraku/core/network/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/looknhear_controller.dart';

class LooknhearDetectView extends StatefulWidget {
  const LooknhearDetectView({super.key});

  @override
  State<LooknhearDetectView> createState() => _LooknhearDetectViewState();
}

class _LooknhearDetectViewState extends State<LooknhearDetectView> {
  final lookController = Get.find<LooknhearController>();
  CameraController? cameraController;
  bool isCameraInitialized = false;
  Timer? _timer;
  bool hasDetected = false;

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
      await cameraController!.setFlashMode(FlashMode.off);

      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => detectObjectInFrame(),
      );

      setState(() {
        isCameraInitialized = true;
      });
      lookController.speakInitialGuidance;
    } catch (e) {
      Get.snackbar("Error", "Gagal mengakses kamera: $e");
    }
  }

  Future<void> detectObjectInFrame() async {
    if (hasDetected || lookController.isSpeaking.value) return;

    try {
      final image = await cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.detect}',
        ), //Mengirim gambar ke backend API
        headers: {'Content-Type': 'application/octet-stream'},
        body: imageBytes,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final detectedLabels = List<String>.from(
          result['detected'],
        ); //mengambil hasil json dari backend

        if (detectedLabels.isNotEmpty) {
          final closestObject = _getClosestObject(detectedLabels);
          lookController.detectNewObject(closestObject);

          _timer?.cancel();
          hasDetected = true;

          await lookController.speakDetectedObject(closestObject);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: ${e.toString()}");
    }
  }

  String _getClosestObject(List<String> objects) {
    return objects.first;
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
                    Positioned.fill(
                      top: 80,
                      bottom: 95,
                      child: CameraPreview(cameraController!),
                    ),
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
                                onPressed: () {
                                  lookController.resetAllSpeech();
                                  Get.back();
                                },
                              ),
                              const Text(
                                "Melihat dan Mendengar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 40),
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
                        child: Column(
                          children: [
                            Obx(() {
                              if (lookController.isProcessingSpeech.value) {
                                return const Text(
                                  "Memproses...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                );
                              } else if (lookController.isListening.value) {
                                return const Text(
                                  "Mendengarkan...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                );
                              } else if (lookController
                                  .recognizedText
                                  .isNotEmpty) {
                                return Text(
                                  "Anda mengucapkan: ${lookController.recognizedText.value}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                );
                              }
                              return const SizedBox();
                            }),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(
                                  () => Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color:
                                          lookController.isListening.value
                                              ? Colors.red
                                              : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.mic,
                                        size: 32,
                                        color:
                                            lookController.isListening.value
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      onPressed: lookController.toggleRecording,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 30),
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
                                      lookController.stopSpeaking();
                                      lookController.detectNewObject('');
                                      lookController.recognizedText.value = '';
                                      hasDetected = false;
                                      _timer?.cancel();
                                      _timer = Timer.periodic(
                                        const Duration(seconds: 3),
                                        (_) => detectObjectInFrame(),
                                      );
                                    },
                                  ),
                                ),
                              ],
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

  @override
  void dispose() {
    lookController.resetAllSpeech();
    _timer?.cancel();
    cameraController?.dispose();
    super.dispose();
  }
}
