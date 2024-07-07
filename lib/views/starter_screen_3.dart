// lib/my_screen.dart

import 'package:firebase_editor_gsoc/user_login.dart';
import 'package:flutter/material.dart';

class StarterScreen3 extends StatelessWidget {
  const StarterScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/mobile.png'),
            const SizedBox(height: 20.0),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Now Available',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text('at the comfort of your ', style: Theme.of(context).textTheme.displayMedium,),
                  Stack(
                    children: [
                      Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(1.0), // Background color
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(40), // Half of the height to make it oval
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(right:40.0),
                            child: Text(
                              'Phone!',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                // Handle the "Next" button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text('Next'),
            ),
            const SizedBox(height: 20.0),


          ],
        ),
      ),
    );
  }
}
