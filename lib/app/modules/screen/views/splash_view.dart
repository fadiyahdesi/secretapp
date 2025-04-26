import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashState();
}

class _SplashState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.offNamed(Routes.SPLASH2);
      },
      child: const Scaffold(
        body: Center(
          child: Image(
            image: AssetImage('assets/images/splashscreen/splash.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
