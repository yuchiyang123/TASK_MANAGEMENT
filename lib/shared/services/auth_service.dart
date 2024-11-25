import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:task_management/shared/models/users.dart';
import 'package:task_management/core/config/database_config.dart';

class AuthService {
  late final MySqlConnection _db;

  //final datacon = DataBaseConfig();

  Future<void> connect() async {
    _db = await MySqlConnection.connect(DatabaseConfig.settings);
  }

  AuthService(this._db);

  Future<User?> login(String email, String password) async {
    try {
      final results =
          await _db.query('SELECT * FROM users WHERE email = ?', [email]);

      if (results.isEmpty) {
        throw '用戶不存在';
      }

      final user = User.fromMap(results.first.fields);

      if (!await verifyPassword(password, user.passwordHash)) {
        throw '密碼驗證失敗';
      }

      await _db
          .query('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyPassword(String password, String passwordHash) async {
    try {
      return BCrypt.checkpw(password, passwordHash);
    } catch (e) {
      print('密碼驗證失敗 $e');
      return false;
    }
  }
}
