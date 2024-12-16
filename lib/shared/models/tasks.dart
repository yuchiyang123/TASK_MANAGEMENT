import 'dart:convert';

class Task {
  /// 任務ID，可為空(新建任務時)
  final int? id;

  /// 任務標題
  final String title;

  /// 任務描述，可選
  final String? description;

  /// 任務狀態(pending/in_progress/completed/cancelled)
  final String status;

  /// 任務優先級(low/medium/high/urgent)
  final String priority;

  /// 任務分類ID，可選
  final int? categoryId;

  /// 創建者ID
  final int creatorId;

  /// 負責人ID，可選
  final int? assigneeId;

  /// 父任務ID，可選(用於子任務)
  final int? parentTaskId;

  /// 開始時間，可選
  final DateTime? startDate;

  /// 截止時間，可選
  final DateTime? dueDate;

  /// 完成時間，可選
  final DateTime? completedAt;

  /// 預估工時(分鐘)，可選
  final int? estimatedMinutes;

  /// 實際工時(分鐘)，可選
  final int? actualMinutes;

  /// 進度百分比(0-100)
  final int progress;

  /// 標籤列表，以JSON格式儲存
  final List<String> tags;

  /// 附件列表，以JSON格式儲存
  final List<Map<String, dynamic>> attachments;

  /// 提醒設定，以JSON格式儲存
  final Map<String, dynamic> reminderSettings;

  /// 重複任務設定，以JSON格式儲存
  final Map<String, dynamic>? recurringSettings;

  /// 任務是否歸檔
  final bool isArchived;

  /// 任務是否刪除
  final bool isDeleted;

  /// 創建時間
  final DateTime createdAt;

  /// 最後更新時間
  final DateTime updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    this.status = 'pending',
    this.priority = 'medium',
    this.categoryId,
    required this.creatorId,
    this.assigneeId,
    this.parentTaskId,
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.estimatedMinutes,
    this.actualMinutes,
    this.progress = 0,
    List<String>? tags,
    List<Map<String, dynamic>>? attachments,
    Map<String, dynamic>? reminderSettings,
    this.recurringSettings,
    this.isArchived = false,
    this.isDeleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : tags = tags ?? [],
        attachments = attachments ?? [],
        reminderSettings = reminderSettings ??
            {
              'enabled': true, // 是否啟用提醒
              'before_deadline': 24, // 截止日期前多少小時提醒
              'notification_types': ['email', 'push'], // 提醒方式
              'custom_times': [], // 自訂提醒時間
            },
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 將資料庫查詢結果(Map格式)轉換為Task物件
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      categoryId: map['category_id'],
      creatorId: map['creator_id'],
      assigneeId: map['assignee_id'],
      parentTaskId: map['parent_task_id'],
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'].toString())
          : null,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'].toString())
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'].toString())
          : null,
      estimatedMinutes: map['estimated_minutes'],
      actualMinutes: map['actual_minutes'],
      progress: map['progress'],
      tags: List<String>.from(json.decode(map['tags'])),
      attachments:
          List<Map<String, dynamic>>.from(json.decode(map['attachments'])),
      reminderSettings: json.decode(map['reminder_settings']),
      recurringSettings: map['recurring_settings'] != null
          ? json.decode(map['recurring_settings'])
          : null,
      isArchived: map['is_archived'] == 1,
      isDeleted: map['is_deleted'] == 1,
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  /// 將Task物件轉換為可存入資料庫的Map格式
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'category_id': categoryId,
      'creator_id': creatorId,
      'assignee_id': assigneeId,
      'parent_task_id': parentTaskId,
      'start_date': startDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'estimated_minutes': estimatedMinutes,
      'actual_minutes': actualMinutes,
      'progress': progress,
      'tags': json.encode(tags),
      'attachments': json.encode(attachments),
      'reminder_settings': json.encode(reminderSettings),
      'recurring_settings':
          recurringSettings != null ? json.encode(recurringSettings) : null,
      'is_archived': isArchived ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 建立Task物件的複本，可選擇性更新部分屬性
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    int? categoryId,
    int? creatorId,
    int? assigneeId,
    int? parentTaskId,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    int? estimatedMinutes,
    int? actualMinutes,
    int? progress,
    List<String>? tags,
    List<Map<String, dynamic>>? attachments,
    Map<String, dynamic>? reminderSettings,
    Map<String, dynamic>? recurringSettings,
    bool? isArchived,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      creatorId: creatorId ?? this.creatorId,
      assigneeId: assigneeId ?? this.assigneeId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      progress: progress ?? this.progress,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      reminderSettings: reminderSettings ?? this.reminderSettings,
      recurringSettings: recurringSettings ?? this.recurringSettings,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
