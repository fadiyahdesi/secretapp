import 'package:bicaraku/app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final Rxn<UserModel> _user = Rxn<UserModel>();
  final box = GetStorage();

  UserModel? get user => _user.value;
  Rxn<UserModel> get userRx => _user;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void setUser(UserModel u) {
    userRx.value = user;
    _user.value = u;
    _saveUserToStorage(u);
    update();
    // Histori login disimpan oleh ProfilController → addHistory("login", ...)
  }

  void clearUser() {
    _user.value = null;
    box.remove('user');
  }

  void setBasicUser(String name, String email) {
    final newUser = UserModel(
      id: '',
      name: name,
      email: email,
      provider: 'email',
      photoUrl: '',
      lastLogin: DateTime.now().toIso8601String(),
    );
    setUser(newUser);
  }

  void _saveUserToStorage(UserModel user) {
    box.write('user', {
      '_id': user.id,
      'name': user.name,
      'email': user.email,
      'provider': user.provider,
      'photoUrl': user.photoUrl,
      'lastLogin': user.lastLogin,
    });
  }

  void _loadUserFromStorage() {
    final storedUser = box.read('user');
    if (storedUser != null) {
      try {
        _user.value = UserModel.fromJson(Map<String, dynamic>.from(storedUser));
      } catch (e) {
        print('Gagal load user dari storage: $e');
        _user.value = null;
      }
    }
  }

  void updateUserInfo({String? name, String? email, String? photoUrl}) {
    if (_user.value != null) {
      final currentUser = _user.value!;
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
        photoUrl: photoUrl ?? currentUser.photoUrl,
      );
      setUser(updatedUser);
    }
  }
}
