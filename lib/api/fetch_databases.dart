import 'dart:convert';

import 'package:firebase_editor_gsoc/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

/// Fetches detailed information about a Firestore database for a given project.
///
/// This function makes an HTTP GET request to the Firestore API to retrieve
/// information about the default database associated with a specific Firebase project.
///
/// The function processes the received JSON data to extract and format specific
/// information, such as the database's display name, creation time, and update time.
///
/// If the API request fails, an error dialog is shown to the user, and an exception is thrown.
///
/// [context]: The BuildContext of the calling widget, used to show error dialogs.
/// [projectId]: The unique identifier of the Firebase project whose database information is being retrieved.
/// [accessToken]: The OAuth2 access token used for authentication in the API request.
///
/// Returns a [Map<String, dynamic>] containing the parsed and formatted database information.
///
/// Throws an [Exception] if the API request fails or encounters an error.
Future<Map<String, dynamic>> fetchDatabaseInfo(BuildContext context, String projectId, String accessToken) async {
  // Define the parent path of the database using the project ID.
  String parent = 'projects/$projectId/databases/(default)';

  // Construct the API endpoint URL.
  String url = 'https://firestore.googleapis.com/v1/$parent';

  // Set up the headers for the HTTP request, including the authorization token.
  Map<String, String> headers = {
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
  };

  try {
    // Make the HTTP GET request to the Firestore API.
    final response = await http.get(Uri.parse(url), headers: headers);

    // Check if the response status code indicates success.
    if (response.statusCode == 200) {
      // Parse the response body JSON into a Map.
      Map<String, dynamic> parsedJson = json.decode(response.body);

      // Extract the database name from the 'name' field in the JSON response.
      String databaseName = parsedJson['name'];

      // Extract the display name by removing the "databases/" prefix from the database name.
      String displayName = databaseName.split('databases/').last;

      // Add the extracted display name to the parsed JSON map.
      parsedJson['displayName'] = displayName;

      // Format the 'createTime' field into a user-friendly format.
      String createTime = formatDateTime(parsedJson['createTime']);

      // Format the 'updateTime' field into a user-friendly format.
      String updateTime = formatDateTime(parsedJson['updateTime']);

      // Add the formatted creation and update times to the parsed JSON map.
      parsedJson['formattedCreateTime'] = createTime;
      parsedJson['formattedUpdateTime'] = updateTime;

      // Return the fully parsed and enriched JSON map.
      return parsedJson;
    } else {
      // If the response status code is not 200, show an error dialog.
      showErrorDialog(context, 'Error, Please Sign in Again!');
      // Throw an exception to indicate the error.
      throw Exception('Error, Please Sign in Again!');
    }
  } catch (error) {
    // If an error occurs during the API request, show an error dialog.
    showErrorDialog(context, 'Error, Please Sign in Again!');
    // Throw an exception to indicate the error.
    throw Exception('Error, Please Sign in Again!');
  }
}
