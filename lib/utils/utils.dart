import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

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


void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Future<void> showPermissionDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
            'This app needs storage access to save files. Please enable storage permission in the app settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              openAppSettings(); // Open the app-specific settings page
            },
          ),
        ],
      );
    },
  );
}

Future<bool> requestManageExternalStoragePermission(BuildContext context) async {
  if (await Permission.manageExternalStorage.isGranted) {
    return true;
  }

  PermissionStatus status = await Permission.manageExternalStorage.request();

  if (status.isGranted) {
    return true;
  } else if (status.isDenied || status.isPermanentlyDenied) {
    await showPermissionDialog(context); // Show the dialog if permission is denied
    return false;
  }

  return false;
}


String extractDisplayName(String documentName, String collectionId) {
  List<String> parts = documentName.split("$collectionId/");
  String displayName = parts.last;
  return displayName;
}



void showExportSuccessDialog(String filePath) {
  // Implement your logic to show a dialog with the file path
  // You can also trigger a notification or alert here
}

void showDownloadErrorDialog(String message) {
  // Implement your logic to show an error dialog
}

String formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
}

// Function to strip the "Value" suffix from the fieldType
String stripValueSuffix(String fieldType) {
  if (fieldType.endsWith('Value')) {
    return fieldType.replaceAll('Value', '');
  }
  return fieldType;
}