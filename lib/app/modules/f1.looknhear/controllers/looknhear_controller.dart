import 'package:get/get.dart';

class LooknhearController extends GetxController {
  var detectedObject = "".obs;

  void detectNewObject(String newObject) {
    detectedObject.value = newObject;
  }

  void refreshDetection() {
    // Simulasi: ganti objek secara random (di dunia nyata ini hasil dari ML model)
    final simulatedObjects = ['Gelas', 'Kursi', 'Bola', 'Boneka', 'TV', 'Tas'];
    simulatedObjects.shuffle();
    detectedObject.value = simulatedObjects.first;
  }

  void speakDetectedObject() {
    // Di dunia nyata: gunakan TTS atau evaluasi suara pengguna
    print("User said: ${detectedObject.value}");
  }
}
