class TaskException implements Exception {
  final String message;
  final String code;

  const TaskException({
    required this.message,
    required this.code,
  });
}

/// 任務相關錯誤碼常量
class TaskErrorCodes {
  /// 標題為空
  static const String EMPTY_TITLE = 'EMPTY_TITLE';

  /// 任務不存在
  static const String TASK_NOT_FOUND = 'TASK_NOT_FOUND';

  /// 無權限操作此任務
  static const String PERMISSION_DENIED = 'PERMISSION_DENIED';

  /// 無效的任務狀態轉換
  static const String INVALID_STATUS_TRANSITION = 'INVALID_STATUS_TRANSITION';

  /// 截止日期無效 (早於開始日期或當前日期)
  static const String INVALID_DUE_DATE = 'INVALID_DUE_DATE';

  /// 進度值無效 (不在 0-100 範圍內)
  static const String INVALID_PROGRESS = 'INVALID_PROGRESS';

  /// 找不到指定的父任務
  static const String PARENT_TASK_NOT_FOUND = 'PARENT_TASK_NOT_FOUND';

  /// 循環依賴 (不能將任務設為自己的子任務)
  static const String CIRCULAR_DEPENDENCY = 'CIRCULAR_DEPENDENCY';

  /// 任務已被歸檔，無法修改
  static const String TASK_ARCHIVED = 'TASK_ARCHIVED';

  /// 任務已被刪除
  static const String TASK_DELETED = 'TASK_DELETED';

  /// 分配的用戶不存在
  static const String ASSIGNEE_NOT_FOUND = 'ASSIGNEE_NOT_FOUND';

  /// 任務分類不存在
  static const String CATEGORY_NOT_FOUND = 'CATEGORY_NOT_FOUND';

  /// 附件上傳失敗
  static const String ATTACHMENT_UPLOAD_FAILED = 'ATTACHMENT_UPLOAD_FAILED';

  /// 附件大小超過限制
  static const String ATTACHMENT_SIZE_EXCEEDED = 'ATTACHMENT_SIZE_EXCEEDED';

  /// 無效的重複任務設定
  static const String INVALID_RECURRING_SETTINGS = 'INVALID_RECURRING_SETTINGS';

  /// 已完成的任務無法修改
  static const String COMPLETED_TASK_MODIFICATION =
      'COMPLETED_TASK_MODIFICATION';
}

// 錯誤訊息對照表
Map<String, String> taskErrorMessages = {
  TaskErrorCodes.EMPTY_TITLE: '任務標題不能為空',
  TaskErrorCodes.TASK_NOT_FOUND: '找不到指定的任務',
  TaskErrorCodes.PERMISSION_DENIED: '您沒有權限執行此操作',
  TaskErrorCodes.INVALID_STATUS_TRANSITION: '無效的狀態變更',
  TaskErrorCodes.INVALID_DUE_DATE: '截止日期無效',
  TaskErrorCodes.INVALID_PROGRESS: '進度值必須在 0-100 之間',
  TaskErrorCodes.PARENT_TASK_NOT_FOUND: '找不到指定的父任務',
  TaskErrorCodes.CIRCULAR_DEPENDENCY: '不能將任務設為自己的子任務',
  TaskErrorCodes.TASK_ARCHIVED: '任務已歸檔，無法修改',
  TaskErrorCodes.TASK_DELETED: '任務已刪除',
  TaskErrorCodes.ASSIGNEE_NOT_FOUND: '找不到指定的負責人',
  TaskErrorCodes.CATEGORY_NOT_FOUND: '找不到指定的任務分類',
  TaskErrorCodes.ATTACHMENT_UPLOAD_FAILED: '附件上傳失敗',
  TaskErrorCodes.ATTACHMENT_SIZE_EXCEEDED: '附件大小超過限制',
  TaskErrorCodes.INVALID_RECURRING_SETTINGS: '重複任務設定無效',
  TaskErrorCodes.COMPLETED_TASK_MODIFICATION: '已完成的任務無法修改',
};
