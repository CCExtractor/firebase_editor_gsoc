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


## How the App Works

### Authentication
The app uses Google OAuth 2.0 for user authentication, allowing access to your Firebase projects. A short-lived access token is obtained to interact with your Firebase data securely.

### Data Management
- **Device Tokens**: Temporarily stored to send real-time notifications regarding updates to Firebase projects.
- **Operations Data**: Tracks and stores information about the actions performed within the app, which is used for analytics and user history.

### Scopes Used
- **Google Cloud Platform**: Accesses and manages your Google Cloud data.
- **Cloud Datastore API**: Views and manages your Google Cloud Datastore data.

### User Rights
Users have the right to access, control, and request the deletion of their data. Access granted through Google OAuth 2.0 can be revoked at any time.

### Notifications
The app uses Cloud Functions to handle notifications, ensuring real-time updates on Firebase projects.

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

## How to Run

### Step 1: Fork the Repository
Start by forking the repository to your own GitHub account. This will allow you to make changes and deploy the app from your own copy of the code.

### Step 2: Set Up a Firebase Project
- Use the Firebase CLI to set up a new Firebase project.
- Follow the instructions to connect the Firebase Editor app to your Firebase project.

### Step 3: Configure Google Cloud Console
- Go to the Google Cloud Console and navigate to the Firebase project you set up.
- Enable OAuth and set up OAuth credentials.
- Make sure to include the following OAuth scopes:
  - `https://www.googleapis.com/auth/datastore`
  - `https://www.googleapis.com/auth/cloud-platform`
  - `https://www.googleapis.com/auth/firebase.messaging`

### Step 4: Set Up Notifications (Optional but Recommended)
- For real-time notifications, you need to set up your own server to manage OAuth 2.0 credentials.
- In this project, we have used Google Cloud Functions, which is the recommended approach.
- Set up Cloud Functions in your Firebase project to handle notifications and other server-side operations.
