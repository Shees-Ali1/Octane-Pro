import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../untils/utils.dart';
import '../Auth/login_page.dart';


class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser; // Get current user

  ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the first letter of the email
    String profileLetter = user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.summryRed,
        title: Text('Profile', style: AppColors.headingStyle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture Section
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.summryRed,
              child: user?.photoURL != null
                  ? CircleAvatar(
                radius: 46,
                backgroundImage: NetworkImage(user!.photoURL!),
              )
                  : Text(
                profileLetter,
                style: AppColors.headingStyle.copyWith(fontSize: 40),
              ),
            ),
            const SizedBox(height: 20),

            // User Email
            Text(
              user?.email ?? 'No Email',
              style: AppColors.headingStyle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),

            // Profile Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkBlack,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  _profileInfoRow('Role', 'First Responder'),
                  // Divider(color: AppColors.primaryWhiteText),
                  // _profileInfoRow('Location', 'City, Country'),
                  Divider(color: AppColors.primaryWhiteText),
                  _profileInfoRow('Joined', 'January 2023'),
                ],
              ),
            ),
            const Spacer(),

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Firebase logout functionality
               Get.offAll(LoginPage());
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.summryRed,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Log Out',
                style: AppColors.headingStyle.copyWith(
                  fontSize: 16,
                  color: AppColors.primaryWhiteText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile Info Row Widget
  Widget _profileInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppColors.descriptionStyle,
          ),
          Text(
            value,
            style: AppColors.subtitleStyle.copyWith(color: AppColors.primaryWhiteText),
          ),
        ],
      ),
    );
  }
}
