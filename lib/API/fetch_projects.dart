import 'dart:convert';
import 'package:firebase_editor_gsoc/controllers/access_controller.dart';
import 'package:firebase_editor_gsoc/views/datatypes/show_error_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Function to call the Firebase Projects API and retrieve a list of Firebase projects.
/// It sends a GET request to the API endpoint and returns the response as a map.
///
/// @param accessToken The access token used for authorization to call the Firebase API.
///
/// @return A Future that completes with a Map<String, dynamic> containing the API response data.
/// If the request fails, an exception is thrown prompting the user to sign in again.
Future<Map<String, dynamic>> callFirebaseProjectsAPI(BuildContext context, String accessToken) async {

  final accessController = Get.put(AccessController());

  final String userAccessToken = accessController.accessToken.text;

  const String url = 'https://firebase.googleapis.com/v1beta1/projects?pageSize=10';

  Map<String, String> headers = {
    'Authorization': 'Bearer $userAccessToken',
    'Accept': 'application/json',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      showErrorDialog(context,"Error, Please sign in Again!");
      throw Exception("Error, Please sign in Again!");
    }
  } catch (error) {
    showErrorDialog(context,"Error, Please sign in Again!");
    throw Exception("Error, Please sign in Again!");

  }
}
