import 'package:get/get.dart';

class HomeController extends GetxController {
  var username = ''.obs;

  void setUsername(String value) {
    username.value = value;
  }
}
