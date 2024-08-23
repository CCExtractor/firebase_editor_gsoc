import 'package:firebase_editor_gsoc/user_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// StarterScreen3 is a stateless widget that displays the third and final
/// starter screen for the app. It allows users to proceed to the login screen
/// by tapping anywhere on the screen or by pressing the forward arrow icon.
class StarterScreen3 extends StatelessWidget {
  const StarterScreen3({super.key});

  /// The build method defines the UI of the StarterScreen3.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set the background color of the screen
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display an image at the center of the screen
                  Image.asset('assets/mobile.png'),
                  const SizedBox(
                      height: 20.0), // Space between the image and text
                  Padding(
                    padding: const EdgeInsets.all(
                        30.0), // Padding around the text content
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the main title text
                        Text(
                          'Now Available',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        // Display the subtitle text
                        Text(
                          'at the comfort of your ',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        // A stack to create an effect around the word "Phone!"
                        Stack(
                          children: [
                            // Background container for the word "Phone!"
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.amber
                                    .withOpacity(1.0), // Background color
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(
                                    40), // Rounded corners to make it oval
                              ),
                            ),
                            // Positioned text "Phone!" inside the background container
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right:
                                      40.0), // Right padding to center the text
                                  child: Text(
                                    'Phone!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Positioned icon in the top-right corner for navigation
            Positioned(
              top: 16.0,
              right: 16.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white), // Forward arrow icon
                onPressed: () async {
                  // Handle the tap on the icon to navigate to the login screen
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasSeenStarterScreens',
                      true); // Mark that the starter screens have been seen
                  Get.offAll(LoginScreen()); // Navigate to the LoginScreen and clear navigation stack
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
