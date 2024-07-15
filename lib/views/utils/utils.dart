import 'package:flutter/material.dart';

String updateTimeStampFieldValue(DateTime date, TimeOfDay time) {
  final DateTime newDateTime = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  return newDateTime.toUtc().toIso8601String();
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        // Do something if needed when the action is pressed
        // Navigator.of(context).pop();
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}