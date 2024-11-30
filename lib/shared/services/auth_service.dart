import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:task_management/shared/models/users.dart';
import 'package:task_management/core/config/database_config.dart';
import 'package:task_management/core/middleware/auth_middleware.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:task_management/core/config/env.dart';

class AuthService {
  late final MySqlConnection _db;

  /// 從config 取得連線資料
  Future<void> connect() async {
    _db = await MySqlConnection.connect(DatabaseConfig.settings);
  }

  /// 獲取連線db
  AuthService(this._db);

  /// 登入邏輯判斷
  Future<Map<String, dynamic>> login(String email, String password) async {
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

      final payload = {
        'userId': user.id,
        'email': user.email,
        'role': user.role,
      };

      final token = AuthMiddleware().generateJWT(payload);

      return {
        'token': token,
        'user': user.toMap()..remove('password_hash'),
      };
    } catch (e) {
      rethrow;
    }
  }

  /// 驗證 user 的 hash 是否正確
  Future<bool> verifyPassword(String password, String passwordHash) async {
    try {
      return BCrypt.checkpw(password, passwordHash);
    } catch (e) {
      print('密碼驗證失敗 $e');
      return false;
    }
  }
}
