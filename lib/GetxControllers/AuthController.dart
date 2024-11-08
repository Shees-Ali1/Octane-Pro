import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octane_pro/Screens/Auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../NavBar/bottom_Bar.dart';

class Authcontroller extends GetxController {
  var checkBox = false.obs;
  RxBool isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Method to log in the user
  void loginUser() async {
    try {
      isLoading.value = true;

      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
        isLoading.value = false;
        return;
      }

      // Perform Firebase login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // If login is successful, save the login status in SharedPreferences
      if (FirebaseAuth.instance.currentUser!.uid != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true); // Save login status

        isLoading.value = false;

        // Navigate to the BottomNav screen
        Get.offAll(const BottomNav());

        // Clear the input fields
        emailController.clear();
        passwordController.clear();
      } else {
        isLoading.value = false;
        Get.snackbar("Error", "Incorrect OTP",
            backgroundColor: Colors.white, colorText: Colors.black);
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      if (e.code == 'user-not-found') {
        Get.snackbar("Error", "No user found for that email.",
            backgroundColor: Colors.white, colorText: Colors.black);
      } else if (e.code == 'invalid-credential') {
        Get.snackbar("Error", "Wrong password provided for that user.",
            backgroundColor: Colors.white, colorText: Colors.black);
      } else {
        Get.snackbar("Error", "Login failed. Error code: ${e.code}",
            backgroundColor: Colors.white, colorText: Colors.black);
      }
    } catch (e) {
      isLoading.value = false;
      print('Error Login Failed $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check login status on app start
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Get.offAll(() => const BottomNav());
    }
  }

  // Logout method to remove the login status
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn'); // Remove login status

    // Log the user out from Firebase
    await FirebaseAuth.instance.signOut();

    // Navigate to the Login page
    Get.offAll(() => const LoginPage());
  }
}
