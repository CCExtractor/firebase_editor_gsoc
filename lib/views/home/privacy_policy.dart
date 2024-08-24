import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Last Updated: 24/08/2024',
              style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16.0),
            Text(
              'Introduction',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Firebase Editor is committed to protecting and respecting your privacy. This Privacy Policy explains how we collect, use, and disclose information about you when you use our mobile application.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Information We Collect',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '1. Google OAuth 2.0 Authentication\n'
                  'We use Google OAuth 2.0 to authenticate users and provide access to their Firebase accounts and projects. This involves obtaining a short-lived access token that allows us to interact with your Firebase data.\n\n'
                  '2. Data Stored\n'
                  '- Device Token: We temporarily store device tokens to send notifications. These tokens are short-lived and not used beyond their intended purpose.\n'
                  '- Operations Data: We store information about operations performed through the App. This data is used for in-app analytics, displaying user history, and recent entries.\n\n'
                  '3. Sensitive Scopes Used\n'
                  '- Analytics Hub API: Scope: "https://www.googleapis.com/auth/cloud-platform". Purpose: To see, edit, configure, and delete your Google Cloud data, and access the email address associated with your Google Account.\n'
                  '- Cloud Datastore API: Scope: "https://www.googleapis.com/auth/datastore". Purpose: To view and manage your Google Cloud Datastore data.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'How We Use Your Information',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '- Accessing Firebase Projects: The access token obtained through Google OAuth 2.0 is used to retrieve and manage your Firebase projects and associated data.\n'
                  '- Sending Notifications: Device tokens are used to send notifications regarding updates to Firebase projects.\n'
                  '- In-App Analytics: Data on operations performed within the app is collected to provide insights and display recent activities within the app.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Data Retention',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '- Device Tokens: Device tokens are stored temporarily and discarded once their purpose is fulfilled.\n'
                  '- Operations Data: Operations data is retained as long as necessary to provide in-app analytics and history features.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Data Sharing',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'We do not share your personal data with third parties except:\n'
                  '- To Comply with Legal Obligations: If required by law, we may share your data with law enforcement or other governmental authorities.\n'
                  '- With Your Consent: We may share your information with third parties when we have your explicit consent to do so.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Security',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'We implement industry-standard security measures to protect your data. However, no system is completely secure, and we cannot guarantee the absolute security of your information.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Your Rights',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'You have the right to:\n'
                  '- Access and Control Your Data: You can request access to the data we have stored and request corrections or deletions.\n'
                  '- Revoke Access: You can revoke access granted through Google OAuth 2.0 at any time.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Changes to This Privacy Policy',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new Privacy Policy on this page.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'If you have any questions or concerns about this Privacy Policy, please contact us at CCExtractor Development Github page.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
