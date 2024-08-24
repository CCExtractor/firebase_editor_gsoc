# Firebase Editor

Firebase Editor is a mobile application built using Flutter and Firebase. It provides an intuitive interface for managing Firebase databases, collections, and documents. The app also includes advanced features like batch operations, real-time notifications, analytics, and a version control system, making it a powerful tool for developers working with Firebase.

## Features

- **Your Projects**: Lists all the Firebase projects associated with the currently signed-in account. You can navigate to project details and view the databases within each project.
- **Adding Collections**: Add collections to your databases. The collection names must exactly match the names in your Firebase project (case sensitive). You can view, create, and delete documents within these collections and perform batch operations.
- **Batch Operations (Exclusive Feature)**: Add or delete fields from multiple documents at once. You can also download document data in JSON format.
- **Version Control System (Exclusive Feature)**: Tracks updates in the database, including project ID, database ID, collection ID, document ID, field updates, operation type, date and time of update, and the user who performed the operation. This feature provides transparency that is not available in the Firebase console.
- **Real-time Notifications (Exclusive Feature)**: Sends real-time notifications to all users when a record is updated, a feature not available in the Firebase console.
- **Document Operations**: Update field values and types, add or delete fields, and perform other document-related tasks.
- **Analytics (Exclusive Feature)**: Provides insights into database activity over the last 30 days.


## Project Structure

### lib
- **api**
  - `fetch_databases.dart`
  - `fetch_projects.dart`
- **controllers**
  - `access_controller.dart`
  - `data_visualization.dart`
  - `define_schema_controllers.dart`
  - `document_controller.dart`
  - `history_controller.dart`
  - `notification_services.dart`
  - `recent_entries.dart`
  - `token_controller.dart`
  - `user_controller.dart`
- **models**
  - `_profile.dart`
- **utils**
- **views**
  - **collections**
    - `user_collections.dart`
  - **databases**
    - `database_overview.dart`
    - `list_databases.dart`
  - **documents**
    - `batch_operations.dart`
    - `list_documents.dart`
    - `list_documents_details.dart`
  - **fields**
    - `array_field_data.dart`
    - `edit_field_type.dart`
    - `map_field_data.dart`
  - **home**
    - `help.dart`
    - `home_screen.dart`
    - `privacy_policy.dart`
  - **nested_fields**
    - `array_within_map.dart`
    - `map_within_array.dart`
    - `map_within_map.dart`
  - **projects**
    - `list_projects.dart`
  - **schemas**
    - `define_schema.dart`
    - `list_schemas.dart`
  - **screens**
    - **starter_screens**
      - `starter_screen_1.dart`
      - `starter_screen_2.dart`
      - `starter_screen_3.dart`
    - **user_profile**
      - `user_edit_history.dart`
      - `user_profile_view.dart`
    - **user_sign_in**
      - `user_login.dart`
- **widgets**
- `firebase_options.dart`
- `main.dart`

## How to Use

### Your Projects
This section lists all the projects associated with the account you are currently signed in to. You can navigate to project details, which lists the databases of that particular project.

### Adding Collections
After selecting a database, you can add collections. The collection name should exactly match the collection name in your Firebase project (case sensitive). In the collections, you can view the documents, create new documents, delete existing documents, and perform batch operations.

### Batch Operations (Exclusive Feature)
Batch operations allow you to add or delete fields from multiple documents at once. You can even download the document data (single or multiple) in JSON format and use it in your other applications.

### Version Control System (Exclusive Feature)
This app has a version control system that keeps track of updates in the database, listing details such as project ID, database ID, collection ID, document ID, the field that is updated, operation type (update, add, delete), time and date of the update, and the user who updated it. This ensures transparency, a feature that is not present in the Firebase console.

### Real-time Notifications (Exclusive Feature)
Real-time notifications are sent to all users when a record is updated, a feature that is not available in the Firebase console.

### Document Operations
You can go to each document to update field values and types, add or delete fields, and more.

### Analytics (Exclusive Feature)
View simple analytics of operations performed in the last 30 days. This feature provides insight into your database activity.

## Privacy Policy

### Last Updated: 24/08/2024

Firebase Editor is committed to protecting and respecting your privacy. This Privacy Policy explains how we collect, use, and disclose information about you when you use our mobile application.

### Information We Collect
1. **Google OAuth 2.0 Authentication**: We use Google OAuth 2.0 to authenticate users and provide access to their Firebase accounts and projects.
2. **Data Stored**:
   - **Device Token**: Temporarily stored to send notifications.
   - **Operations Data**: Stored for in-app analytics, displaying user history, and recent entries.
3. **Sensitive Scopes Used**:
   - **Analytics Hub API**: Scope: "https://www.googleapis.com/auth/cloud-platform". Purpose: To see, edit, configure, and delete your Google Cloud data, and access the email address associated with your Google Account.
   - **Cloud Datastore API**: Scope: "https://www.googleapis.com/auth/datastore". Purpose: To view and manage your Google Cloud Datastore data.

### How We Use Your Information
- **Accessing Firebase Projects**: The access token obtained through Google OAuth 2.0 retrieves and manages your Firebase projects and associated data.
- **Sending Notifications**: Device tokens are used to send notifications regarding updates to Firebase projects.
- **In-App Analytics**: Data on operations performed within the app is collected to provide insights and display recent activities within the app.

### Data Retention
- **Device Tokens**: Stored temporarily and discarded once their purpose is fulfilled.
- **Operations Data**: Retained as long as necessary to provide in-app analytics and history features.

### Data Sharing
We do not share your personal data with third parties except:
- **To Comply with Legal Obligations**: If required by law, we may share your data with law enforcement or other governmental authorities.
- **With Your Consent**: We may share your information with third parties when we have your explicit consent to do so.

### Security
We implement industry-standard security measures to protect your data. However, no system is completely secure, and we cannot guarantee the absolute security of your information.

### Your Rights
You have the right to:
- **Access and Control Your Data**: You can request access to the data we have stored and request corrections or deletions.
- **Revoke Access**: You can revoke access granted through Google OAuth 2.0 at any time.

### Changes to This Privacy Policy
We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new Privacy Policy on this page.




