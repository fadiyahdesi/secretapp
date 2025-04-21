import 'package:bicaraku/app/modules/home/bindings/home_binding.dart';
import 'package:bicaraku/app/modules/home/bindings/login_binding.dart';
import 'package:bicaraku/app/modules/home/bindings/profil_binding.dart';
import 'package:bicaraku/app/modules/home/bindings/register_binding.dart';
import 'package:bicaraku/app/modules/home/views/home_view.dart';
import 'package:bicaraku/app/modules/home/views/login_view.dart';
import 'package:bicaraku/app/modules/home/views/looknhear_view.dart';
import 'package:bicaraku/app/modules/home/views/profil_view.dart';
import 'package:bicaraku/app/modules/home/views/register_view.dart';
import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(name: '/looknhear', page: () => const LooknhearView()),
  ];
}
