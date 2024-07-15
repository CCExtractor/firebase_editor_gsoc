import 'package:flutter/material.dart';

String updateTimestampValue(DateTime selectedDate, TimeOfDay selectedTime) {
  final DateTime combined = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  ).toUtc(); // Convert to UTC

  return combined.toIso8601String();
}