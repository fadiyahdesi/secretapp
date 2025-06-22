import 'dart:convert';
import 'dart:math';

import 'package:bicaraku/app/data/models/activity_history.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityController extends GetxController {
  final RxList<ActivityHistory> histories = <ActivityHistory>[].obs;
  final String storageKey = 'activity_histories';
  final int maxHistories = 10;

  @override
  void onInit() {
    super.onInit();
    loadHistories();
  }

  Future<void> loadHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(storageKey);

    histories.clear();
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        final loadedHistories =
            jsonList.map((json) => ActivityHistory.fromJson(json)).toList();
        histories.assignAll(loadedHistories);
      } catch (e) {
        print("Error loading histories: $e");
      }
    }
    update();
  }

  Future<void> saveHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        histories.reversed.map((history) => history.toJson()).toList();
    prefs.setString(storageKey, json.encode(jsonList));
  }

  void addHistory(ActivityHistory newHistory) {
    // Generate ID unik dengan kombinasi timestamp dan random number
    final uniqueId =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
    final historyWithId = newHistory.copyWith(id: uniqueId);

    // Tambahkan ke awal list (riwayat terbaru)
    histories.insert(0, historyWithId);

    // Batasi jumlah riwayat yang disimpan
    if (histories.length > maxHistories) {
      histories.removeRange(maxHistories, histories.length);
    }

    // Simpan perubahan
    saveHistories();
    update(); // Paksa update GetX
  }
  void updateHistoryStatus(String id, bool isCompleted) {
    final index = histories.indexWhere((h) => h.id == id);
    if (index != -1) {
      histories[index] = histories[index].copyWith(isCompleted: isCompleted);
      saveHistories();
      update();
    }
  }
}
