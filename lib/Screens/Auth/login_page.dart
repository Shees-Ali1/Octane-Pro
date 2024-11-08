import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:octane_pro/GetxControllers/AuthController.dart';
import 'package:octane_pro/GetxControllers/Sale-Controller/SaleSummaryController.dart';
import 'package:octane_pro/Screens/Auth/register_page.dart';

import '../../CustomWidgets/CustomInputField.dart';
import '../../NavBar/bottom_Bar.dart';
import '../../untils/assetImages.dart';
import '../../untils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final Authcontroller authcontroller = Get.find();
  final SaleSummaryController saleSummaryController =
  Get.put(SaleSummaryController());

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showValidationMessage(String message) {
    Get.snackbar(
      "Validation Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 10,
      icon: Icon(Icons.warning, color: Colors.white),
    );
  }

  void _validateAndLogin() {
    final email = authcontroller.emailController.text.trim();
    final password = authcontroller.passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showValidationMessage('Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      _showValidationMessage('Please enter your password');
      return;
    }

    // Call login method if validation passes
    authcontroller.loginUser();
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
              AppColors.backgroundColorWhite,
              AppColors.backgroundColor,
            ],
            stops: [
              0.0,
              0.5,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 80.h,
              right: 0,
              left: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  AppImages.OCTANEpro,
                  height: 235.h,
                  width: 222.w,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: 516.h,
                  width: 375.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.loginBottom),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 64.h),
                        Text(
                          'Login',
                          style: AppColors.headingStyle
                              .copyWith(color: Colors.white, fontSize: 35.sp),
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: 311.w,
                          child: CustomInputField(
                            controller: authcontroller.emailController,
                            label: 'Your Email',
                            svgIconPath: AppIcons.emailIcon,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        SizedBox(
                          width: 311.w,
                          child: CustomInputField(
                            controller: authcontroller.passwordController,
                            label: 'Your Password',
                            obscureText: true,
                            svgIconPath: AppIcons.passwordIcon,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Obx(
                                      () => GestureDetector(
                                    onTap: () {
                                      authcontroller.checkBox.value =
                                      !authcontroller.checkBox.value;
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: AppColors.borderColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          authcontroller.checkBox.value
                                              ? Icons.check
                                              : null,
                                          size: 16,
                                          color: AppColors.bottomColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "Remember information",
                                  style: AppColors.headingStyle.copyWith(
                                      color: Colors.white, fontSize: 10.sp),
                                ),
                                Spacer(),
                                Text(
                                  "Forgot Password",
                                  style: AppColors.headingStyle.copyWith(
                                      color: AppColors.forgot, fontSize: 15.sp),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 70.h),
                        SizedBox(
                          width: 311.w,
                          height: 61.h,
                          child: ElevatedButton(
                            onPressed: _validateAndLogin,
                            child: authcontroller.isLoading.value
                                ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                                : Text(
                              'Login',
                              style: AppColors.headingStyle.copyWith(
                                color: AppColors.bottomColor,
                                fontSize: 19.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.inputBtnColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                side: BorderSide(
                                  color: AppColors.borderColor,
                                  width: 4.0,
                                ),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        RichText(
                          text: TextSpan(
                            style: AppColors.headingStyle.copyWith(
                              color: AppColors.primaryTextColor,
                              fontSize: 15.sp,
                            ),
                            children: [
                              TextSpan(
                                text: "Register with new account? ",
                              ),
                              TextSpan(
                                text: "Register",
                                style: AppColors.headingStyle.copyWith(
                                  color: AppColors.forgot,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.off(() => RegisterPage());
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
