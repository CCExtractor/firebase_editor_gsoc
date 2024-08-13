// lib/my_screen.dart

import 'package:firebase_editor_gsoc/views/starter_screen_3.dart';
import 'package:flutter/material.dart';

class StarterScreen2 extends StatelessWidget {
  const StarterScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StarterScreen3(),
            ),
          );
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 60.0,),
                  Image.asset('assets/cloud.png'),
                  const SizedBox(height: 20.0),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Access',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),

                      Stack(
                        children: [
                          Container(
                            height: 70,
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
                                padding: const EdgeInsets.only(right:70.0),
                                child: Text(
                                  'Edit',
                                  style: Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Update',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),

                      Text(
                        'your databases anytime, anywhere!',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16.0,
              right: 16.0,
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                onPressed: () {
                  // Handle the tap on the icon here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StarterScreen3(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
