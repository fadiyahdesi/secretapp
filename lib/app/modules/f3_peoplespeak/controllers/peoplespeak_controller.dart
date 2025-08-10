import 'package:bicaraku/app/data/controllers/activity_controller.dart';
import 'package:bicaraku/app/data/controllers/total_points_controller.dart';
import 'package:bicaraku/app/data/models/activity_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BerbicaraController extends GetxController {
  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final TotalPointsController pointsController = Get.put(
    TotalPointsController(),
  );
  final ActivityController activityController = Get.find<ActivityController>();

  var currentSentence = "".obs;
  var isListening = false.obs;
  var recognizedText = "".obs;
  var ttsInitialized = false.obs;
  var speechInitialized = false.obs;
  var isPlayingInstruction = false.obs;
  var isCancelled = false.obs;
  // State untuk melacak suku kata
  var systemSyllable = "".obs;
  var userSyllable = "".obs;
  var syllableResults = <String, bool>{}.obs;

  // PERBAIKAN 1: Tambahkan variabel untuk menyimpan path ikon dari challenge saat ini.
  var currentChallengeIconPath = "".obs;

  final int challengePoints = 20;

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

  final Map<String, List<String>> syllablePronunciations = {
    'Mobil Merah': ['Mo', 'bil', 'Me', 'rah'],
    'Botol di Meja': ['Bo', 'tol', 'di', 'Me', 'ja'],
    'Anjing Bermain dengan Bola': [
      'An',
      'jing',
      'Ber',
      'main',
      'deng',
      'an',
      'Bo',
      'la',
    ],
    'Buku Tersusun Rapi di Rak': [
      'Bu',
      'ku',
      'Ter',
      'su',
      'sun',
      'Ra',
      'pi',
      'di',
      'Rak',
    ],
    'Rusa Sedang Makan Rumput di Lapangan': [
      'Ru',
      'sa',
      'Se',
      'dang',
      'Ma',
      'kan',
      'Rum',
      'put',
      'di',
      'La',
      'pang',
      'an',
    ],
  };

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

  // PERBAIKAN 2: Ubah method `startPractice` untuk menerima `iconPath`.
  Future<void> startPractice(String sentence, String iconPath) async {
    // Simpan path ikon saat latihan dimulai. Ini akan membuatnya persisten.
    currentChallengeIconPath.value = iconPath;
    currentSentence.value = sentence; // Juga set kalimat saat ini di sini

    isPlayingInstruction.value = true;

    if (isCancelled.value) return;
    await tts.speak("Silakan ucapkan kalimat berikut:");
    await Future.delayed(const Duration(seconds: 1));

    if (isCancelled.value) return;
    await tts.speak(sentence);
    await Future.delayed(const Duration(seconds: 2));

    if (isCancelled.value) return;
    await _speakSyllables(sentence);

    isPlayingInstruction.value = false;
  }

  Future<void> _speakSyllables(String sentence) async {
    final syllables = syllablePronunciations[sentence] ?? [sentence];
    await tts.setSpeechRate(0.2);

    for (String syllable in syllables) {
      systemSyllable.value = syllable;
      await tts.speak(syllable);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    systemSyllable.value = "";
    await tts.setSpeechRate(0.3);
  }

  // PERBAIKAN 3: Ubah method `toggleRecording` agar sesuai dengan yang dipanggil di View.
  Future<void> toggleRecording(String phrase, String iconPath) async {
    // Pastikan icon path tersimpan jika-jika `startPractice` terlewat.
    if (currentChallengeIconPath.value.isEmpty) {
      currentChallengeIconPath.value = iconPath;
    }

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
      userSyllable.value = "";
      syllableResults.clear();

      final syllables = syllablePronunciations[currentSentence.value] ?? [];
      syllableResults.value = {for (var s in syllables) s: false};

      await speech.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
          _checkSyllablePronunciation(result.recognizedWords);
        },
        localeId: "id-ID",
        listenFor: const Duration(seconds: 10),
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memulai rekaman");
      isListening.value = false;
    }
  }

  void _checkSyllablePronunciation(String recognizedWords) {
    final input = recognizedWords.toLowerCase();
    final syllables = syllablePronunciations[currentSentence.value] ?? [];
    final tempResults = Map<String, bool>.from(syllableResults);

    for (String syllable in syllables) {
      if (input.contains(syllable.toLowerCase())) {
        tempResults[syllable] = true;
      }
    }
    syllableResults.value = tempResults;
  }

  // PERBAIKAN 4: Hapus parameter karena kita akan menggunakan state controller.
  Future<void> _stopListening() async {
    try {
      await speech.stop();
      isListening.value = false;
      _checkPronunciation();
    } catch (e) {
      Get.snackbar("Error", "Gagal menghentikan rekaman");
    }
  }

  // PERBAIKAN 5: Hapus parameter di sini juga.
  void _checkPronunciation() {
    final input = recognizedText.value.trim().toLowerCase();
    final target = currentSentence.value.trim().toLowerCase();

    if (input == target) {
      _showSuccessDialog();
    } else {
      _showRetryDialog();
    }
  }

  // PERBAIKAN 6: Hapus parameter dan gunakan state controller `currentChallengeIconPath`.
  void _showSuccessDialog() {
    // Simpan aktivitas langsung ke MongoDB
    activityController.addHistory(
      ActivityHistory(
        id: '', // ID akan dibuat di server
        title: "Berbicara: ${currentSentence.value}",
        image:
            currentChallengeIconPath.value, // <-- MENGGUNAKAN STATE YANG BENAR
        date: DateTime.now(),
        isCompleted: true,
        instruksi: "Ucapkan kalimat: ${currentSentence.value}",
        points: challengePoints,
      ),
    );

    pointsController.updatePoints(challengePoints);

    tts.speak(
      "Selamat! Kamu berhasil mengucapkan semua suku kata dengan benar. Kamu mendapatkan $challengePoints poin!",
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/correct.png', width: 100, height: 100),
            const SizedBox(height: 20),
            Text(
              "+$challengePoints Poin",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Pengucapanmu tepat!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Selamat! Kamu berhasil mengucapkan semua suku kata dengan benar",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Return to PeopleSpeakView
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Selesai",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRetryDialog() {
    tts.speak("Pengucapan belum tepat. Silakan coba lagi.");
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/wrong.png', width: 100, height: 100),
            const SizedBox(height: 20),
            Text(
              "Perlu Latihan Lagi",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Perhatikan pengucapan per suku kata",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildSyllableResultPreview(),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  child: const Text("Kembali", style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // PERBAIKAN 7: Panggil `startPractice` dengan path ikon yang sudah tersimpan.
                    startPractice(
                      currentSentence.value,
                      currentChallengeIconPath.value,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Ulangi",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyllableResultPreview() {
    final syllables = syllablePronunciations[currentSentence.value] ?? [];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children:
          syllables.map((syllable) {
            final isCorrect = syllableResults[syllable] ?? false;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:
                    isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    syllable,
                    style: TextStyle(
                      fontSize: 16,
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    isCorrect ? Icons.check : Icons.close,
                    size: 16,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  @override
  void onClose() {
    tts.stop();
    speech.stop();
    isCancelled.value = true;
    super.onClose();
  }
}
