import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_editor_gsoc/firebase_options.dart';
import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:firebase_editor_gsoc/views/starter_screen_1.dart';
import 'package:flutter/material.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.amber, // Adding a secondary color
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 62.0, fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontSize: 24.0, fontStyle: FontStyle.italic),
          titleMedium: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          bodySmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color:Colors.white)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white, // Button text color
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        )
      ),
      home: StarterScreen1(),
      debugShowCheckedModeBanner: false,
    );
  }
}


