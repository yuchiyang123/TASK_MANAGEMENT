import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:task_management/shared/models/users.dart';
import 'package:task_management/core/config/database_config.dart';
import 'package:task_management/core/middleware/auth_middleware.dart';
import 'package:task_management/features/auth/Exception/auth_exception.dart';
import 'package:email_validator/email_validator.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/shared/widgets/error_dialog.dart';

class AuthService {
  late final MySqlConnection _db;

  // logger 偵錯訊息初始化
  final logger = Logger();

  /// 從config 取得連線資料
  Future<void> connect() async {
    try {
      _db = await MySqlConnection.connect(DatabaseConfig.settings);
    } catch (e) {
      logger.w('資料庫連線錯誤，錯誤碼：$e');
      showDialogNC('連線錯誤', '請聯絡管理人員，謝謝');
    }
  }

  /// 獲取連線db
  AuthService(this._db, this._pref);

  // SharedPreferences 初始化
  final SharedPreferences _pref;

  /// 登入邏輯判斷
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final results =
          await _db.query('SELECT * FROM users WHERE email = ?', [email]);

      if (results.isEmpty) {
        throw const AuthException(
          message: '用戶不存在',
          code: AuthErrorCodes.UNDERFOUND_USER,
        );
      }

      final user = User.fromMap(results.first.fields);

      if (!await verifyPassword(password, user.passwordHash)) {
        throw const AuthException(
          message: '密碼驗證失敗',
          code: AuthErrorCodes.PASSWORD_VERIFIY_FAILED,
        );
      }

      if (!user.isActive) {
        throw const AuthException(
          message: '帳號已被停權,請聯絡管理人員謝謝！',
          code: AuthErrorCodes.ACCOUNT_DISABLED,
        );
      }

      await _db
          .query('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);

      final payload = {
        'userId': user.id,
        'email': user.email,
        'role': user.role,
      };

      final accessToken = AuthMiddleware().generateAccessToken(payload);
      final refreshToken = AuthMiddleware().generateRefreshToken(payload);

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } catch (e) {
      logger.w('登入失敗, $e');
      rethrow;
    }
  }

  /// 刷新 accessToken
  String refreshAccessToken(String refreshToken) {
    try {
      return AuthMiddleware().refreshAccessToken(refreshToken);
    } catch (e) {
      logger.w('刷新token失敗, $e');
      throw '刷新token失敗';
    }
  }

  /// 驗證 user 的 hash 是否正確
  Future<bool> verifyPassword(String password, String passwordHash) async {
    try {
      return BCrypt.checkpw(password, passwordHash);
    } catch (e) {
      logger.w('密碼驗證失敗, $e');
      return false;
    }
  }

  /// 用戶註冊
  Future<User> register(User user, String plainPassword) async {
    try {
      if (user.username.isEmpty) {
        throw const AuthException(
          message: '用戶名不得為空',
          code: AuthErrorCodes.UNDERFOUND_USER,
        );
      }

      if (user.email.isEmpty) {
        throw const AuthException(
          message: 'Eamil不得為空',
          code: AuthErrorCodes.UNDERFOUND_USER,
        );
      }

      if (plainPassword.isEmpty) {
        throw const AuthException(
          message: '密碼不得為空',
          code: AuthErrorCodes.USERNAME_DUPLICATE,
        );
      }

      if (!validatePassword(plainPassword)) {
        throw const AuthException(
          message: '密碼至少8位,包含大小寫字母、數字',
          code: AuthErrorCodes.INVALID_PASSWORD,
        );
      }

      final checkUserName = await _db.query(
        'SELECT id FROM users WHERE username = ?',
        [user.username],
      );

      if (checkUserName.isNotEmpty) {
        throw const AuthException(
          message: '用戶名重複,請重新輸入',
          code: AuthErrorCodes.USERNAME_DUPLICATE,
        );
      }

      if (!emailverify(user.email)) {
        throw const AuthException(
          message: 'Email格式錯誤',
          code: AuthErrorCodes.INVALID_EMAIL,
        );
      }

      final checkEmail = await _db.query(
        'SELECT id FROM users WHERE email = ?',
        [user.email],
      );

      if (checkEmail.isNotEmpty) {
        throw const AuthException(
          message: 'Email重複,請重新輸入',
          code: AuthErrorCodes.EMAIL_DUPLICATE,
        );
      }

      // 生成 hash
      final salt = BCrypt.gensalt();
      final passwordHash = BCrypt.hashpw(plainPassword, salt);

      // 建立新的 user 物件，包含 hash 後的密碼
      final userToSave = user.copyWith(
        passwordHash: passwordHash,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _db.query('''
      INSERT INTO users (
        username,
        email,
        password_hash,
        display_name,
        avatar_url,
        phone,
        language,
        theme,
        time_zone,
        notification_settings,
        is_active,
        created_at,
        updated_at,
        role
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        userToSave.username,
        userToSave.email,
        userToSave.passwordHash,
        userToSave.displayName,
        userToSave.avatarUrl,
        userToSave.phone,
        userToSave.language,
        userToSave.theme,
        userToSave.timeZone,
        json.encode(userToSave.notificationSettings),
        userToSave.isActive ? 1 : 0,
        userToSave.createdAt.toIso8601String(),
        userToSave.updatedAt.toIso8601String(),
        userToSave.role,
      ]);

      // 返回包含 ID 的用戶資料
      return userToSave.copyWith(id: result.insertId);
    } catch (e) {
      // 註冊失敗 rollback
      await _db.query('ROLLBACK');
      logger.w(e);
      rethrow;
    }
  }

  /// 驗證註冊密碼是否一樣
  bool validatePasswordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  /// 驗證 email (同步)
  bool emailverify(String email) {
    try {
      return EmailValidator.validate(email);
    } catch (e) {
      logger.w(e);
      throw 'Email格式不正確，請確認格式是否正確，例：example@mail.com';
    }
  }

  /// 驗證密碼複雜度
  bool validatePassword(String password) {
    // 至少8位，包含大小寫字母、數字
    final passwordRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  /// 儲存 AccessToken 和 refreshToken
  Future<void> setJWToken(String? accessToken, String? refreshToken) async {
    await _pref.setString('ACCESS_TOKEN_KEY', accessToken as String);
    await _pref.setString('REFRESH_TOKEN_KEY', refreshToken as String);
  }

  /// 移除 AccessToken 和 refreshToken
  Future<void> clearJWToken() async {
    await _pref.remove('ACCESS_TOKEN_KEY');
    await _pref.remove('REFRESH_TOKEN_KEY');
  }

  /// 是否有登入？
  bool isAuthenticated() {
    final accessToken = _pref.getString('ACCESS_TOKEN_KEY');
    final refreshToken = _pref.getString('REFRESH_TOKEN_KEY');

    if (accessToken == null && refreshToken == null) return false;

    if (AuthMiddleware().verifyJWT(accessToken!)) {
      return true;
    }
    try {
      final newAccessToken = AuthMiddleware().refreshAccessToken(refreshToken!);
      _pref.setString('ACCESS_TOKEN_KEY', newAccessToken);
      return true;
    } catch (e) {
      clearJWToken();
      return false;
    }
  }
}
