import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lifetrack/screens/sign_in.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(child: LottieBuilder.asset("assets/images/splash.json")),
        ],
      ),
      nextScreen: SignIn(),
      backgroundColor: Color(0xFFFFFFFF),
      splashIconSize: 400,
    );
  }
}
