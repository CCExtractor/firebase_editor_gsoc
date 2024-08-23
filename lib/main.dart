import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/firebase_options.dart';
import 'package:firebase_editor_gsoc/user_login.dart';
import 'package:firebase_editor_gsoc/views/starter_screen_1.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// navigator key for navigation purposes
// This key is crucial for navigating without direct access to BuildContext.
final navigatorKey = GlobalKey<NavigatorState>();

/// for handling notifications when app is in terminated state
/// must be a top level function
/// to make a pop up,, give android channel id in additional setting in firebase

// @pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// to handle firebase background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Initialize the UserController
  Get.put(UserController());
  Get.put(TokenController());
  Get.put(AccessController());

  // for showing starter screens only once!
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenStarterScreens =
      prefs.getBool('hasSeenStarterScreens') ?? false;

  runApp(MyApp(hasSeenStarterScreens: hasSeenStarterScreens));
}

class MyApp extends StatelessWidget {
  final bool hasSeenStarterScreens;

  const MyApp({super.key, required this.hasSeenStarterScreens});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.amber, // Adding a secondary color
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
              displayLarge: TextStyle(
                  fontSize: 62.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              displayMedium: TextStyle(
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              titleLarge:
                  TextStyle(fontSize: 24.0, fontStyle: FontStyle.italic),
              titleMedium:
                  TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
              bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
              bodySmall: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.white)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white, // Button text color
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          )),
      home:
          hasSeenStarterScreens ? const LoginScreen() : const StarterScreen1(),
      navigatorKey: navigatorKey, // Assign the global navigator key
      debugShowCheckedModeBanner: false,
    );
  }
}
