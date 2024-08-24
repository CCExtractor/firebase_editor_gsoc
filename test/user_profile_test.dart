import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/views/list_projects.dart';
import 'package:firebase_editor_gsoc/views/user_edit_history.dart';
import 'package:firebase_editor_gsoc/views/user_profile_view.dart';

// Mock class for UserController
class MockUserController extends Mock implements UserController {}

void main() {
  late MockUserController mockUserController;

  setUp(() {
    mockUserController = MockUserController();
    Get.put<UserController>(mockUserController);
  });

  tearDown(() {
    Get.reset(); // Resets the GetX state after each test
  });

  testWidgets('UserProfileView displays user information and options', (WidgetTester tester) async {
    // Arrange: Set up the mock user data
    when(mockUserController.user).thenReturn(MockUser(
      displayName: 'John Doe',
      email: 'johndoe@example.com',
      photoURL: 'https://example.com/photo.jpg',
    ) as User?);

    // Act: Build the UserProfileView widget
    await tester.pumpWidget(GetMaterialApp(home: UserProfileView()));

    // Assert: Verify that the user information is displayed correctly
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('johndoe@example.com'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('Tapping on Your Projects navigates to ProjectsPage', (WidgetTester tester) async {
    // Arrange
    when(mockUserController.user).thenReturn(MockUser(
      displayName: 'John Doe',
      email: 'johndoe@example.com',
      photoURL: 'https://example.com/photo.jpg',
    ) as User?);

    // Act
    await tester.pumpWidget(GetMaterialApp(home: UserProfileView()));
    await tester.tap(find.text('Your Projects'));
    await tester.pumpAndSettle(); // Wait for navigation

    // Assert: Verify that the ProjectsPage is displayed
    expect(find.byType(ProjectsPage), findsOneWidget);
  });

  testWidgets('Tapping on Switch Accounts calls handleLogout', (WidgetTester tester) async {
    // Arrange
    when(mockUserController.user).thenReturn(MockUser(
      displayName: 'John Doe',
      email: 'johndoe@example.com',
      photoURL: 'https://example.com/photo.jpg',
    ) as User?);

    // Act
    await tester.pumpWidget(GetMaterialApp(home: UserProfileView()));
    await tester.tap(find.text('Switch Accounts'));
    await tester.pumpAndSettle();

    // Assert: Verify that handleLogout was called
    verify(mockUserController.handleLogout()).called(1);
  });

  testWidgets('Tapping on Edit History navigates to HistoryPage', (WidgetTester tester) async {
    // Arrange
    when(mockUserController.user).thenReturn(MockUser(
      displayName: 'John Doe',
      email: 'johndoe@example.com',
      photoURL: 'https://example.com/photo.jpg',
    ) as User?);

    // Act
    await tester.pumpWidget(GetMaterialApp(home: UserProfileView()));
    await tester.tap(find.text('Edit History'));
    await tester.pumpAndSettle(); // Wait for navigation

    // Assert: Verify that the HistoryPage is displayed
    expect(find.byType(HistoryPage), findsOneWidget);
  });
}

// Mock User class (replace with your actual User model)
class MockUser {
  final String? displayName;
  final String? email;
  final String? photoURL;

  MockUser({this.displayName, this.email, this.photoURL});
}
