import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:task_management/core/config/env.dart';

class AuthMiddleware {
  /// 取得系統 jwt key
  final secretKey = Env.jwtSecretKey;

  /// 生成驗證 Token(時間短)
  String generateAccessToken(Map<String, dynamic> payload) {
    // jwt 2小時過期
    final expiration = DateTime.now().add(Duration(hours: 2));
    payload['exp'] = expiration.millisecondsSinceEpoch ~/ 1000;
    //  添加標籤
    payload['type'] = 'access';

    //  使用 jwt 生成 token
    final jwt = JWT(payload);
    return jwt.sign(SecretKey(secretKey));
  }

  /// 生成刷新 token(時間長)
  String generateRefreshToken(Map<String, dynamic> payload) {
    // jwt 30天過期
    final expiration = DateTime.now().add(Duration(days: 30));
    payload['exp'] = expiration.millisecondsSinceEpoch ~/ 1000;
    // 添加標籤
    payload['type'] = 'refresh';

    // 使用 jwt 生成 token
    final jwt = JWT(payload);
    return jwt.sign(SecretKey(secretKey));
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

  /// 從 JWT 取得用戶資訊
  Map<String, dynamic> getJWTPayload(String token) {
    return JwtDecoder.decode(token);
  }
}
