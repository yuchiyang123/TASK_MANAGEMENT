import 'package:mysql1/mysql1.dart';
import 'package:riverpod/riverpod.dart';
import 'package:task_management/core/config/database_config.dart';
import 'package:task_management/shared/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authServiceProvider = FutureProvider((ref) async {
  final connection = await MySqlConnection.connect(DatabaseConfig.settings);
  final SharedPreferences pref = await SharedPreferences.getInstance();
  return AuthService(connection, pref);
});
