import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_editor_gsoc/controllers/access_controller.dart';
import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/widgets/firebase_options.dart';
import 'package:firebase_editor_gsoc/views/user_sign_in/user_login.dart';
import 'package:firebase_editor_gsoc/views/screens/starter_screens/starter_screen_1.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_editor_gsoc/utils/theme_provider.dart';
import 'package:firebase_editor_gsoc/views/home/home_screen.dart';

// navigator key for navigation purposes
// This key is crucial for navigating without direct access to BuildContext.
final navigatorKey = GlobalKey<NavigatorState>();

/// for handling notifications when app is in terminated state
/// must be a top level function
/// to make a pop up,, give android channel id in additional setting in firebase
@pragma('vm:entry-point')
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

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(hasSeenStarterScreens: hasSeenStarterScreens),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenStarterScreens;

  const MyApp({super.key, required this.hasSeenStarterScreens});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GetMaterialApp(
      title: 'Firebase Editor',

      /// Use the custom themes from ThemeProvider
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.currentTheme, // Toggles based on isDarkMode

      home: hasSeenStarterScreens ? LoginScreen() : const StarterScreen1(),
      navigatorKey: navigatorKey, // Assign the global navigator key
      debugShowCheckedModeBanner: false,
    );
  }
}

// HomeScreen Implementation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            // Use onPrimary for icons on the appBar's primary color
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: const HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome to Home Screen',
        // Use the headlineMedium from the theme
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
