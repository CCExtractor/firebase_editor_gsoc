import 'package:firebase_editor_gsoc/views/screens/starter_screens/starter_screen_2.dart';
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
      body: Stack(
        children: [
          Column(
            children: [
              const Spacer(), // Pushes the app name to the top
              // Column to display the app's name
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display the word "Firebase"
                  Text(
                    'Firebase',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20.0), // Space between "Firebase" and "Editor"
                  // Stack to create a highlighted background effect around the word "Editor"
                  Stack(
                    children: [
                      // Background container for the word "Editor"
                      Container(
                        height: 70,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(1.0), // Background color
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(40), // Rounded corners to make it oval
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
              const Spacer(), // Pushes the image to the bottom
              // Stack to display the welcome image
              Image.asset('assets/welcome.png'), // Display welcome image
            ],
          ),
          // Positioned icon in the top-right corner for navigation
          Positioned(
            top: 30.0,
            right: 16.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white), // Forward arrow icon
              onPressed: () {
                // Navigate to StarterScreen2 using GetX for navigation
                Get.to(const StarterScreen2());
              },
            ),
          ),
        ],
      ),
    );
  }
}
