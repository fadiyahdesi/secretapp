import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bicaraku/app/data/controllers/user_controller.dart';
import 'package:bicaraku/app/data/controllers/total_points_controller.dart';
import 'package:bicaraku/app/data/models/activity_history.dart';
import 'package:bicaraku/core/network/api_constant.dart';
import 'package:bicaraku/core/network/dio_client.dart';
import 'package:bicaraku/app/routes/app_routes.dart';

class ActivityController extends GetxController {
  final RxList<ActivityHistory> histories = <ActivityHistory>[].obs;
  final RxBool isLoading = false.obs;

  final _dioClient = Get.put(DioClient());
  final String storageKeyPrefix = 'activity_histories_';
  final int maxHistories = 10;

  String get storageKey {
    final user = Get.find<UserController>().user;
    return '$storageKeyPrefix${user?.id ?? "unknown"}';
  }

  @override
  void onInit() {
    super.onInit();
    loadHistories();
  }

  /// Load from server. Jika gagal, fallback ke local storage
  Future<void> loadHistories() async {
    isLoading.value = true;
    try {
      final response = await _dioClient.get(ApiConstants.activities);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final items = data.map((json) => ActivityHistory.fromJson(json)).toList();
        histories.assignAll(items);
        await _saveToLocal(items);
      } else {
        await _loadFromLocal();
      }
    } catch (e) {
      print("Error loading from API: $e");
      await _loadFromLocal();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addHistory(ActivityHistory newHistory) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.activities,
        data: newHistory.toJson(),
      );

      if (response.statusCode == 201) {
        await loadHistories();
        _refreshPoints();
        Get.snackbar("Berhasil", "Aktivitas berhasil ditambahkan!");
      }
    } catch (e) {
      print("Error adding history: $e");

      // Fallback offline: generate ID dan simpan lokal
      final localId = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';
      final localHistory = newHistory.copyWith(id: localId);
      histories.insert(0, localHistory);

      // Batas max history lokal
      if (histories.length > maxHistories) {
        histories.removeRange(maxHistories, histories.length);
      }

      await _saveToLocal(histories);
      Get.snackbar("Offline", "Aktivitas disimpan secara lokal");
    }
  }

  Future<void> removeHistory(String id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.activities}/$id');
      if (response.statusCode == 200) {
        histories.removeWhere((h) => h.id == id);
        await _saveToLocal(histories);
        Get.snackbar("Berhasil", "Aktivitas berhasil dihapus.");
      } else {
        Get.snackbar("Error", "Gagal menghapus aktivitas.");
      }
    } catch (e) {
      print("Error removing history: $e");
      Get.snackbar("Offline", "Tidak terhubung. Hapus gagal.");
    }
  }

  Future<void> clearAllHistories() async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Hapus Semua Riwayat"),
        content: const Text("Apakah Anda yakin ingin menghapus semua riwayat aktivitas?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text("Batal")),
          TextButton(onPressed: () => Get.back(result: true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    if (Get.currentRoute != Routes.HISTORY) {
      Get.snackbar("Gagal", "Aksi ini hanya diizinkan dari halaman Riwayat");
      return;
    }

    try {
      final response = await _dioClient.delete(ApiConstants.activities);
      if (response.statusCode == 200) {
        histories.clear();
        await _removeLocal();
        Get.snackbar("Berhasil", "Semua riwayat aktivitas telah dihapus");
      } else {
        Get.snackbar("Error", "Gagal menghapus dari server");
      }
    } catch (e) {
      print("Error clearing histories: $e");
      Get.snackbar("Offline", "Tidak terhubung. Tidak dapat hapus semua.");
    }
  }

  // -----------------------
  // LOCAL STORAGE SUPPORT
  // -----------------------

  Future<void> _saveToLocal(List<ActivityHistory> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList();
    prefs.setString(storageKey, json.encode(jsonList));
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        histories.assignAll(jsonList.map((e) => ActivityHistory.fromJson(e)).toList());
      } catch (e) {
        print("Error parsing local histories: $e");
      }
    }
  }

  Future<void> _removeLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }

  void _refreshPoints() {
    if (Get.isRegistered<TotalPointsController>()) {
      Get.find<TotalPointsController>().loadTotalPoints();
    } else {
      Get.put(TotalPointsController()).loadTotalPoints();
    }
  }
}
