import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_editor_gsoc/controllers/access_controller.dart';
import 'package:firebase_editor_gsoc/views/documents/list_documents.dart';
import 'package:firebase_editor_gsoc/views/documents/list_documents_details.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// A service class that handles notification-related functionalities,
/// including initializing notifications, handling incoming notifications,
/// and sending notifications using Firebase Cloud Messaging (FCM).
class NotificationServices {
  final accessController = Get.put(AccessController());
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// Instance of FlutterLocalNotificationsPlugin to manage local notifications
  /// when the app is in an active state.
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the local notification settings for Android and iOS.
  ///
  /// This method is used to set up the notification settings when the app is
  /// in the foreground. It configures the notification icon, initialization
  /// settings for Android and iOS, and specifies what happens when a notification
  /// is received while the app is active.
  ///
  /// [context]: The build context from the calling widget.
  /// [message]: The incoming remote message that contains the notification data.
  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    // Android initialization settings, using the app icon as the notification icon.
    var androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");

    // iOS initialization settings.
    var iosInitializationSettings = const DarwinInitializationSettings();

    // Combine Android and iOS settings into one initialization settings object.
    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    // Initialize the FlutterLocalNotificationsPlugin with the settings.
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        // Define what happens when a notification is tapped.
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  /// Initializes Firebase Messaging to listen for incoming messages.
  ///
  /// This method sets up a listener for Firebase messages that are received
  /// while the app is in the foreground. It triggers the display of a local
  /// notification when a message is received.
  ///
  /// [context]: The build context from the calling widget.
  void firebaseInit(BuildContext context) {
    // Listen for incoming messages while the app is in the foreground.
    FirebaseMessaging.onMessage.listen((message) {
      // Show in-app notifications when a message is received.
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showInAppNotifications(message);
      }
    });
  }

  /// Displays an in-app notification using the FlutterLocalNotificationsPlugin.
  ///
  /// This method is called when a message is received while the app is active.
  /// It sets up the notification details for both Android and iOS and then
  /// displays the notification to the user.
  ///
  /// [message]: The incoming remote message that contains the notification data.
  Future<void> showInAppNotifications(RemoteMessage message) async {
    // Define the notification channel for Android.
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
            Random.secure().nextInt(100000).toString(), // Random channel ID
            "High Priority Notification", // Channel name
            importance: Importance.max // Importance level
            );

    // Set up the Android notification details.
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            androidNotificationChannel.id, // Channel ID
            androidNotificationChannel.name, // Channel name
            channelDescription:
                "Your channel description", // Channel description
            importance: Importance.high, // Importance level
            priority: Priority.high, // Priority level
            ticker: "ticker");

    // Set up the iOS notification details.
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    // Combine Android and iOS notification details into one object.
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    // Show the notification immediately.
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0, // Notification ID
          message.notification!.title.toString(), // Notification title
          message.notification!.body.toString(), // Notification body
          notificationDetails);
    });
  }

  /// Requests notification permissions from the user.
  ///
  /// This method requests permission from the user to display notifications.
  /// It handles the different permission levels available on Android and iOS.
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, // Display notifications in the device's notification bar
        announcement:
            true, // Read notifications through connected devices like earphones
        badge: true, // Display a badge on the app icon
        carPlay: true, // Allow notifications in CarPlay
        criticalAlert: true, // Allow critical alerts
        provisional:
            true, // Request permission the first time a notification is sent (iOS)
        sound: true // Play a sound with the notification
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // User granted permission
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // User granted provisional permission (iOS)
    } else {
      // User denied permission
    }
  }

  /// Retrieves the device token used for Firebase Cloud Messaging.
  ///
  /// This method gets the unique device token for the current device, which
  /// is used by Firebase Cloud Messaging to send notifications to this device.
  ///
  /// Returns the device token as a [String].
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  /// Listens for token refresh events and updates the token in the database.
  ///
  /// This method listens for changes to the device's Firebase Cloud Messaging
  /// token, which can happen if the token expires or is refreshed. It updates
  /// the token in the Firestore database if necessary.
  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString(); // Log or handle the token refresh event
    });
  }

  /// Sets up interaction handling for when the app is opened via a notification.
  ///
  /// This method handles notifications that the user interacts with while the
  /// app is in the background or terminated state. It ensures the correct
  /// screen or action is triggered based on the notification data.
  ///
  /// [context]: The build context from the calling widget.
  Future<void> setUpInteractMessage(BuildContext context) async {
    // Handle notifications that opened the app from a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    // Handle notifications that opened the app from a background state.
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  /// Handles notification taps and redirects to the appropriate screen.
  ///
  /// This method processes the notification data and determines the appropriate
  /// action or screen to navigate to based on the type of notification received.
  ///
  /// [context]: The build context from the calling widget.
  /// [message]: The incoming remote message that contains the notification data.
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'record updated') {
      // Navigate to the document details page.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentDetailsPage(
            accessToken: accessController.accessToken.text,
            projectId: message.data['project_id'],
            databaseId: message.data['database_id'],
            collectionId: message.data['collection_id'],
            documentPath:
                "projects/${message.data['project_id']}/databases/${message.data['database_id']}/documents/${message.data['collection_id']}/${message.data['document_id']}",
          ),
        ),
      );
    } else if (message.data['type'] == 'batch operation') {
      // Navigate to the documents page.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentsPage(
            accessToken: accessController.accessToken.text,
            projectId: message.data['project_id'],
            databaseId: message.data['database_id'],
            collectionId: message.data['collection_id'],
          ),
        ),
      );
    }
  }

  /// Fetches the OAuth access token from the server.
  ///
  /// This method sends a GET request to the server to retrieve an OAuth access
  /// token, which is used to authenticate requests to Firebase Cloud Messaging.
  ///
  /// Returns the access token as a [String] or an empty string if the request fails.
  Future<String> fetchAccessToken() async {
    const url =
        'https://us-central1-gsoc-24-3f4d1.cloudfunctions.net/getOAuthToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  /// Sends a batch operation notification to a specific device.
  ///
  /// This method constructs and sends a batch operation notification to a device
  /// using Firebase Cloud Messaging. It includes information about the project,
  /// database, and collection related to the batch operation.
  ///
  /// [token]: The device token to which the notification will be sent.
  /// [projectId]: The ID of the project associated with the operation.
  /// [databaseId]: The ID of the database associated with the operation.
  /// [collectionId]: The ID of the collection associated with the operation.
  Future<void> sendBatchOperationNotification(String token, String projectId,
      String databaseId, String collectionId) async {
    try {
      String baseProjectId =
          "gsoc-24-3f4d1"; // Replace with your actual project ID
      String url =
          'https://fcm.googleapis.com/v1/projects/$baseProjectId/messages:send';

      // Fetch the access token.
      String accessToken = await fetchAccessToken();
      if (accessToken.isEmpty) {
        return;
      }

      var body = jsonEncode({
        "message": {
          "token": token,
          "notification": {
            "title": "Batch Operation Executed",
            "body": "$projectId/$databaseId/$collectionId",
          },
          "data": {
            "type": "batch operation",
            "project_id": projectId,
            "database_id": databaseId,
            "collection_id": collectionId,
          }
        }
      });

      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Notification sent successfully.
      } else {
        // Failed to send notification.
      }
    } catch (e) {
      // Handle errors.
    }
  }

  /// Sends a record update notification to a specific device.
  ///
  /// This method constructs and sends a record update notification to a device
  /// using Firebase Cloud Messaging. It includes information about the project,
  /// database, collection, and document that was updated.
  ///
  /// [token]: The device token to which the notification will be sent.
  /// [projectId]: The ID of the project associated with the updated record.
  /// [databaseId]: The ID of the database associated with the updated record.
  /// [collectionId]: The ID of the collection associated with the updated record.
  /// [documentId]: The ID of the document that was updated.
  Future<void> sendNotification(String token, String projectId,
      String databaseId, String collectionId, String documentId) async {
    try {
      String baseProjectId = 'gsoc-24-3f4d1';
      String url =
          'https://fcm.googleapis.com/v1/projects/$baseProjectId/messages:send';

      // Fetch the access token.
      String accessToken = await fetchAccessToken();
      if (accessToken.isEmpty) {
        return;
      }

      var body = jsonEncode({
        "message": {
          "token": token,
          "notification": {
            "title": "Record Updated",
            "body": "$projectId/$databaseId/$collectionId",
          },
          "data": {
            "type": "record updated",
            "project_id": projectId,
            "database_id": databaseId,
            "collection_id": collectionId,
            "document_id": documentId,
          }
        }
      });

      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Notification sent successfully.
      } else {
        // Failed to send notification.
      }
    } catch (e) {
      // Handle errors.
    }
  }

  /// Triggers a notification for a record update based on a project ID.
  ///
  /// This method queries the Firestore database to find users associated with
  /// the specified project ID. It then sends a notification to each user's device
  /// informing them of the record update.
  ///
  /// [projectId]: The ID of the project associated with the record update.
  /// [databaseId]: The ID of the database associated with the record update.
  /// [collectionId]: The ID of the collection associated with the record update.
  /// [documentId]: The ID of the document that was updated.
  void triggerNotification(String projectId, String databaseId,
      String collectionId, String documentId) async {
    try {
      // Reference to the users collection in Firestore.
      final CollectionReference usersCollectionRef =
          FirebaseFirestore.instance.collection('users');

      // Query the users collection to find users with the specified projectId in their projectIds array.
      final QuerySnapshot querySnapshot = await usersCollectionRef
          .where('projectIds', arrayContains: projectId)
          .get();

      // Loop through the documents in the query result.
      for (var doc in querySnapshot.docs) {
        // Get the device token from each document.
        String? deviceToken = doc.get('deviceToken');

        if (deviceToken != null && deviceToken.isNotEmpty) {
          // Trigger the sendNotification function with the device token.
          sendNotification(
              deviceToken, projectId, databaseId, collectionId, documentId);
        }
      }
    } catch (error) {
      // Handle errors.
    }
  }

  /// Triggers a notification for a batch operation based on a project ID.
  ///
  /// This method queries the Firestore database to find users associated with
  /// the specified project ID. It then sends a notification to each user's device
  /// informing them of the batch operation.
  ///
  /// [projectId]: The ID of the project associated with the batch operation.
  /// [databaseId]: The ID of the database associated with the batch operation.
  /// [collectionId]: The ID of the collection associated with the batch operation.
  void triggerBatchOpNotification(
      String projectId, String databaseId, String collectionId) async {
    try {
      // Reference to the users collection in Firestore.
      final CollectionReference usersCollectionRef =
          FirebaseFirestore.instance.collection('users');

      // Query the users collection to find users with the specified projectId in their projectIds array.
      final QuerySnapshot querySnapshot = await usersCollectionRef
          .where('projectIds', arrayContains: projectId)
          .get();

      // Loop through the documents in the query result.
      for (var doc in querySnapshot.docs) {
        // Get the device token from each document.
        String? deviceToken = doc.get('deviceToken');

        if (deviceToken != null && deviceToken.isNotEmpty) {
          // Trigger the sendBatchOperationNotification function with the device token.
          sendBatchOperationNotification(
              deviceToken, projectId, databaseId, collectionId);
        }
      }
    } catch (error) {
      // Handle errors.
    }
  }
}
