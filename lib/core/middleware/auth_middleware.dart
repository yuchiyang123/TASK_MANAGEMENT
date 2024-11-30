import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:task_management/core/config/env.dart';

class AuthMiddleware {
  /// 取得系統 jwt key
  final secretKey = Env.jwtSecretKey;

  /// 生成 jwt Token
  String generateJWT(Map<String, dynamic> payload) {
    // jwt 7天過期
    final expiration = DateTime.now().add(Duration(days: 7));
    payload['exp'] = expiration.millisecondsSinceEpoch ~/ 1000;

    //  使用jwt 生成 token
    final jwt = JWT(payload);
    return jwt.sign(SecretKey(secretKey));
  }

  /// 驗證 JWT
  bool verifyJWT(String token) {
    try {
      // 解析 token
      JWT.verify(token, SecretKey(secretKey));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 從 JWT 取得用戶資訊
  Map<String, dynamic> getJWTPayload(String token) {
    return JwtDecoder.decode(token);
  }
}
