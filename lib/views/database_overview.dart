
import 'package:firebase_editor_gsoc/views/circle_widget.dart';
import 'package:firebase_editor_gsoc/views/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/define_schema.dart';
import 'package:firebase_editor_gsoc/views/two_circle_row.dart';
import 'package:flutter/material.dart';

class DatabaseOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Overview'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Center(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CRUD operations", style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 20.0,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleWidget(
                        icon: Icons.add,
                        text: 'Create',
                        onTap: () {
                          // Handle Home click
                          print('Create clicked');
                        },
                      ),
                      CircleWidget(
                        icon: Icons.remove_red_eye,
                        text: 'Read',
                        onTap: () {
                          // Handle Settings click
                          print('Read clicked');
                        },
                      ),
                      CircleWidget(
                        icon: Icons.edit,
                        text: 'Update',
                        onTap: () {
                          // Handle Search click
                          print('Update clicked');
                        },
                      ),
                      CircleWidget(
                        icon: Icons.delete,
                        text: 'Delete',
                        onTap: () {
                          // Handle Notifications click
                          print('Delete clicked');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),


            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue, // Background color
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_align_left_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customize Schema',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              'Manage and edit your \ndatabase schema',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(), // Adds space between text and button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Button action
                          print('Button pressed');
                        },
                        child: Text('Edit'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DualCircleRow(
                    circleDataList: [
                      CircleData(
                        color: Colors.amber,
                        icon: Icons.format_align_justify_sharp,
                        text: 'Show Schema',
                      ),
                      CircleData(
                        color: Colors.amber,
                        icon: Icons.auto_graph_rounded,
                        text: 'Query Summary',
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DualCircleRow(
                    circleDataList: [
                      CircleData(
                        color: Colors.amber,
                        icon: Icons.history_rounded,
                        text: 'Edit History',
                      ),
                      CircleData(
                        color: Colors.amber,
                        icon: Icons.analytics_rounded,
                        text: 'Analytics',
                      ),
                    ],
                  ),
                ),
              ],
            )

          ],
        ),



      ),
    );
  }
}
