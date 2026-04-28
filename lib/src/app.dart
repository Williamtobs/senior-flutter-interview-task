import 'package:flutter/material.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/view/document_screen.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/view/task_board_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polymarq Assessment',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Switch between the two screens to test them
      home: TaskBoardScreen(),
      // home: DocumentDashboardPage(),
    );
  }
}
