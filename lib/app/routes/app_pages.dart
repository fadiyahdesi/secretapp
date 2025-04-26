import 'package:bicaraku/app/modules/f1.looknhear/views/looknhear_detect_view.dart';
import 'package:bicaraku/app/modules/f2.cariobjek/controllers/cariobjek_controller.dart';
import 'package:bicaraku/app/modules/f2.cariobjek/views/cariobjek_view.dart';
import 'package:bicaraku/app/modules/f2.cariobjek/views/cariobjekcam_view.dart';
import 'package:bicaraku/app/modules/f3.peoplespeak/views/peoplespeak_view.dart';
import 'package:bicaraku/app/modules/home/bindings/home_binding.dart';
import 'package:bicaraku/app/modules/login/bindings/login_binding.dart';
import 'package:bicaraku/app/modules/profil/bindings/profil_binding.dart';
import 'package:bicaraku/app/modules/register/bindings/register_binding.dart';
import 'package:bicaraku/app/modules/home/views/home_view.dart';
import 'package:bicaraku/app/modules/login/views/login_view.dart';
import 'package:bicaraku/app/modules/f1.looknhear/views/looknhear_view.dart';
import 'package:bicaraku/app/modules/profil/views/profil_view.dart';
import 'package:bicaraku/app/modules/register/views/register_view.dart';
import 'package:bicaraku/app/modules/screen/views/splash2_view.dart';
import 'package:bicaraku/app/modules/screen/views/splash3_view.dart';
import 'package:bicaraku/app/modules/screen/views/splash4_view.dart';
import 'package:bicaraku/app/modules/screen/views/splash5_view.dart';
import 'package:bicaraku/app/modules/screen/views/splash_view.dart';
import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // SPLASH SCREEN
    GetPage(name: Routes.SPLASH, page: () => const SplashView()),
    GetPage(name: Routes.SPLASH2, page: () => const Splash2View()),
    GetPage(name: Routes.SPLASH3, page: () => const Splash3View()),
    GetPage(name: Routes.SPLASH4, page: () => const Splash4View()),
    GetPage(name: Routes.SPLASH5, page: () => const Splash5View()),

    // LOGIN
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // REGISTER
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),

    // HOME
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // PROFIL
    GetPage(
      name: Routes.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),

    // LOOKNHEAR
    GetPage(name: '/looknhear', page: () => const LooknhearView()),
    GetPage(name: '/looknhearcam', page: () => const LooknhearDetectView()),

    // CARIOBJEK
    GetPage(name: '/cariobjek', page: () => const CariobjekView()),
    GetPage(
      name: '/cariobjekcam',
      page: () => const CariobjekcamView(),
      binding: BindingsBuilder(() {
        Get.put(CariObjekController());
      }),
    ),

    // PEOPLESPEAK
    GetPage(name: '/peoplespeak', page: () => const PeopleSpeakView()),
  ];
}
