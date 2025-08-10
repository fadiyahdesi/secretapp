import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bicaraku/app/data/models/user_model.dart';
import 'package:bicaraku/app/data/controllers/activity_controller.dart';
import 'package:bicaraku/app/data/controllers/total_points_controller.dart';

class UserController extends GetxController {
  final Rxn<UserModel> _user = Rxn<UserModel>();
  final box = GetStorage();

  UserModel? get user => _user.value;
  Rxn<UserModel> get userRx => _user;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();

    ever(userRx, (_) {
      if (_user.value != null) {
        Get.put(TotalPointsController()).loadTotalPoints();
      }
    });

    ever(userRx, (_) {
      if (Get.isRegistered<ActivityController>()) {
        final activityController = Get.find<ActivityController>();
        if (_user.value != null && _user.value!.id.isNotEmpty) {
          activityController.loadHistories();
        }
      }
    });
  }

  void setUser(UserModel u) {
    _user.value = u;
    _saveUserToStorage(u);
  }

  void clearUser() {
    _user.value = null;
    box.remove('user');
  }

  void setBasicUser(String name, String email) {
    final newUser = UserModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      provider: 'email',
      photoUrl: '',
      lastLogin: DateTime.now().toIso8601String(),
      points: 0,
    );
    setUser(newUser);
  }

  void updateUserInfo({
    String? name,
    String? email,
    String? photoUrl,
    int? points,
  }) {
    if (_user.value != null) {
      final updatedUser = _user.value!.copyWith(
        name: name ?? _user.value!.name,
        email: email ?? _user.value!.email,
        photoUrl: photoUrl ?? _user.value!.photoUrl,
        points: points ?? _user.value!.points,
      );
      setUser(updatedUser);
    }
  }

  void addPoints(int points) {
    if (_user.value != null) {
      final updatedUser = _user.value!.copyWith(
        points: _user.value!.points + points,
      );
      setUser(updatedUser);
      update(); // Notify listeners
    }
  }

  void _saveUserToStorage(UserModel user) {
    box.write('user', user.toJson());
  }

  void _loadUserFromStorage() {
    final storedUserMap = box.read('user');
    if (storedUserMap != null && storedUserMap is Map<String, dynamic>) {
      try {
        _user.value = UserModel.fromJson(storedUserMap);
      } catch (e) {
        print('Error parsing user data from storage: $e');
        _user.value = null;
        box.remove('user');
      }
    } else {
      _user.value = null;
    }
  }
}
