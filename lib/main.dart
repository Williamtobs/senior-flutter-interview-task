import 'package:flutter/material.dart';
import 'package:swamp_task_management_app/src/app.dart';
import 'package:swamp_task_management_app/src/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}
