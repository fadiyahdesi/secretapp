//part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const PROFIL = _Paths.PROFIL;
  static const LOOKNHEAR = _Paths.LOOKNHEAR;
}

abstract class _Paths {
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const PROFIL = '/profil';
  static const LOOKNHEAR = '/looknhear';
}
