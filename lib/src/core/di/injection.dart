import 'package:get_it/get_it.dart';
import 'package:swamp_task_management_app/src/data/task/repositories/task_repository_impl.dart';
import 'package:swamp_task_management_app/src/domain/task/repositories/task_repositories.dart';
import 'package:swamp_task_management_app/src/domain/task/usecases/create_task.dart';
import 'package:swamp_task_management_app/src/domain/task/usecases/delete_task.dart';
import 'package:swamp_task_management_app/src/domain/task/usecases/move_task.dart';
import 'package:swamp_task_management_app/src/domain/task/usecases/update_task.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _taskModule();
  // Features
}

Future<void> _taskModule() async {
  // Bloc
  sl.registerFactory(
    () => TaskBloc(createTask: sl(), moveTask: sl(), repository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => MoveTask(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl());
}
