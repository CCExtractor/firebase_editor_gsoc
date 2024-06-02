// lib/controllers/schema_controllers.dart

import 'package:flutter/material.dart';

class SchemaControllers {
  final TextEditingController dbNameController = TextEditingController();
  final TextEditingController primaryKeyNameController = TextEditingController();
  final TextEditingController primaryKeyTypeController = TextEditingController();
  final List<TextEditingController> attributeNameControllers = [];
  final List<TextEditingController> attributeTypeControllers = [];

  String primaryKeyType = 'string'; // Default value for dropdown
  void dispose() {
    dbNameController.dispose();
    primaryKeyNameController.dispose();
    primaryKeyTypeController.dispose();
    attributeNameControllers.forEach((controller) => controller.dispose());
    attributeTypeControllers.forEach((controller) => controller.dispose());
  }

  void addAttributeControllers() {
    attributeNameControllers.add(TextEditingController());
    attributeTypeControllers.add(TextEditingController());
  }
}
