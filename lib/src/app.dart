import 'package:flutter/material.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/view/task_board_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swamp Task Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskBoardScreen(),
    );
  }
}
