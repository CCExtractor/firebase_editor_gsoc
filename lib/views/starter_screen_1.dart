// lib/my_screen.dart

import 'package:firebase_editor_gsoc/views/starter_screen_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StarterScreen1 extends StatelessWidget {
  const StarterScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firebase',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Stack(
                  children: [
                    Container(
                      height: 70,
                      width: 200,
                      decoration: BoxDecoration(
                        color:
                            Colors.amber.withOpacity(1.0), // Background color
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(
                            40), // Half of the height to make it oval
                      ),
                    ),
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
              height: 50.0,
            ),
            Stack(children: [
              const SizedBox(height: 2.0),
              Image.asset('assets/welcome.png'),
              Positioned(
                bottom: 10.0,
                left: 140.0,
                right: 140.0,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle the "Next" button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StarterScreen2(),
                      ),
                    );
                  },
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.white.withOpacity(0.9),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
