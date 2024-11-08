import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:octane_pro/Screens/Auth/login_page.dart';

import '../../CustomWidgets/CustomInputField.dart';
import '../../untils/assetImages.dart';
import '../../untils/utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pumpNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  var isLoading = false.obs;

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
    nameController.dispose();
    pumpNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

  Future<void> _registerUser() async {
    if (nameController.text.isEmpty) {
      _showValidationMessage('Please enter your name');
      return;
    }
    if (pumpNameController.text.isEmpty) {
      _showValidationMessage('Please enter your pump name');
      return;
    }
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      _showValidationMessage('Please enter a valid email');
      return;
    }
    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      _showValidationMessage('Password must be at least 6 characters');
      return;
    }
    if (confirmPasswordController.text != passwordController.text) {
      _showValidationMessage('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      // Register the user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save additional user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': nameController.text.trim(),
        'pumpName': pumpNameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      // Navigate to the login page after successful registration
      Get.off(() => LoginPage());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Unknown error",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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
              top: 50.h,
              right: 0,
              left: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  AppImages.OCTANEpro,
                  height: 120.h,
                  width: 100.w,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: 650.h,
                  width: 375.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.loginBottom),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 90.h),
                          Text(
                            'Register',
                            style: AppColors.headingStyle
                                .copyWith(color: Colors.white, fontSize: 35.sp),
                          ),
                          SizedBox(height: 15.h),
                          SizedBox(
                            width: 311.w,
                            child: CustomInputField(
                              controller: nameController,
                              label: 'Name',
                              svgIconPath: AppIcons.userIcon,
                              validator: null,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 311.w,
                            child: CustomInputField(
                              controller: pumpNameController,
                              // svgIconPath: AppIcons.pump,
                              label: 'Pump Name',
                              validator: null,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 311.w,
                            child: CustomInputField(
                              controller: emailController,
                              label: 'Email',
                              svgIconPath: AppIcons.emailIcon,
                              validator: null,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 311.w,
                            child: CustomInputField(
                              controller: passwordController,
                              label: 'Password',
                              obscureText: true,
                              svgIconPath: AppIcons.passwordIcon,
                              validator: null,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 311.w,
                            child: CustomInputField(
                              controller: confirmPasswordController,
                              label: 'Confirm Password',
                              obscureText: true,
                              svgIconPath: AppIcons.passwordIcon,
                              validator: null,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Obx(
                                () => SizedBox(
                              width: 311.w,
                              height: 61.h,
                              child: ElevatedButton(
                                onPressed: isLoading.value ? null : _registerUser,
                                child: isLoading.value
                                    ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                                    : Text(
                                  'Register',
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
                          ),
                          SizedBox(height: 8.h),
                          RichText(
                            text: TextSpan(
                              style: AppColors.headingStyle.copyWith(
                                color: AppColors.primaryTextColor,
                                fontSize: 15.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: "Already have an account? ",
                                ),
                                TextSpan(
                                  text: "Login",
                                  style: AppColors.headingStyle.copyWith(
                                    color: AppColors.forgot,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.off(() => LoginPage());
                                    },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
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
