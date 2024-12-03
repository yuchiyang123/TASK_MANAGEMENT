import 'package:mysql1/mysql1.dart';
import 'package:riverpod/riverpod.dart';
import 'package:task_management/core/config/database_config.dart';
import 'package:task_management/shared/services/auth_service.dart';

final authServiceProvider = FutureProvider((ref) async {
  final connection = await MySqlConnection.connect(DatabaseConfig.settings);
  return AuthService(connection);
});
