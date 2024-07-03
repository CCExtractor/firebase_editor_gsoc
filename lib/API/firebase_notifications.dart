// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_editor_gsoc/main.dart';
// import 'package:firebase_editor_gsoc/views/list_projects.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
//
// // top level function --> outside a class
// Future<void> handleBackgroundMessage(RemoteMessage message) async{
//   print("Title: ${message.notification?.title}");
//   print("Body: ${message.notification?.body}");
//   print("Payload: ${message.data}");
// }
//
// class FirebaseNotifications{
//
//   final _firebaseMessaging = FirebaseMessaging.instance;
//
//   void handleMessage(RemoteMessage? message){
//
//     print('handle message called');
//     if (message == null) return;
//
//     navigatorKey.currentState?.pushNamed(
//       '/list-projects',
//       arguments: message,
//     );
//
//   }
//
//   Future initPushNotifications() async {
//
//     print("init Push notify called");
//
//     // the below is imp for iOS foreground notification
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // this line is responsible for performing an action when app is woken up from terminated state
//     // handleMessage function is passed to it, meaning that we want to execute this function when the notification is clicked
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//
//
//     // similar functionality as above, when app opened from background state
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//
//
//     // background handler for better organisation of the code
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//
//   }
//
//
//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     // save this along with used uid in database when making for real world
//     final fcmToken = await _firebaseMessaging.getToken();
//     print('token: $fcmToken');
//     initPushNotifications();
//
//     // to receive notification in the background when the app is terminated
//     // a function is passed to this, note this function can't be an anonymous function
//     // it should be a top level function meaning its not a class method
//     // which requires initialization
//
//     // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//     // this has been moved up in initPushNotification methods
//   }
//
//
// }