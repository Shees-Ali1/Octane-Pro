import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:octane_pro/Screens/Auth/login_page.dart';
import 'package:octane_pro/untils/assetImages.dart';
import 'package:octane_pro/untils/utils.dart'; // Assuming AppColors is defined here

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late Animation<Offset> _imageSlideAnimation;

  late AnimationController _textAnimationController;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Image Animation - Slide from right to left
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Duration for the slide animation
    );

    // Slide from right (1, 0) to center (0, 0)
    _imageSlideAnimation = Tween<Offset>(begin: Offset(2, 0), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Text Animation - Fade in from center
    _textAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Duration for the text fade animation
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the image animation first
    _imageAnimationController.forward();

    // Start the text animation after the image animation is complete
    Future.delayed(Duration(seconds: 2), () {
      _textAnimationController.forward();
      Future.delayed(Duration(seconds: 2), () {

        Get.off(LoginPage());
      });

    });


  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundColorWhite, // Second color
              AppColors.backgroundColor, // First color
            ],
            stops: [
              0.0,
              0.5, // First color ends at 50% height
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Image with Slide Animation from right to left
              SlideTransition(
                position: _imageSlideAnimation,
                child: Align(
                  alignment: Alignment.centerRight, // Align the image to the right side
                  child: Image.asset(
                    AppImages.splashLeaf,

                  ),
                ),
              ),
              // Text with Fade Animation after Image completes
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SizedBox(
                      width: 275.w,
                      child: Text(
                        "Get All Insights on your fingertips!",
                        textAlign: TextAlign.center,
                        style: AppColors.headingStyle.copyWith(fontSize: 35.sp),
                      ),
                    ),
                  ),
                ),
              ),
          
          
          
              Positioned(
                right: 0,
                bottom: 40.h,
                child: Center(
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SizedBox(
                      width: 275.w,
                      child: Padding(
                        padding:  EdgeInsets.only(left: 70.0.w),
                        child: RichText(
                          textAlign: TextAlign.center, // Align text to center
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Powered by: \n", // First part of the text
                                style: AppColors.headingStyle.copyWith(
                                  fontSize: 12.sp, // Adjust font size for this part
                                  color: Colors.white, // Customize color
                                ),
                              ),
                              TextSpan(
                                text: "SoftThrive", // Second part of the text with different style
                                style: AppColors.headingStyle.copyWith(
                                  fontSize: 25.sp, // Larger font size
                                  color: AppColors.forgot, // Primary color or any color you prefer
                                  fontWeight: FontWeight.bold, // Make it bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
          
            ],
          ),
        ),
      ),
    );
  }
}
