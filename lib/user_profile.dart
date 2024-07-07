import 'package:flutter/material.dart';
import 'models/user.dart';
import 'views/user_profile_view.dart';

class UserProfile extends StatelessWidget {
  final User user = User(
    imageUrl: 'https://i.pinimg.com/564x/be/45/87/be45870b11faa9d507a7e9eeb557bc28.jpg',
    name: 'John Doe',
    email: 'john.doe@example.com',
    services: ['Service 1', 'Service 2', 'Service 3'],
  );

  UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfileView();
  }
}
