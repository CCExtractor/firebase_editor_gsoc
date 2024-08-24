import 'dart:io';
import 'dart:math';

import 'package:firebase_editor_gsoc/controllers/document_controller.dart';
import 'package:firebase_editor_gsoc/controllers/history_controller.dart';
import 'package:firebase_editor_gsoc/controllers/notification_services.dart';
import 'package:firebase_editor_gsoc/utils/utils.dart';
import 'package:firebase_editor_gsoc/widgets/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/documents/list_documents_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsPage extends StatefulWidget {
  final String accessToken;
  final String projectId;
  final String databaseId;
  final String collectionId;

  const DocumentsPage({
    super.key,
    required this.accessToken,
    required this.projectId,
    required this.databaseId,
    required this.collectionId,
  });

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  // State management and initialization
  bool _isLoading = true; // Indicates if the documents are still being loaded
  bool _isProcessing = false; // Indicates if a processing operation is ongoing

  List<dynamic> _documents = []; // List to store the fetched documents
  List<dynamic> _filteredDocuments = []; // List to store filtered documents based on search
  String? _error; // Variable to store any error messages
  final TextEditingController _searchController = TextEditingController(); // Controller for the search bar
  final documentController = Get.put(DocumentController()); // Document controller using GetX
  NotificationServices notificationServices = NotificationServices(); // Instance of notification services

  bool _isBatchOperation = false; // Flag to indicate if a batch operation is ongoing
  List<String> _selectedDocuments = []; // List of selected document paths

  /// Initializes the state of the widget, including fetching documents and setting up a listener for the search bar.
  @override
  void initState() {
    super.initState();
    _fetchDocuments(); // Fetch documents from Firestore

    // Listener to filter documents as the user types in the search bar
    _searchController.addListener(() {
      _filterDocuments(); // Filters documents based on search query
    });
  }

  /// Navigates to the document details page when a document is selected.
  /// @param documentPath The path of the document to display details for.
  void _showDocumentDetails(String documentPath) {
    Get.to(
      DocumentDetailsPage(
        accessToken: widget.accessToken,
        projectId: widget.projectId,
        databaseId: widget.databaseId,
        collectionId: widget.collectionId,
        documentPath: documentPath,
      ),
    );
  }



  ///  ------------------------------  FILTER DOCUMENTS BASED ON SEARCH BAR INPUT -------------------------------------- ///

  /// Filters the documents based on the search query entered in the search bar.
  /// This function checks if the field names of documents contain the search query.
  void _filterDocuments() {
    setState(() {
      String searchQuery = _searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        _filteredDocuments = _documents; // Show all documents if no query is entered
      } else {
        _filteredDocuments = _documents.where((doc) {
          var fields = doc['fields'] ?? {};
          bool matches = false;

          // Iterate over the fields to see if any field name contains the search query
          for (var fieldName in fields.keys) {
            if (fieldName.toLowerCase().contains(searchQuery)) {
              matches = true;
              break;
            }
          }

          return matches;
        }).toList();
      }
    });
  }

  /// ---------------------------------- FETCH DOCUMENTS --------------------------------------------------------------- ///

  /// Fetches the list of documents from Firestore for the specified collection.
  /// The documents are stored in _documents and _filteredDocuments variables.
  void _fetchDocuments() async {
    String parent =
        'projects/${widget.projectId}/databases/${widget.databaseId}/documents';
    String url =
        'https://firestore.googleapis.com/v1/$parent/${widget.collectionId}';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _documents = data['documents'] ?? [];
          _filteredDocuments = _documents; // Initially, all documents are shown
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
          'Failed to call Firestore API. Status Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = 'Error calling Firestore API: $error';
        _isLoading = false;
      });
    }
  }

  ///  ------------------------------ FETCH SPECIFIC DOCUMENT DATA ----------------------------------------------------- ///

  /// Fetches the details of a specific document from Firestore.
  /// @param documentPath The path of the document to fetch.
  /// @returns A map containing the fields of the document.
  Future<Map<String, dynamic>> _fetchDocumentDetails(
      String documentPath) async {
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['fields'] ?? {};
      } else {
        showErrorDialog(context,
            'Failed to fetch document details. Status Code: ${response.statusCode}');
        return {};
      }
    } catch (error) {
      showErrorDialog(context, 'Error fetching document details: $error');
      return {};
    }
  }


  /// ---------------------------------------- FETCH DOCUMENT DATA FOR DOWNLOADING ------------------------------------- ///

  /// Fetches the entire document data from Firestore, used primarily for downloading purposes.
  /// @param documentPath The path of the document to fetch.
  /// @returns A map containing the entire document data.
  Future<Map<String, dynamic>> _fetchDownloadDocumentDetails(
      String documentPath) async {
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data; // Return the entire document data, not just the fields
      } else {
        return {};
      }
    } catch (error) {
      return {};
    }
  }


  ///  ------------------------------------------- CREATE NEW DOCUMENT -------------------------------------------------  ///

  /// Function to generate a random ID of the specified length.
  /// The ID consists of uppercase letters, lowercase letters, and digits.
  ///
  /// @param length The length of the random ID to be generated.
  /// @returns A random ID string of the specified length.
  String generateRandomId(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }


  /// Function to show a dialog for creating a new document.
  /// The user can manually enter a Document ID or generate an automatic one.
  Future<void> showCreateDocumentDialog(BuildContext context) async {
    String documentId = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Document'), // Dialog title
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Text field to enter or display the Document ID
              TextField(
                controller: documentController.documentIdController,
                decoration: const InputDecoration(labelText: 'Document ID'),
                onChanged: (value) {
                  documentController.documentIdController.text = value;
                },
              ),
              const SizedBox(height: 10),
              // Button to generate an automatic Document ID
              TextButton(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.blue,
                        width: 2.0), // Border color and width
                    borderRadius: BorderRadius.circular(
                        8.0), // Optional: add border radius
                  ),
                  child: const Text('Auto ID'),
                ),
                onPressed: () {
                  setState(() {
                    documentId = generateRandomId(
                        20); // Generate a random ID of length 20
                    documentController.documentIdController.text = documentId;
                  });

                  // Update the TextField with the generated ID and reopen the dialog
                  Navigator.of(context).pop();
                  showCreateDocumentDialog(context);
                },
              ),
            ],
          ),
          actions: <Widget>[
            // Button to cancel the document creation
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                documentController.documentIdController.text =
                    ""; // Clear the Document ID controller
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            // Button to create the document with the entered or generated ID
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (documentController.documentIdController.text.isNotEmpty) {
                  // If a Document ID is provided, proceed with creation
                  _checkAndCreateDocument(
                      documentController.documentIdController.text, context);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // If no Document ID is provided, show an error dialog
                  showErrorDialog(context, 'Please enter a Document ID.');
                }
              },
            ),
          ],
        );
      },
    );
  }


  ///  Function to check if a document with the provided ID already exists.
  /// If it does not exist, create a new document with the specified ID.
  ///
  /// @param documentId The ID of the document to be checked and potentially created.
  /// @param context The BuildContext used to show dialogs and manage the UI.
  ///
  /// @return A Future that completes when the check and create operation is done.
  void _checkAndCreateDocument(String documentId, BuildContext context) async {
    // Construct the document path and URL for the Firestore API request
    String documentPath =
        'projects/${widget.projectId}/databases/${widget.databaseId}/documents/${widget.collectionId}/$documentId';
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Check if the document exists by sending a GET request
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        // If the document exists, show an error dialog
        showErrorDialog(context,
            'Document ID already exists. Please choose a different ID.');
      } else if (response.statusCode == 404) {
        // If the document does not exist, proceed to create a new document
        _createDocument(documentId, context);
      } else {
        // If an unexpected status code is returned, show an error dialog
        showErrorDialog(
            context, 'Error checking document ID: ${response.statusCode}');
      }
    } catch (error) {
      // If an error occurs during the request, show an error dialog
      showErrorDialog(context, 'Error checking document ID: $error');
    }
  }

  /// Function to create a new document with the provided ID.
  /// The document fields are specified in the `body` map.
  ///
  /// @param documentId The ID of the document to be created.
  /// @param context The BuildContext used to show dialogs and manage the UI.
  ///
  /// @return A Future that completes when the document creation process is finished.

  void _createDocument(String documentId, BuildContext context) async {
    // Construct the document path and URL for the Firestore API request
    String documentPath =
        'projects/${widget.projectId}/databases/${widget.databaseId}/documents/${widget.collectionId}/$documentId';
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      // Add your document fields here
    };

    setState(() {
      _isProcessing = true; // Start loading indicator
    });

    try {
      // Send a PATCH request to create the document
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        // If the document is created successfully, update the state and history
        DateTime createTime = DateTime.now();
        insertHistory(
            documentPath, "Document - $documentId", createTime, 'create');

        _fetchDocuments(); // Refresh the document list

        // Clear the Document ID controller after creating the document
        documentController.documentIdController.text = "";

        // Show a toast message indicating success
        showToast("Document Created Successfully!");

        // recentEntryService.triggerRecentEntry(widget.projectId, widget.databaseId, widget.collectionId);
      } else {
        // If document creation fails, show an error dialog
        showErrorDialog(context,
            'Failed to create document. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // If an error occurs during the request, show an error dialog
      showErrorDialog(context, 'Error creating document: $error');
    } finally {
      setState(() {
        _isProcessing = false; // Stop loading indicator
      });
    }
  }

  /// ------------------------------------------- DELETE DOCUMENT ---------------------------------------------------///

  /// Function to delete a document from Firestore.
  ///
  /// @param documentPath The path of the document to be deleted from Firestore.
  ///
  /// @return A Future that completes when the document deletion process is finished.
  void _deleteDocument(String documentPath) async {
    String url =
        'https://firestore.googleapis.com/v1/$documentPath'; // API endpoint for deleting the document
    Map<String, String> headers = {
      'Authorization':
          'Bearer ${widget.accessToken}', // Bearer token for authorization
      'Accept': 'application/json', // Header to accept JSON responses
    };

    setState(() {
      _isProcessing = true; // Start loading indicator
    });

    try {
      // Send a DELETE request to the Firestore API to delete the specified document
      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // If the deletion is successful, remove the document from the local list
        setState(() {
          _documents.removeWhere((doc) => doc['name'] == documentPath);

          DateTime deleteTime =
              DateTime.now(); // Capture the current time for history
          insertHistory(
            documentPath,
            "Document - ${extractDisplayName(documentPath, widget.collectionId)}",
            deleteTime,
            'delete', // Record the delete operation in history
          );
        });
        showToast('Document deleted successfully!'); // Show success message
      } else {
        // If deletion fails, show an error dialog with the status code
        showErrorDialog(context,
            'Failed to delete document. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // If an error occurs during the deletion process, show an error dialog
      showErrorDialog(context, 'Failed to delete document: $error');
    } finally {
      setState(() {
        _isProcessing = false; // Stop loading indicator
      });
    }
  }



  /// Function to show a dialog for deleting a specific field within a document.
  ///
  /// @param context The BuildContext used to show the dialog.
  /// @param onDeleteField A callback function that is triggered when the user confirms the deletion, passing the field name to delete.
  ///
  /// @return void This function does not return a value but triggers the onDeleteField callback with the entered field name when the user confirms the deletion.
  void showDeleteFieldDialog(
      BuildContext context, Function(String) onDeleteField) {
    String fieldName =
        ''; // Variable to store the field name entered by the user

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Field'), // Dialog title
          content: TextField(
            decoration: const InputDecoration(
                labelText: 'Field Name'), // Input field for the field name
            onChanged: (value) {
              fieldName =
                  value; // Update the fieldName variable as the user types
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog without taking action
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                onDeleteField(
                    fieldName); // Call the provided callback with the entered field name
              },
            ),
          ],
        );
      },
    );
  }



  /// Function to show a confirmation dialog before deleting a document.
  ///
  /// @param documentPath The path of the document to be deleted.
  ///
  /// @return void This function does not return a value but prompts the user with a confirmation dialog. If confirmed, it proceeds with the document deletion.
  void _confirmDeleteDocument(String documentPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'), // Dialog title
          content: const Text(
              'Are you sure you want to delete this document?'), // Confirmation message
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog without taking action
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _deleteDocument(
                    documentPath); // Proceed with the document deletion
              },
            ),
          ],
        );
      },
    );
  }

  /// ------------------------------------------- DOWNLOAD DOCUMENTS IN JSON --------------------------------------- ///

  /// Function to export all documents in a Firestore collection to a JSON file.
  /// The user is prompted to save the file to their desired location on their device.
  ///
  /// @param projectId The ID of the Firebase project containing the collection.
  /// @param databaseId The ID of the database within the Firebase project.
  /// @param collectionId The ID of the Firestore collection to be exported.
  /// @param accessToken The access token for authenticating the Firestore API request.
  /// @param context The BuildContext used to manage UI elements and dialogs.
  ///
  /// @return A Future that completes when the export operation is finished, either successfully or with an error.
  Future<void> _exportCollectionToJson(String projectId, String databaseId,
      String collectionId, String accessToken, BuildContext context) async {
    try {
      // Request storage permission before attempting to save the file
      bool permissionGranted =
          await requestManageExternalStoragePermission(context);

      if (!permissionGranted) {
        showDownloadErrorDialog(
            'Storage permission is required to save the file.'); // Show error if permission is denied
        return;
      }

      // Fetch all documents in the specified Firestore collection
      String parent = 'projects/$projectId/databases/$databaseId/documents';
      String url = 'https://firestore.googleapis.com/v1/$parent/$collectionId';
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken', // Authorization header
        'Accept': 'application/json',
      };

      final response = await Dio().get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        // If the request is successful, process the documents
        var data = response.data;
        List<dynamic> documents = data['documents'] ?? [];

        if (documents.isEmpty) {
          showDownloadErrorDialog(
              'No documents found in the collection.'); // Show error if no documents are found
          return;
        }

        // Convert the list of documents to a JSON string
        String jsonString = jsonEncode(documents);

        // Get the temporary directory to save the file initially
        Directory directory = await getTemporaryDirectory();
        String fileName = '$collectionId.json';
        String tempPath = '${directory.path}/$fileName';

        // Save the JSON string to a temporary file
        File tempFile = File(tempPath);
        await tempFile.writeAsString(jsonString);

        // Prompt the user to save the file to their desired location (Downloads or other)
        if (Platform.isAndroid) {
          final params = SaveFileDialogParams(sourceFilePath: tempPath);
          final filePath = await FlutterFileDialog.saveFile(params: params);

          if (filePath != null) {
            showExportSuccessDialog(filePath); // Show success message
          } else {
            showDownloadErrorDialog(
                'File save was canceled.'); // Show error if saving is canceled
          }
        } else if (Platform.isIOS) {
          // Directly save to the iOS Downloads folder or handle differently if needed
          final downloadsDirectory = await getDownloadsDirectory();
          final iosPath = '${downloadsDirectory?.path}/$fileName';
          File iosFile = await tempFile.copy(iosPath);
          showExportSuccessDialog(iosPath); // Show success message
        }
      } else {
        // Show error if the request fails
        showDownloadErrorDialog(
            'Failed to fetch documents. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch and display any errors that occur during the process
      showDownloadErrorDialog('Error exporting collection: $e');
    }
  }

  /// --------------------------------------------- BATCH OPERATIONS ---------------------------------------------- ///

  /// Function to show a dialog for adding a new field to selected documents.
  /// The dialog allows the user to input the field name, select the field type, and set the field value.
  void showAddFieldDialog(BuildContext context) async {
    String fieldName = '';
    String fieldType = 'stringValue'; // Default field type
    String fieldValue = '';
    bool fieldBoolValue = true; // default value
    TextEditingController fieldValueController = TextEditingController();
    TextEditingController latitudeController = TextEditingController();
    TextEditingController longitudeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    List<Map<String, String>> arrayFields = []; // Store array fields
    List<Map<String, String>> mapFields = []; // Store map fields

    // Dropdown menu items for field types
    List<String> fieldTypes = [
      'stringValue',
      'integerValue',
      'booleanValue',
      // 'mapValue',
      'arrayValue',
      'nullValue',
      'timestampValue',
      'geoPointValue',
      'referenceValue',
    ];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Field'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Field Name'),
                      onChanged: (value) {
                        fieldName = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: fieldType,
                      items: fieldTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          fieldType = value!;
                          fieldValue = '';
                          fieldValueController.text = '';
                          latitudeController.clear();
                          longitudeController.clear();
                        });
                      },
                      decoration:
                          const InputDecoration(labelText: 'Field Type'),
                    ),
                    if (fieldType == 'booleanValue')
                      DropdownButtonFormField<bool>(
                        value: fieldBoolValue,
                        items: const [
                          DropdownMenuItem<bool>(
                            value: true,
                            child: Text(
                              'true',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          DropdownMenuItem<bool>(
                            value: false,
                            child: Text(
                              'false',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            fieldBoolValue = value!;
                            fieldValue = value.toString();
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Field Value'),
                      )
                    else if (fieldType == 'geoPointValue')
                      Column(
                        children: [
                          TextField(
                            controller: latitudeController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Latitude'),
                            onChanged: (value) {
                              setState(() {
                                fieldValue =
                                    '${latitudeController.text},${longitudeController.text}';
                              });
                            },
                          ),
                          TextField(
                            controller: longitudeController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Longitude'),
                            onChanged: (value) {
                              setState(() {
                                fieldValue =
                                    '${latitudeController.text},${longitudeController.text}';
                              });
                            },
                          ),
                        ],
                      )
                    else if (fieldType == 'timestampValue')
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: Colors.blue,
                                    width:
                                        2.0), // Change color and width as needed
                              ),
                              child: ListTile(
                                title: const Text('Date'),
                                subtitle:
                                    Text(selectedDate.toString().split(' ')[0]),
                                trailing:
                                    const Icon(Icons.calendar_month_outlined),
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null &&
                                      pickedDate != selectedDate) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                      fieldValue = updateTimeStampFieldValue(
                                          selectedDate, selectedTime);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: Colors.blue,
                                    width:
                                        2.0), // Change color and width as needed
                              ),
                              child: ListTile(
                                title: const Text('Time'),
                                subtitle: Text(selectedTime.format(context)),
                                trailing:
                                    const Icon(Icons.watch_later_outlined),
                                onTap: () async {
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (pickedTime != null &&
                                      pickedTime != selectedTime) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                      fieldValue = updateTimeStampFieldValue(
                                          selectedDate, selectedTime);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          if (fieldValue.isNotEmpty)
                            Text('Selected DateTime: $fieldValue'),
                        ],
                      )
                    else if (fieldType == 'nullValue')
                      TextField(
                        controller: fieldValueController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Field Value'),
                        onChanged: (value) {
                          setState(() {
                            fieldValue = 'null';
                          });
                        },
                      )
                    else if (fieldType == 'arrayValue' ||
                        fieldType == 'mapValue')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "You can add fields after creating the $fieldType"),
                      )
                    else
                      TextField(
                        controller: fieldValueController,
                        onChanged: (value) {
                          fieldValue = value;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Field Value'),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if(fieldType == 'arrayValue' || fieldType == "mapValue") {
                      // since we are creating empty array and empty map, field value won't matter
                      _addFieldToSelectedDocuments(fieldName, fieldType, fieldType);
                    } else {
                      _addFieldToSelectedDocuments(fieldName, fieldType, fieldValue);
                    }
                    _addFieldToSelectedDocuments(
                        fieldName, fieldType, fieldValue);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Function to add or update a specified field in multiple selected Firestore documents.
  /// It formats the field value based on its type and performs a batch write operation.
  ///
  /// @param fieldName The name of the field to be added or updated in the selected documents.
  /// @param fieldType The type of the field to be added (e.g., 'stringValue', 'integerValue', etc.).
  /// @param fieldValue The value of the field to be added or updated, formatted according to its type.
  ///
  /// @return A Future that completes when the batch write operation is finished, either successfully or with an error.
  Future<void> _addFieldToSelectedDocuments(
      String fieldName, String fieldType, dynamic fieldValue) async {
    if (_selectedDocuments.isEmpty) {
      showErrorDialog(context, 'No documents selected for batch update.');
      return;
    }

    setState(() {
      _isProcessing = true; // Start loading
    });

    String url =
        'https://firestore.googleapis.com/v1/projects/${widget.projectId}/databases/${widget.databaseId}/documents:batchWrite';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    List<Map<String, dynamic>> writes = [];
    for (var documentPath in _selectedDocuments) {
      Map<String, dynamic> existingFields =
          await _fetchDocumentDetails(documentPath);

      dynamic formattedValue;
      try {
        switch (fieldType) {
          case 'stringValue':
            formattedValue = {'stringValue': fieldValue};
            break;
          case 'integerValue':
            formattedValue = {'integerValue': int.parse(fieldValue)};
            break;
          case 'booleanValue':
            formattedValue = {
              'booleanValue': fieldValue.toLowerCase() == 'true' ||
                  fieldValue.toLowerCase() == 'false'
            };
            break;
          case 'mapValue':
            formattedValue = {
              'mapValue': {'fields': {}}
            }; // Create an empty map
            break;
          case 'arrayValue':
            formattedValue = {
              'arrayValue': {'values': []}
            }; // Create an empty array
            break;
          case 'nullValue':
            formattedValue = {'nullValue': null};
            break;
          case 'timestampValue':
            formattedValue = {'timestampValue': fieldValue};
            break;
          case 'geoPointValue':
            var parts = fieldValue.split(',');
            var value = {
              'latitude': double.parse(parts[0]),
              'longitude': double.parse(parts[1])
            };
            formattedValue = {'geoPointValue': value};
            break;
          case 'referenceValue':
            formattedValue = {'referenceValue': fieldValue};
            break;
          default:
            showErrorDialog(context, 'Unsupported field type');
            return;
        }
      } catch (e) {
        showErrorDialog(
            context, 'Invalid value for the selected field type: $e');
        return;
      }

      // Add new fields to the existing fields
      existingFields.addAll({
        fieldName: formattedValue,
      });

      writes.add({
        "update": {"fields": existingFields, "name": documentPath}
      });
    }

    Map<String, dynamic> body = {"writes": writes};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showToast('Field added to selected documents successfully!');
        _fetchDocuments(); // Refresh the documents list
        // trigger notification for batch operations
        notificationServices.triggerBatchOpNotification(
            widget.projectId, widget.databaseId, widget.collectionId);
      } else {
        showErrorDialog(context,
            'Failed to add field to documents. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, 'Error adding field to documents: $error');
    } finally {
      setState(() {
        _isProcessing = false; // Stop loading
      });
    }
  }

  /// Function to delete a specified field from multiple selected Firestore documents.
  /// It removes the field and performs a batch write operation to update the documents.
  ///
  /// @param fieldName The name of the field to be deleted from the selected documents.
  ///
  /// @return A Future that completes when the batch write operation is finished, either successfully or with an error.
  Future<void> _deleteFieldFromSelectedDocuments(String fieldName) async {
    if (_selectedDocuments.isEmpty) {
      showErrorDialog(context, 'No documents selected for batch update.');
      return;
    }

    String url =
        'https://firestore.googleapis.com/v1/projects/${widget.projectId}/databases/${widget.databaseId}/documents:batchWrite';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    setState(() {
      _isProcessing = true; // Start loading
    });

    List<Map<String, dynamic>> writes = [];
    for (var documentPath in _selectedDocuments) {
      Map<String, dynamic> existingFields =
          await _fetchDocumentDetails(documentPath);

      // Remove the specified field from the existing fields
      existingFields.remove(fieldName);

      writes.add({
        "update": {"fields": existingFields, "name": documentPath}
      });
    }

    Map<String, dynamic> body = {"writes": writes};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showToast('Field deleted from selected documents successfully!');
        _fetchDocuments(); // Refresh the documents list
        // trigger notification for batch operations
        notificationServices.triggerBatchOpNotification(
            widget.projectId, widget.databaseId, widget.collectionId);
      } else {
        showErrorDialog(context,
            'Failed to delete field from documents. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, 'Error deleting field from documents: $error');
    } finally {
      setState(() {
        _isProcessing = false; // Stop loading
      });
    }
  }

  /// Function to export selected documents from a Firestore collection to a JSON file.
  /// The user is prompted to save the file to their desired location on their device.
  ///
  /// @param projectId The ID of the Firebase project containing the collection.
  /// @param databaseId The ID of the database within the Firebase project.
  /// @param selectedDocumentPaths A list of document paths representing the selected documents to export.
  /// @param accessToken The access token for authenticating the Firestore API request.
  /// @param context The BuildContext used to manage UI elements and dialogs.
  ///
  /// @return A Future that completes when the export operation is finished, either successfully or with an error.
  Future<void> _exportSelectedDocumentsToJson(
      String projectId,
      String databaseId,
      List<String> selectedDocumentPaths,
      String accessToken,
      BuildContext context) async {
    try {
      // Request storage permission before attempting to save the file
      bool permissionGranted =
          await requestManageExternalStoragePermission(context);

      if (!permissionGranted) {
        showDownloadErrorDialog(
            'Storage permission is required to save the file.'); // Show error if permission is denied
        return;
      }

      if (selectedDocumentPaths.isEmpty) {
        showDownloadErrorDialog(
            'No documents selected for export.'); // Show error if no documents are selected
        return;
      }

      List<Map<String, dynamic>> selectedDocumentsData = [];

      for (String documentPath in selectedDocumentPaths) {
        // Fetch details for each selected document
        Map<String, dynamic> documentData =
            await _fetchDownloadDocumentDetails(documentPath);
        selectedDocumentsData.add(documentData);
      }

      // Convert the list of selected documents to a JSON string
      String jsonString = jsonEncode(selectedDocumentsData);

      // Get the temporary directory to save the file initially
      Directory directory = await getTemporaryDirectory();
      String fileName =
          'selected_documents_${DateTime.now().millisecondsSinceEpoch}.json';
      String tempPath = '${directory.path}/$fileName';

      // Save the JSON string to a temporary file
      File tempFile = File(tempPath);
      await tempFile.writeAsString(jsonString);

      // Prompt the user to save the file to their desired location (Downloads or other)
      if (Platform.isAndroid) {
        final params = SaveFileDialogParams(sourceFilePath: tempPath);
        final filePath = await FlutterFileDialog.saveFile(params: params);

        if (filePath != null) {
          showExportSuccessDialog(filePath); // Show success message
        } else {
          showDownloadErrorDialog(
              'File save was canceled.'); // Show error if saving is canceled
        }
      } else if (Platform.isIOS) {
        // Directly save to the iOS Downloads folder or handle differently if needed
        final downloadsDirectory = await getDownloadsDirectory();
        final iosPath = '${downloadsDirectory?.path}/$fileName';
        File iosFile = await tempFile.copy(iosPath);
        showExportSuccessDialog(iosPath); // Show success message
      }
    } catch (e) {
      // Catch and display any errors that occur during the process
      showDownloadErrorDialog('Error exporting selected documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.collectionId}: documents'),
      ),
      drawer: CustomDrawer(),
      body: _isLoading || _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _isLoading
                        ? 'Loading documents...'
                        : 'Processing...Please Wait',
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search by field name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                20.0)), // Set the radius to your desired value
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(20.0)), // Same as above
                            borderSide: BorderSide(
                                color: Colors
                                    .grey), // Optional: set the border color
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(20.0)), // Same as above
                            borderSide: BorderSide(
                                color: Colors
                                    .blue), // Optional: set the border color for focused state
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Define your button action here
                              showCreateDocumentDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.amber, // Set the background color
                            ),
                            child: const Text('Create'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Define your button action here
                              _exportCollectionToJson(
                                  widget.projectId,
                                  widget.databaseId,
                                  widget.collectionId,
                                  widget.accessToken,
                                  context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.amber, // Set the background color
                            ),
                            child: const Text('Download all'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isBatchOperation = !_isBatchOperation;
                                if (!_isBatchOperation) {
                                  _selectedDocuments.clear();
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue, // Set the background color
                            ),
                            child: Text(
                              _isBatchOperation ? 'Cancel' : 'Select',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isBatchOperation)
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Define your button action here
                                showAddFieldDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Set the background color
                              ),
                              child: const Text(
                                'Add a Field',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            child: ElevatedButton(
                              onPressed: () {
                                showDeleteFieldDialog(context, (fieldName) {
                                  _deleteFieldFromSelectedDocuments(fieldName);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Set the background color
                              ),
                              child: const Text(
                                'Delete a Field',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedDocuments.isNotEmpty) {
                                  _exportSelectedDocumentsToJson(
                                    widget.projectId,
                                    widget.databaseId,
                                    _selectedDocuments,
                                    widget.accessToken,
                                    context,
                                  );
                                } else {
                                  showDownloadErrorDialog(
                                      'Please select documents to export.');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Set the background color
                              ),
                              child: const Text(
                                'Download',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredDocuments.length,
                        itemBuilder: (context, index) {
                          var document = _filteredDocuments[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: _isBatchOperation
                                  ? Checkbox(
                                      value: _selectedDocuments
                                          .contains(document['name']),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedDocuments
                                                .add(document['name']);
                                          } else {
                                            _selectedDocuments
                                                .remove(document['name']);
                                          }
                                        });
                                      },
                                    )
                                  : null,
                              title: Text(
                                  "Document ID: ${extractDisplayName(document['name'], widget.collectionId)}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Created Time: ${formatDateTime(document['createTime'])}'),
                                  Text(
                                      'Updated Time: ${formatDateTime(document['updateTime'])}'),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _showDocumentDetails(
                                              document['name']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                        ),
                                        child: const Text('View Fields'),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _confirmDeleteDocument(
                                              document['name']);
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
