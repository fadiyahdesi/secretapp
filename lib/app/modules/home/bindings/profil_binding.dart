import 'package:bicaraku/app/modules/home/controllers/profil_controller.dart';
import 'package:get/get.dart';

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilController>(() => ProfilController());
  }
}
