import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


// Future<Map<String, dynamic>> fetchDatabaseInfo(String projectId, String accessToken) async {
//   String parent = 'projects/$projectId/databases/(default)';
//   String url = 'https://firestore.googleapis.com/v1/$parent';
//
//   Map<String, String> headers = {
//     'Authorization': 'Bearer $accessToken',
//     'Accept': 'application/json',
//   };
//
//   try {
//     final response = await http.get(Uri.parse(url), headers: headers);
//
//     if (response.statusCode == 200) {
//       print('Firestore API Response: ${response.body}');
//       Map<String, dynamic> parsedJson = json.decode(response.body);
//
//       // Extracting the database name after "databases/"
//       String databaseName = parsedJson['name'];
//       String displayName = databaseName.split('databases/').last;
//
//       // Adding the extracted name to the response map
//       parsedJson['displayName'] = displayName;
//
//       return parsedJson;
//     } else {
//       print('Failed to call Firestore API. Status Code: ${response.statusCode}');
//       throw Exception('Failed to call Firestore API. Status Code: ${response.statusCode}');
//     }
//   } catch (error) {
//     print('Error calling Firestore API: $error');
//     throw Exception('Error calling Firestore API: $error');
//   }
// }
Future<Map<String, dynamic>> fetchDatabaseInfo(String projectId, String accessToken) async {
  String parent = 'projects/$projectId/databases/(default)';
  String url = 'https://firestore.googleapis.com/v1/$parent';

  Map<String, String> headers = {
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      print('Firestore API Response: ${response.body}');
      Map<String, dynamic> parsedJson = json.decode(response.body);


      // Extracting the database name after "databases/"
      String databaseName = parsedJson['name'];
      String displayName = databaseName.split('databases/').last;

      // Adding the extracted name to the response map
      parsedJson['displayName'] = displayName;
      // Format createTime
      String createTime = _formatDateTime(parsedJson['createTime']);

      // Format updateTime
      String updateTime = _formatDateTime(parsedJson['updateTime']);

      // Adding formatted dates to the response map
      parsedJson['formattedCreateTime'] = createTime;
      parsedJson['formattedUpdateTime'] = updateTime;

      return parsedJson;
    } else {
      print('Failed to call Firestore API. Status Code: ${response.statusCode}');
      throw Exception('Failed to call Firestore API. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error calling Firestore API: $error');
    throw Exception('Error calling Firestore API: $error');
  }
}

String _formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
}
