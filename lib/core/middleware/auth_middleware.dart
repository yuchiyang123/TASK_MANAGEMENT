import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:task_management/core/config/env.dart';
import 'package:task_management/shared/widgets/error_dialog.dart';
import 'package:logger/logger.dart';
import 'package:task_management/core/constants/error_messages.dart';

class AuthMiddleware {
  final logger = Logger();

  /// 取得系統 jwt key
  final secretKey = Env.jwtSecretKey;

  /// 生成驗證 Token(時間短)
  String generateAccessToken(Map<String, dynamic> payload) {
    try {
      // jwt 2小時過期
      final expiration = DateTime.now().add(const Duration(hours: 2));
      payload['exp'] = expiration.millisecondsSinceEpoch ~/ 1000;
      //  添加標籤
      payload['type'] = 'access';

      //  使用 jwt 生成 token
      final jwt = JWT(payload);
      return jwt.sign(SecretKey(secretKey));
    } catch (e) {
      logger.w('AccessToken 取得失敗，錯誤原因:$e');
      showDialogNC('AccessToken 取得失敗，', ErrorMessages.contactadmin);
      throw ('AccessToken 取得失敗。');
    }
  }

  /// 生成刷新 token(時間長)
  String generateRefreshToken(Map<String, dynamic> payload) {
    try {
      // jwt 30天過期
      final expiration = DateTime.now().add(const Duration(days: 30));
      payload['exp'] = expiration.millisecondsSinceEpoch ~/ 1000;
      // 添加標籤
      payload['type'] = 'refresh';

      // 使用 jwt 生成 token
      final jwt = JWT(payload);
      return jwt.sign(SecretKey(secretKey));
    } catch (e) {
      logger.w('RefreshToken 取得失敗，錯誤原因:$e');
      showDialogNC('RefreshToken 取得失敗，', ErrorMessages.contactadmin);
      throw ('RefreshToken 取得失敗。');
    }
  }

  /// 用 refreshToken 刷新 AccessToken
  String refreshAccessToken(String refreshToken) {
    try {
      // 驗證 refreshToken
      final jwt = JWT.verify(refreshToken, SecretKey(secretKey));

      if (jwt.payload['type'] != 'refresh') {
        throw 'Invaild token type';
      }

      // 從新生成 payload，並且移除掉 refresh token 的 exp 和 type
      final payload = Map<String, dynamic>.from(jwt.payload)
        ..remove('exp')
        ..remove('type');

      return generateAccessToken(payload);
    } catch (e) {
      logger.w('${ErrorMessages.invalidToken}$e');
      throw '無效token,錯誤碼為$e';
    }
  }

  /// 驗證 JWT
  bool verifyJWT(String token) {
    try {
      // 解析 token
      final jwt = JWT.verify(token, SecretKey(secretKey));
      return jwt.payload['type'] == 'access';
    } catch (e) {
      return false;
    }
  }

  /// 是否為AccessToken
  bool isAccessToken(String token) {
    try {
      final payload = getJWTPayload(token);
      return payload['type'] == 'access';
    } catch (e) {
      logger.w('${ErrorMessages.notAccessToken}$e');
      throw false;
    }
  }

  /// 從 JWT 取得用戶資訊
  Map<String, dynamic> getJWTPayload(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(secretKey));
      return Map<String, dynamic>.from(jwt.payload);
    } catch (e) {
      logger.w('${ErrorMessages.invalidToken}$e');
      throw (ErrorMessages.invalidToken);
    }
  }
}
