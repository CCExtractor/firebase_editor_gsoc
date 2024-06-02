// lib/my_screen.dart

import 'package:firebase_editor_gsoc/views/starter_screen_3.dart';
import 'package:flutter/material.dart';

class StarterScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 60.0,),
            Image.asset('assets/cloud.png'),
            SizedBox(height: 20.0),

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


            SizedBox(height: 60.0),
            ElevatedButton(
              onPressed: () {
                // Handle the "Next" button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StarterScreen3(),
                  ),
                );
              },
              child: Text('Next'),
            ),
            SizedBox(height: 20.0),


          ],
        ),
      ),
    );
  }
}
