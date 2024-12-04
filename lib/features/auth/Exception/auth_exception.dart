// auth_exception.dart
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException({
    required this.message,
    required this.code,
  });
}

/// 認證相關錯誤碼常量
class AuthErrorCodes {
  /// 用戶名已存在，註冊時檢測到重複的用戶名
  static const String USERNAME_DUPLICATE = 'USERNAME_DUPLICATE';

  /// 電子郵件已存在，註冊時檢測到重複的電子郵件地址
  static const String EMAIL_DUPLICATE = 'EMAIL_DUPLICATE';

  /// 無效的電子郵件格式，輸入的電子郵件地址格式不正確
  static const String INVALID_EMAIL = 'INVALID_EMAIL';

  /// 密碼格式無效，不符合密碼複雜度要求（如：長度、包含大小寫字母和數字等）
  static const String INVALID_PASSWORD = 'INVALID_PASSWORD';

  /// 用戶不存在，查詢數據庫時找不到指定的用戶
  static const String USER_NOT_FOUND = 'USER_NOT_FOUND';

  /// 無效的憑證，通常是密碼錯誤或認證信息不正確
  static const String INVALID_CREDENTIALS = 'INVALID_CREDENTIALS';

  /// 帳號已被停用，用戶帳號處於非活動狀態
  static const String ACCOUNT_DISABLED = 'ACCOUNT_DISABLED';

  /// 未知錯誤，系統捕獲到未預期的異常
  static const String UNKNOWN_ERROR = 'UNKNOWN_ERROR';

  /// 找不到用戶，通常用於查詢或操作特定用戶時未找到對應記錄
  static const String UNDERFOUND_USER = 'UNDERFOUND_USER';

  /// 密碼驗證失敗，用於密碼比對不匹配的情況
  static const String PASSWORD_VERIFIY_FAILED = 'PASSWORD_VERIFIY_FAILED';
}
