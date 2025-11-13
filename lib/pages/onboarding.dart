import 'package:chatapp_real/services/auth.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width * 0.07;
    final double imageHeight = size.height * 0.45;
    final double titleFontSize = size.width * 0.055;
    final double subtitleFontSize = size.width * 0.035;
    final double buttonHeight = size.height * 0.07;
    final double buttonFontSize = size.width * 0.045;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            height: size.height - MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// 🖼️ Onboarding Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Image.asset(
                    "images/onboard.png",
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),

                /// 📝 Main Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding * 0.8,
                  ),
                  child: Text(
                    "Enjoy the new experience of chatting with global friends",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),

                /// 💬 Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding * 1.2,
                  ),
                  child: Text(
                    "Connect people around the world for free",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),

                /// 🟣 Google Sign-In Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 10,
                  ),
                  child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(30),
                    child: GestureDetector(
                      onTap: () {
                        Authmethods().signinWithGoogle(context);
                      },
                      child: Container(
                        height: buttonHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff703eff),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "images/search.png",
                              height: buttonHeight * 0.6,
                              width: buttonHeight * 0.6,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: size.width * 0.03),
                            Text(
                              "Sign in with Google",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}