# Firebase Editor

Firebase Editor is a mobile application built using Flutter and Firebase. It provides an intuitive interface for managing Firebase databases, collections, and documents. The app also includes advanced features like batch operations, real-time notifications, analytics, and a version control system, making it a powerful tool for developers working with Firebase.

## Features

- **Comprehensive CRUD Operations**
  - Easily create, read, update, and delete documents within your Firebase databases.
  - Support for batch operations to perform CRUD actions on multiple records simultaneously.
  - Inline editing capabilities for quick modifications.
  
- **Real-time Notifications**
  - Receive instant notifications for any additions, updates, or deletions in your Firebase records.
  - Customize notification preferences based on specific collections or documents.
  - Leverages Firebase Cloud Messaging and Cloud Functions for efficient and reliable notification delivery.
  
- **Secure Authentication and Authorization**
  - Utilizes Google OAuth 2.0 for secure user authentication.
  - Access control mechanisms to manage user permissions and roles within the app.
  - Short-lived access tokens ensure enhanced security during data interactions.
  
- **Advanced Search and Filter**
  - Powerful search functionality to quickly locate records across projects, databases, and collections.
  - Multiple filter options based on field values, update times, and user activity.
  - Supports saving frequent search queries for repeated use.
  
- **Data Export and Import**
  - Export data in popular formats such as JSON and CSV for external use and backups.
  - Import data seamlessly to populate your databases or migrate data between projects.
  - Supports bulk data operations with error handling and validation.
  
- **Data Visualization and Analytics**
  - Interactive dashboards providing visual insights into your database activities and trends.
  - Charts and graphs showcasing operations performed over customizable timeframes.
  - Monitor key metrics such as data growth, user activity, and operation frequencies.
  
- **Audit Logging and History Tracking**
  - Detailed logs of all operations performed within the app, including timestamps and user information.
  - Version control system to track changes and revert to previous states if necessary.
  - Enhances accountability and facilitates debugging by maintaining a comprehensive activity history.
  
- **Project and Database Management**
  - View and manage all your Firebase projects in one centralized interface.
  - Navigate through different databases, collections, and documents with ease.
  - Supports adding and removing collections dynamically as per project requirements.
  
- **User-friendly Interface**
  - Clean and intuitive design ensuring a smooth user experience across all functionalities.
  - Responsive layouts optimized for various mobile devices and screen sizes.
  - In-app help and documentation to guide users through different features and operations.
  
- **Notifications Setup via Cloud Functions**
  - Easy setup for real-time notifications using Google Cloud Functions.
  - Provides templates and guides for deploying and configuring necessary cloud functions.
  - Ensures scalability and reliability in handling notification workloads.


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
