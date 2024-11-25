import 'dart:convert';

class User {
  /// 用戶ID，可為空(新建用戶時)
  final int? id;

  /// 用戶名稱，唯一標識
  final String username;

  /// 電子郵件，唯一標識
  final String email;

  /// 加密後的密碼
  final String passwordHash;

  /// 顯示名稱，可選
  final String? displayName;

  /// 頭像URL，可選
  final String? avatarUrl;

  /// 手機號碼，可選
  final String? phone;

  /// 界面語言，預設zh-TW
  final String language;

  /// 界面主題(light/dark/system)
  final String theme;

  /// 時區設定
  final String timeZone;

  /// 通知相關設定，以JSON格式儲存
  final Map<String, dynamic> notificationSettings;

  /// 最後登入時間
  final DateTime? lastLogin;

  /// 最後同步時間
  final DateTime? lastSync;

  /// 帳號是否啟用
  final bool isActive;

  /// 創建時間
  final DateTime createdAt;

  /// 最後更新時間
  final DateTime updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.displayName,
    this.avatarUrl,
    this.phone,
    this.language = 'zh-TW',
    this.theme = 'system',
    this.timeZone = 'Asia/Taipei',
    Map<String, dynamic>? notificationSettings,
    this.lastLogin,
    this.lastSync,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.notificationSettings = notificationSettings ??
            {
              'email': true, // 是否接收電子郵件通知
              'push': true, // 是否接收推播通知
              'desktop': true, // 是否接收桌面通知
              'sound': true, // 是否開啟通知音效
              'task_reminder': true, // 是否接收任務提醒
              'deadline_reminder': true, // 是否接收截止日期提醒
              'team_updates': true // 是否接收團隊更新通知
            },
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  /// 將資料庫查詢結果(Map格式)轉換為User物件
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['password_hash'],
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      phone: map['phone'],
      language: map['language'],
      theme: map['theme'],
      timeZone: map['time_zone'],
      notificationSettings: json.decode(map['notification_settings']),
      lastLogin:
          map['last_login'] != null ? DateTime.parse(map['last_login']) : null,
      lastSync:
          map['last_sync'] != null ? DateTime.parse(map['last_sync']) : null,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 將User物件轉換為可存入資料庫的Map格式
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'language': language,
      'theme': theme,
      'time_zone': timeZone,
      'notification_settings': json.encode(notificationSettings),
      'last_login': lastLogin?.toIso8601String(),
      'last_sync': lastSync?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 建立User物件的複本，可選擇性更新部分屬性
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? displayName,
    String? avatarUrl,
    String? phone,
    String? language,
    String? theme,
    String? timeZone,
    Map<String, dynamic>? notificationSettings,
    DateTime? lastLogin,
    DateTime? lastSync,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      timeZone: timeZone ?? this.timeZone,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      lastLogin: lastLogin ?? this.lastLogin,
      lastSync: lastSync ?? this.lastSync,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
