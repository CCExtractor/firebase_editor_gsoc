import 'package:firebase_editor_gsoc/views/starter_screen_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// StarterScreen1 is a stateless widget that displays the first screen
/// in the app's onboarding flow. It introduces the app's name and brand,
/// and allows users to proceed to the next screen (StarterScreen2) by
/// tapping anywhere on the screen or by pressing the forward arrow icon.
class StarterScreen1 extends StatelessWidget {
  const StarterScreen1({super.key});

  /// The build method defines the UI of the StarterScreen1.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set the background color of the screen
      body: GestureDetector(
        // GestureDetector listens for tap events on the entire screen
        onTap: () {
          // Navigate to StarterScreen2 using GetX for navigation
          Get.to(const StarterScreen2());
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align content to the bottom
                children: [
                  // Column to display the app's name
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the word "Firebase"
                      Text(
                        'Firebase',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      // Stack to create a highlighted background effect around the word "Editor"
                      Stack(
                        children: [
                          // Background container for the word "Editor"
                          Container(
                            height: 70,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.amber
                                  .withOpacity(1.0), // Background color
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(
                                  40), // Rounded corners to make it oval
                            ),
                          ),
                          // Positioned text "Editor" inside the background container
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Editor',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50.0, // Space between the app name and the image
                  ),
                  // Stack to display the welcome image
                  Stack(
                    children: [
                      const SizedBox(height: 2.0),
                      Image.asset(
                          'assets/welcome.png'), // Display welcome image
                    ],
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
                onPressed: () {
                  // Navigate to StarterScreen2 using GetX for navigation
                  Get.to(const StarterScreen2());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
