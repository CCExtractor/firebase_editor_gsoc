import 'package:firebase_editor_gsoc/views/starter_screen_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StarterScreen1 extends StatelessWidget {
  const StarterScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StarterScreen2(),
            ),
          );
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                              color: Colors.amber.withOpacity(1.0),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(40),
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
                  Stack(
                    children: [
                      const SizedBox(height: 2.0),
                      Image.asset('assets/welcome.png'),
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
                      builder: (context) => const StarterScreen2(),
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
