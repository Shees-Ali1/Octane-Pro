import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../NavBar/bottom_Bar.dart';

class Authcontroller extends GetxController {
  var checkBox = false.obs;
  RxBool isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void loginUser() async {
    try {
      isLoading.value = true;

      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
        isLoading.value = false;
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      if (FirebaseAuth.instance.currentUser!.uid != null) {
        isLoading.value = false;
        Get.offAll(const BottomNav());
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
        isLoading.value = false;
      } else if (e.code == 'invalid-credential') {
        Get.snackbar("Error", "Wrong password provided for that user.",
            backgroundColor: Colors.white, colorText: Colors.black);
        isLoading.value = false;
      } else {
        Get.snackbar("Error", "Login failed. Error code: ${e.code}",
            backgroundColor: Colors.white, colorText: Colors.black);
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;

      print('Error Login Failed $e');
    }finally{
      isLoading.value = false;

    }
  }
}
