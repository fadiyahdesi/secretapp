import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class LooknhearController extends GetxController {
  var detectedObject = "".obs;
  final FlutterTts _flutterTts = FlutterTts();
  var isSpeaking = false.obs;
  final _speechQueue = <String>[].obs;
  final stt.SpeechToText _speech = stt.SpeechToText();
  var isListening = false.obs;
  var recognizedText = "".obs;
  final correctImage = 'assets/images/correct.png';
  final wrongImage = 'assets/images/wrong.png';
  final wrongAudio = 'assets/audio/wrong.wav';
  final correctAudio = 'assets/audio/correct.wav';
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
  // === Detected Object ===
  void detectNewObject(String newObject) {
    detectedObject.value = newObject;
  }

  RxBool isProcessingSpeech = false.obs;
  Future<void> toggleRecording() async {
    if (isListening.value) {
      stopListening();
    } else {
      if (detectedObject.value.isEmpty) {
        Get.snackbar("Info", "Tidak ada objek yang terdeteksi");
        return;
      }
      await startListening(detectedObject.value);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _flutterTts.awaitSpeakCompletion(
      true,
    ); // Tunggu sampai selesai bicara
    await _flutterTts.setSpeechRate(0.5); // Kecepatan sedang
    await _flutterTts.setPitch(1.1); // Sedikit lebih tinggi untuk suara ramah
    await _flutterTts.setLanguage("id-ID");

    try {
      // Coba set voice lebih natural (tergantung platform)
      await _flutterTts.setVoice({
        'name': 'id-id-x-dfc#female_2-local',
        'locale': 'id-ID',
      });
    } catch (e) {
      print("Voice not available, using default: $e");
    }
  }

  Future<void> speakInitialGuidance() async {
    stopSpeaking(); // Stop any existing speech
    await _speechWithPause("Ayo mulai!", pause: 400);
    await _speechWithPause("Arahkan kamera ke benda", pause: 300);
    await _speechWithPause("Kita akan belajar bersama", pause: 500);
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

      // Bicara dengan pola lebih natural
      for (int i = 0; i < 3; i++) {
        if (_speechQueue.isNotEmpty) break;

        // 1. Sebutkan objek lengkap dulu
        await _speechWithPause("Ini adalah");
        await _speechWithPause(object, pause: 800);

        // 2. Mengeja dengan ritme
        await _spellWord(object);

        // 3. Beri jeda antar pengulangan
        await Future.delayed(const Duration(milliseconds: 1200));
      }

      // Instruksi dengan kalimat lebih natural
      if (_speechQueue.isEmpty) {
        await _speechWithPause("Sekarang", pause: 400);
        await _speechWithPause("coba kamu ucapkan", pause: 300);
        await _speechWithPause(object, pause: 800);
      }
    }
    isSpeaking.value = false;
  }

  Future<void> _spellWord(String word) async {
    final syllables = _splitIntoSyllables(word);

    await _speechWithPause(" ", pause: 500);

    for (int i = 0; i < syllables.length; i++) {
      // Beri penekanan berbeda di suku kata terakhir
      if (i == syllables.length - 1) {
        await _flutterTts.setPitch(1.3); // Naikkan pitch untuk penekanan
        await _flutterTts.speak(syllables[i]);
        await _flutterTts.setPitch(1.1); // Kembalikan ke normal
      } else {
        await _speechWithPause(syllables[i], pause: 400);
      }

      // Jeda lebih panjang antar suku kata
      if (i < syllables.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<void> _speechWithPause(String text, {int pause = 300}) async {
    await _flutterTts.speak(text);
    await Future.delayed(Duration(milliseconds: pause));
  }

  void _checkSpeechMatch() async {
    final input = recognizedText.value.toLowerCase().trim();
    final target = detectedObject.value.toLowerCase().trim();

    await _flutterTts.stop();

    if (input == target) {
      // Feedback lebih ekspresif
      await _speechWithPause("Hore!", pause: 400);
      await _speechWithPause("Kamu benar!", pause: 300);
      await _speechWithPause("$target", pause: 400);
      await _speechWithPause("Ayo lanjutkan!", pause: 500);

      Get.dialog(_buildFeedbackDialog(true, target), barrierDismissible: false);
    } else {
      // Feedback lebih mendukung
      await _speechWithPause("Oops...", pause: 500);
      await _speechWithPause("Hampir tepat!", pause: 400);
      await _speechWithPause("Coba lagi ya", pause: 600);

      Get.dialog(
        _buildFeedbackDialog(false, target),
        barrierDismissible: false,
      );
    }

    await Future.delayed(const Duration(seconds: 3));
    Get.back();
  }

  Widget _buildFeedbackDialog(bool isCorrect, String object) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.5, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    isCorrect ? correctImage : wrongImage,
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 15),
                  Text(
                    isCorrect ? "Selamat!" : "Ayo coba lagi",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.orange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    isCorrect
                        ? "Kamu berhasil mengucapkan\n\"$object\""
                        : "Ucapkan \"$object\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

      // Aturan khusus untuk konsonan berurutan
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

      // Aturan khusus untuk suku kata akhir
      if (i == word.length - 1) {
        syllables.add(currentSyllable);
      }
      // Split setelah vokal (kecuali akhir kata)
      else if (isVowel && !_isVowel(word[i + 1])) {
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

  void stopSpeaking() {
    _flutterTts.stop();
    _speechQueue.clear();
    isSpeaking.value = false;
  }

  Future<void> startListening(String expectedObject) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          isListening.value = false;
          isProcessingSpeech.value = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            _checkSpeechMatch();
            isProcessingSpeech.value = false;
          });
        }
      },
      onError: (error) {
        isListening.value = false;
        isProcessingSpeech.value = false;
        print("STT Error: $error");
      },
    );

    if (available) {
      isListening.value = true;
      recognizedText.value = "";
      _speech.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
        },
        pauseFor: const Duration(seconds: 2),
        listenFor: const Duration(seconds: 5),
        localeId: "id_ID",
      );
    } else {
      Get.snackbar("Error", "Speech recognition not available");
    }
  }

  void resetAllSpeech() {
    stopSpeaking(); // Hentikan semua ucapan
    recognizedText.value = ""; // Reset teks yang diakui
    detectedObject.value = ""; // Reset objek terdeteksi
    isProcessingSpeech.value = false; // Reset status pemrosesan
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
    _checkSpeechMatch();
  }

  @override
  void onClose() {
    stopSpeaking();
    super.onClose();
  }
}
