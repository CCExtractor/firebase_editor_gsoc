import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

import 'mocks.dart';
import 'mocks.mocks.dart'; // Import the generated mocks


class MockFirebaseAuth extends Mock implements FirebaseAuth {}
void main() {
  late MockUser mockUser;

  setUpAll(() async {
    // Ensure that Firebase is initialized before running tests
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(); // Initialize Firebase here

    // Set up the mock user
    mockUser = MockUser();
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.photoURL).thenReturn('https://via.placeholder.com/150');

    // Mock any other behavior you need for User
  });

  testWidgets('HomeScreen displays correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(
      home: HomeScreen(),
    ));

    // Check if AppBar title is present
    expect(find.text('Home'), findsOneWidget);

    // Check if the user profile container is displayed
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('You are currently signed in as:'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);

    // Check if the quick access buttons are present
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);

    // Check if the Operations Analysis section is displayed
    expect(find.text('Operations Analysis (Last 30 days)'), findsOneWidget);

    // Check if the Recently Accessed section is displayed
    expect(find.text('Recently Accessed'), findsOneWidget);

    // Check if placeholder text for no data is displayed
    expect(find.text('No operations data available!'), findsOneWidget);
    expect(find.text('No data available'), findsOneWidget);
  });
}
