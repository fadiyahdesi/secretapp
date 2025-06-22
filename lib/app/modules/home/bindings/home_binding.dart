import 'package:bicaraku/app/data/controllers/activity_controller.dart';
import 'package:bicaraku/app/data/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:bicaraku/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<ActivityController>(() => ActivityController());
    Get.put(ActivityController(), permanent: true);
    Get.find<ActivityController>().loadHistories();
  }
}
