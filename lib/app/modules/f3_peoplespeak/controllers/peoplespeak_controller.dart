import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BerbicaraController extends GetxController {
  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  var currentSentence = "".obs;
  var isListening = false.obs;
  var recognizedText = "".obs;
  var ttsInitialized = false.obs;
  var speechInitialized = false.obs;
  var isPlayingInstruction = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initTTS();
    _initSpeech();
  }

  Future<void> _initTTS() async {
    try {
      await tts.setLanguage("id-ID");
      await tts.setSpeechRate(0.3);
      await tts.setPitch(1.0);
      await tts.awaitSpeakCompletion(true);
      ttsInitialized.value = true;
    } catch (e) {
      Get.snackbar("Error", "Gagal inisialisasi Text-to-Speech");
    }
  }

  Future<void> _initSpeech() async {
    try {
      speechInitialized.value = await speech.initialize();
      if (!speechInitialized.value) {
        Get.snackbar("Error", "Akses mikrofon tidak diizinkan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal inisialisasi Speech-to-Text");
    }
  }

  Future<void> startPractice(String sentence) async {
    isPlayingInstruction.value = true;
    
    // Ucapkan instruksi
    await tts.speak("Silakan ucapkan kalimat berikut:");
    await Future.delayed(const Duration(seconds: 1));
    
    // Ucapkan kalimat 2x
    for (int i = 0; i < 2; i++) {
      await tts.speak(sentence);
      await Future.delayed(const Duration(seconds: 2));
    }
    
    isPlayingInstruction.value = false;
  }

  Future<void> toggleRecording() async {
    if (isListening.value) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!speechInitialized.value) return;
    if (isPlayingInstruction.value) return;

    try {
      isListening.value = true;
      recognizedText.value = "";
      await speech.listen(
        onResult: (result) => recognizedText.value = result.recognizedWords,
        localeId: "id-ID",
        listenFor: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memulai rekaman");
      isListening.value = false;
    }
  }

  Future<void> _stopListening() async {
    try {
      await speech.stop();
      isListening.value = false;
      _checkPronunciation();
    } catch (e) {
      Get.snackbar("Error", "Gagal menghentikan rekaman");
    }
  }

  void _checkPronunciation() {
    final input = recognizedText.value.trim().toLowerCase();
    final target = currentSentence.value.trim().toLowerCase();

    if (input == target) {
      _showSuccessDialog();
    } else {
      _showRetryDialog();
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Selamat!"),
          ],
        ),
        content: const Text("Pengucapanmu tepat!"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Kembali ke halaman sebelumnya
            },
            child: const Text("Selesai"),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text("Coba Lagi"),
          ],
        ),
        content: const Text("Pengucapan belum tepat"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              startPractice(currentSentence.value);
            },
            child: const Text("Ulangi"),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    tts.stop();
    speech.stop();
    super.onClose();
  }
}