import 'dart:io';
import 'dart:math';

import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/views/list_documents_details.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';


class NotificationServices {

  final accessController = Get.put(AccessController());
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// for showing notifications when app is in active state
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// function to initialize the _flutterLocalNotificationsPlugin instance
  // provide context and message
  void initLocalNotifications(BuildContext context, RemoteMessage message) async {

    print("local notifications called");

    /// ANDROID INITIALIZATION
    // provide the icon you want to show in the notification right now it comes from res folder in android
    // if you want to add yours, add it to drawable icon
    // and then use drawable/ic_launcher
    var androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");

    /// IOS INITIALIZATION
    var iosInitializationSettings = const DarwinInitializationSettings();

    /// BIND THE SETTINGS TOGETHER
    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );

    /// initialize the _flutterLocalNotificationsPlugin instance
    /// provide the initialization settings
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      /// handle on received msg
      onDidReceiveNotificationResponse: (payload){
          handleMessage(context, message);
      }
    );
  }


  /// this listens to broadcast service of fcm to listen for notifications
  void firebaseInit(BuildContext context) {

    // listens on to notifications coming
    FirebaseMessaging.onMessage.listen((message) {

      print("NOTIFICATION TITLE: ${message.notification?.title.toString()}");
      print("NOTIFICATION BODY: ${message.notification?.body.toString()}");
      print("DATA: ${message.data.toString()}");
      print(message.data['project_id']);
      print(message.data['database_id']);
      print(message.data['collection_id']);
      print(message.data['document_id']);
      // show in app notifications
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showInAppNotifications(message);
      }
    });

  }


  /// show notifications when app active
  Future<void> showInAppNotifications(RemoteMessage message) async{

    print("show in app notifications called");

    ///  SET ANDROID NOTIFICATIONS AND CHANNEL DETAILS
    // set a channel id and name for now
    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
      // for now provide a random channel id
      Random.secure().nextInt(100000).toString(),
      // for now you can give the name anything
      "High Priority Notification",
      importance: Importance.max // don't set it high, or it will not show
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        // access channel id
        androidNotificationChannel.id,
        // access channel Name
        androidNotificationChannel.name,
        channelDescription: "Your channel description",
        importance: Importance.high,
        priority: Priority.high,
        ticker: "ticker"
    );

    /// SET IOS NOTIFICATIONS AND CHANNEL DETAILS
    /// ios handles it by itself, firebase doesn't uses this
    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    /// BIND THE SETTINGS TOGETHER
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    // provide duration and callback function
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,   // id
          message.notification!.title.toString(), // title
          message.notification!.body.toString(), // body
          notificationDetails);
    });

  }


  // request permissions
  void requestNotificationPermission() async {

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,  // notifications are shown in the device, if false, not shown even if permission given
      announcement: true, // in earphones etc, notification can be read
      badge: true, // number shown on top of app icon
      carPlay: true, //
      criticalAlert: true,
      provisional: true, // request for permission when notifications are sent first time, for iOS
      sound: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("user granted permission");
      }
    // for iOS
    else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("user granted permission");
    }else{
      print("user denied permission");
    }

  }


  // firebase sends notifications based on device token/device ID
  Future<String> getDeviceToken() async {
    String? token = await  messaging.getToken();
    return token!;
  }
  // use this function to listen to token expiration and update it in the database.
  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("refreshed token: $event");
  });
}

  // redirect on tap on background notification or terminated state
  Future<void> setUpInteractMessage(BuildContext context) async {

    // when app is in terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    // when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });

  }


  // redirect on tap on in app notification
  void handleMessage(BuildContext context, RemoteMessage message){
      if(message.data['type'] == 'record updated'){
        // redirect to the document updated page
        // access all ids from the payload
        print(accessController.accessToken.text);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentDetailsPage(
              accessToken: accessController.accessToken.text,
              projectId: message.data['project_id'],
              databaseId: message.data['database_id'],
              collectionId: message.data['collection_id'],
              documentPath: "projects/hellos-bc256/databases/(default)/documents/bookings/UkbGIXCwLSWD0YQtosM2",
            ),
          ),
        );
      }
  }


}