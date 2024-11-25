import 'env.dart';
import 'package:mysql1/mysql1.dart';

// mysql
class DatabaseConfig {
  static ConnectionSettings get settings => ConnectionSettings(
      host: Env.dbHost,
      port: Env.dbPort,
      user: Env.dbUser,
      password: Env.dbPassword,
      db: Env.dbName);
}
