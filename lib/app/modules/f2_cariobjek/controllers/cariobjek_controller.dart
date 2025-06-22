import 'dart:async';
import 'dart:convert';

import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:bicaraku/core/network/api_constant.dart';
import 'package:bicaraku/app/data/controllers/activity_controller.dart';
import 'package:bicaraku/app/data/models/activity_history.dart';

class CariObjekController extends GetxController {
  late CameraController cameraController;
  final isCameraInitialized = false.obs;
  final countdown = 20.obs;
  final instruksi = ''.obs;
  final targetObject = ''.obs;
  final detectedObject = ''.obs;
  var isSpeaking = false.obs;
  var isListening = false.obs;
  var recognizedText = ''.obs;
  var isProcessingSpeech = false.obs;

  Timer? _detectionTimer;
  Timer? _countdownTimer;
  final _speechQueue = <String>[].obs;
  late FlutterTts _tts;
  late stt.SpeechToText _speech;

  // Shared assets dan konfigurasi
  final correctImage = 'assets/images/correct.png';
  final wrongImage = 'assets/images/wrong.png';
  final _pronunciationExceptions = {
    "orang": ["o", "rang"],
    "kursi": ["kur", "si"],
    "payung": ["pa", "yung"],
    "sepeda": ["se", "pe", "da"],
    "motor": ["mo", "tor"],
    "pesawat": ["pe", "sa", "wat"],
    "kereta": ["ke", "re", "ta"],
    "lampu lalu lintas": ["lam", "pu", "la", "lu", "lin", "tas"],
    "hidran": ["hi", "dran"],
    "zebra": ["ze", "bra"],
    "jerapah": ["je", "ra", "pah"],
    "frisbi": ["fris", "bi"],
    "wortel": ["wor", "tel"],
    "laptop": ["lap", "top"],
    "microwave": ["mi", "cro", "wave"],
    "kulkas": ["kul", "kas"],
    "remote": ["re", "mo", "te"],
    "keyboard": ["key", "board"],
    "pemanggang": ["pe", "mang", "gang"],
    "wastafel": ["was", "ta", "fel"],
    "televisi": ["te", "le", "vi", "si"],
    "sandwich": ["sand", "wich"],
    "pizza": ["pit", "za"],
    "donat": ["do", "nat"],
    "boneka beruang": ["bo", "ne", "ka", "be", "ru", "ang"],
    "pengering rambut": ["pe", "nge", "ring", "ram", "but"],
  };

  @override
  void onInit() {
    super.onInit();
     
     // Cek apakah ada instruksi yang dikirim dari history
    if (Get.arguments != null && Get.arguments is String) {
      instruksi.value = Get.arguments as String;
      targetObject.value = _extractTargetObject(instruksi.value);
    }
    
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _configureTts();
    await _initializeSpeech();

    if (Get.arguments != null && Get.arguments is String) {
      instruksi.value = Get.arguments;
      targetObject.value = _extractTargetObject(instruksi.value);
    }

    await _initializeCamera();
    await _speakInitialInstruction(); // 1. Bicara instruksi awal
    _startCountdown(); // 2. Mulai timer setelah selesai bicara
    _startDetection(); // 3. Mulai deteksi objek
  }

  String _extractTargetObject(String instruksi) {
    return instruksi.replaceAll('"', '').replaceAll('AYO TEMUKAN ', '').trim();
  }

  Future<void> _configureTts() async {
    _tts = FlutterTts();
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage("id-ID");
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.0);
  }

  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await cameraController.initialize();
      isCameraInitialized.value = true;

      _detectionTimer = Timer.periodic(Duration(seconds: 3), (_) {
        if (!isSpeaking.value && countdown.value > 0) {
          _detectObjectInFrame();
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Gagal menginisialisasi kamera");
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        _handleTimeout();
        timer.cancel();
      }
    });
  }

  Future<void> _speakInitialInstruction() async {
    for (int i = 0; i < 3; i++) {
      await _tts.speak("Ayo cari ${targetObject.value}");
      // Tunggu sampai selesai bicara + jeda 1.5 detik
      await Future.delayed(Duration(milliseconds: 1500));
    }
    // Beri instruksi setelah 3x pengulangan
    await _tts.speak(
      "Cari ${targetObject.value} di sekitarmu dan arahkan kamera!",
    );
  }

  void _startDetection() {
    _detectionTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (!isSpeaking.value && countdown.value > 0) {
        _detectObjectInFrame();
      }
    });
  }

  Future<void> _detectObjectInFrame() async {
    try {
      final image = await cameraController.takePicture();
      final imageBytes = await image.readAsBytes();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.detect}'),
        headers: {'Content-Type': 'application/octet-stream'},
        body: imageBytes,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final detectedLabels = List<String>.from(result['detected']);

        if (detectedLabels.isNotEmpty) {
          final closestObject = _getClosestObject(detectedLabels);
          detectedObject.value = closestObject;

          if (closestObject.toLowerCase() == targetObject.value.toLowerCase()) {
            await _handleObjectFound(); // Object benar
          } else {
            await _handleWrongObject(closestObject); // Object salah
          }
        }
      }
    } catch (e) {
      debugPrint("Error deteksi objek: $e");
    }
  }

  Future<void> _handleObjectFound() async {
    _detectionTimer?.cancel();
    _countdownTimer?.cancel();
  Get.dialog(
    Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.5, end: 1.5),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 150,
            ),
          );
        },
        onEnd: () {
          Get.back();
        },
      ),
    ),
    barrierColor: Colors.black.withOpacity(0.6),
  );
    // Beri feedback suara
    await _tts.speak("Hore! Kamu berhasil menemukan ${targetObject.value}");
    await _tts.speak("Sekarang coba ucapkan nama benda tersebut");

    _startListening();
    // Simpan riwayat aktivitas
  final activityController = Get.find<ActivityController>();
  activityController.addHistory(ActivityHistory(
    id: '',
    title: "Mencari ${targetObject.value}",
    image: _getImageForObject(targetObject.value),
    date: DateTime.now(),
    isCompleted: true,
    instruksi: instruksi.value
  ));
  }

  String _getClosestObject(List<String> objects) {
    return objects.first;
  }

  Future<void> _handleWrongObject(String detectedName) async {
  // Hentikan semua ucapan sebelumnya
  await _tts.stop();
  
  // Beri feedback lebih informatif
  await _tts.speak("Belum tepat");
  await Future.delayed(const Duration(milliseconds: 500));
  await _tts.speak("Ini $detectedName");
  await Future.delayed(const Duration(milliseconds: 1000));
  await _tts.speak("Sekarang coba cari ${targetObject.value} ya");
  
  // Tambahkan animasi visual
  Get.dialog(
    Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/wrong.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Salah!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ini $detectedName\nCari ${targetObject.value}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
        onEnd: () {
          Future.delayed(const Duration(seconds: 3), () => Get.back());
        },
      ),
    ),
    barrierColor: Colors.black.withOpacity(0.5),
  );
}

  Future<void> speakDetectedObject(String object) async {
    _speechQueue.add(object);
    if (!isSpeaking.value) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    while (_speechQueue.isNotEmpty) {
      isSpeaking.value = true;
      final object = _speechQueue.removeAt(0);

      for (int i = 0; i < 3; i++) {
        await _speechWithPause("Ini adalah", pause: 1000);
        await _speechWithPause(object, pause: 1500);
        await _spellWord(object);
        await Future.delayed(Duration(milliseconds: 2000));
      }

      if (_speechQueue.isEmpty) {
        await _speechWithPause("Sekarang", pause: 1000);
        await _speechWithPause("coba kamu ucapkan", pause: 800);
        await _speechWithPause(object, pause: 1500);
      }
    }
    isSpeaking.value = false;
  }

  Future<void> _spellWord(String word) async {
    final syllables = _splitIntoSyllables(word);

    await _speechWithPause(" ", pause: 1000);

    for (int i = 0; i < syllables.length; i++) {
      await _tts.setSpeechRate(0.3);
      await _speechWithPause(syllables[i], pause: 800);
      await _tts.setSpeechRate(0.4);

      if (i < syllables.length - 1) {
        await Future.delayed(Duration(milliseconds: 1000));
      }
    }
  }

  List<String> _splitIntoSyllables(String word) {
    if (_pronunciationExceptions.containsKey(word)) {
      return _pronunciationExceptions[word]!;
    }

    List<String> syllables = [];
    String currentSyllable = '';
    bool lastWasVowel = false;

    for (int i = 0; i < word.length; i++) {
      final char = word[i].toLowerCase();
      final isVowel = _isVowel(char);

      if (!isVowel && i > 0 && !lastWasVowel) {
        if (i + 1 < word.length && !_isVowel(word[i + 1])) {
          syllables.add(currentSyllable);
          currentSyllable = char;
          continue;
        } else if (currentSyllable.isNotEmpty) {
          syllables.add(currentSyllable);
          currentSyllable = char;
          continue;
        }
      }

      currentSyllable += char;
      lastWasVowel = isVowel;

      if (i == word.length - 1) {
        syllables.add(currentSyllable);
      } else if (isVowel && !_isVowel(word[i + 1])) {
        syllables.add(currentSyllable);
        currentSyllable = '';
        lastWasVowel = false;
      }
    }

    return syllables.isNotEmpty ? syllables : [word];
  }

  bool _isVowel(String char) {
    return ['a', 'i', 'u', 'e', 'o'].contains(char.toLowerCase());
  }

  Future<void> _speechWithPause(String text, {int pause = 300}) async {
    await _tts.speak(text);
    await Future.delayed(Duration(milliseconds: pause));
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      isListening.value = true;
      _speech.listen(
        onResult: (result) => recognizedText.value = result.recognizedWords,
        localeId: "id_ID",
        listenFor: Duration(seconds: 5),
        onSoundLevelChange: (level) {
          // Untuk visualisasi level suara (opsional)
        },
      );
    }
  }

  Future<void> toggleRecording() async {
    if (isListening.value) {
      _speech.stop();
      isListening.value = false;
      _checkSpeechMatch();
    } else {
      if (targetObject.value.isEmpty) return;
      await _startListening();
    }
  }

  void _checkSpeechMatch() async {
    final input = recognizedText.value.toLowerCase().trim();
    final target = targetObject.value.toLowerCase().trim();

    await _tts.stop();

    if (input == target) {
      await _speechWithPause("Hore! Pelafalanmu tepat!", pause: 500);
      await _speechWithPause("Kamu hebat!", pause: 300);
      Get.offAllNamed(Routes.HOME);
    } else {
      await _speechWithPause("Pelafalanmu belum tepat", pause: 500);
      await _speechWithPause("Ayo coba ucapkan lagi", pause: 300);
      recognizedText.value = '';
      _startListening();
    }
  }

  void _handleTimeout() {
    _detectionTimer?.cancel();
    _countdownTimer?.cancel();
    
    Get.dialog(
       _buildTimeoutDialog(), // Ganti dengan custom dialog
    barrierDismissible: false,
  );
  
  _tts.speak("Waktu sudah habis, jangan menyerah ya! Coba lagi lain kali");
   final activityController = Get.find<ActivityController>();
  activityController.addHistory(ActivityHistory(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "Mencari ${targetObject.value}",
    image: _getImageForObject(targetObject.value),
    date: DateTime.now(),
    isCompleted: false,
    instruksi: instruksi.value,
  ));
}
String _getImageForObject(String object) {
  final objectImages = {
    "BOLA": 'assets/images/f2.cariobjek/1.png',
    "BOTOL": 'assets/images/f2.cariobjek/2.png',
    "KURSI": 'assets/images/f2.cariobjek/3.png',
    "TEMPAT TIDUR": 'assets/images/f2.cariobjek/5.png',
    "TAS": 'assets/images/f2.cariobjek/6.png',
    "TELEVISI": 'assets/images/f2.cariobjek/4.png',
  };
  
  return objectImages[object] ?? 'assets/images/defaulthistory.png';
}
Widget _buildTimeoutDialog() {
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(30),
    child: Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animasi crying image
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Image.asset(
                  'assets/images/crying.png', // Pastikan path ini benar
                  width: 180,
                  height: 180,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            "Waktu Habis!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Yah, waktu sudah habis.\nJangan menyerah, coba lagi ya!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, height: 1.4),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.CARIOBJEK);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "COBA LAGI",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  void onClose() {
  // Hentikan semua timer
  _detectionTimer?.cancel();
  _countdownTimer?.cancel();
  
  // Hentikan TTS dan semua antrian suara
  _tts.stop();
  _speechQueue.clear();
  isSpeaking.value = false;
  
  // Hentikan speech recognition
  if (_speech.isListening) {
    _speech.stop();
  }
  isListening.value = false;
  
  // Lepas resource kamera
  if (isCameraInitialized.value) {
    cameraController.dispose();
  }
  
  // Reset semua state
  countdown.value = 20;
  recognizedText.value = '';
  isProcessingSpeech.value = false;
  
  super.onClose();
}
}
