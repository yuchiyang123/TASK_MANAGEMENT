// 環境變數
class Env {
  static const dbHost =
      String.fromEnvironment('DB_HOST', defaultValue: 'localhost');
  static const dbPort = int.fromEnvironment('DB_PORT', defaultValue: 3306);
  static const dbUser = String.fromEnvironment('DB_USER', defaultValue: '');
  static const dbPassword =
      String.fromEnvironment('DB_PASSWORD', defaultValue: '');
  static const dbName =
      String.fromEnvironment('DB_NAME', defaultValue: 'task_management_db');
}
