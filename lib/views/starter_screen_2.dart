import 'package:firebase_editor_gsoc/views/starter_screen_3.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// StarterScreen2 is a stateless widget that displays the second screen
/// in the app's onboarding flow. It allows users to proceed to the next
/// starter screen (StarterScreen3) by tapping anywhere on the screen or
/// by pressing the forward arrow icon.
class StarterScreen2 extends StatelessWidget {
  const StarterScreen2({super.key});

  /// The build method defines the UI of the StarterScreen2.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set the background color of the screen
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 60.0), // Space between the top and the image
                  // Display an image at the center-top of the screen
                  Image.asset('assets/cloud.png'),
                  const SizedBox(height: 20.0), // Space between the image and text
        
                  // Column for displaying text content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the word "Access"
                      Text(
                        'Access',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      // Stack to create a background effect around the word "Edit"
                      Stack(
                        children: [
                          // Background container for the word "Edit"
                          Container(
                            height: 70,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(1.0), // Background color
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(40), // Rounded corners to make it oval
                            ),
                          ),
                          // Positioned text "Edit" inside the background container
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 70.0), // Right padding to center the text
                                child: Text(
                                  'Edit',
                                  style: Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Display the word "Update"
                      Text(
                        'Update',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      // Display the description text
                      Text(
                        'your databases anytime, anywhere!',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ),
                ],
              ),
            ),
            // Positioned icon in the top-right corner for navigation
            Positioned(
              top: 30.0,
              right: 16.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white), // Forward arrow icon
                onPressed: () {
                  // Navigate to StarterScreen3 using GetX for navigation
                  Get.to(const StarterScreen3());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}