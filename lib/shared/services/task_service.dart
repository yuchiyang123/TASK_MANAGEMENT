import 'dart:convert';
import 'dart:math';
import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:task_management/shared/models/tasks.dart';

import 'package:task_management/core/config/database_config.dart';
import 'package:task_management/core/middleware/auth_middleware.dart';
import 'package:task_management/features/task/exception/task_exception.dart';
import 'package:email_validator/email_validator.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/shared/widgets/error_dialog.dart';

class TaskService {
  /// 連線字串
  late final MySqlConnection _db;

  /// 初始化錯誤提示
  final logger = Logger();

  /// 建立連線
  Future<void> connect() async {
    try {
      _db = await MySqlConnection.connect(DatabaseConfig.settings);
    } catch (e) {
      logger.w('資料庫連線錯誤，錯誤碼：$e');
      showDialogNC('連線錯誤', '請聯絡管理人員，謝謝');
    }
  }

  TaskService(this._db);

  Future<void> insertTask(Task task) async {
    try {
      if (task.title.isEmpty) {
        throw const TaskException(
          message: '任務標題不得為空',
          code: TaskErrorCodes.EMPTY_TITLE,
        );
      }

      final taskToSave = task.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 插入任務到資料庫
      final result = await _db.query('''
          INSERT INTO tasks (
            title,
            description,
            status,
            priority,
            category_id,
            creator_id,
            assignee_id,
            parent_task_id,
            start_date,
            due_date,
            estimated_minutes,
            actual_minutes,
            progress,
            tags,
            attachments,
            reminder_settings,
            recurring_settings,
            is_archived,
            is_deleted,
            created_at,
            updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
        taskToSave.title,
        taskToSave.description,
        taskToSave.status,
        taskToSave.priority,
        taskToSave.categoryId,
        taskToSave.creatorId,
        taskToSave.assigneeId,
        taskToSave.parentTaskId,
        taskToSave.startDate?.toIso8601String(),
        taskToSave.dueDate?.toIso8601String(),
        taskToSave.estimatedMinutes,
        taskToSave.actualMinutes,
        taskToSave.progress,
        json.encode(taskToSave.tags),
        json.encode(taskToSave.attachments),
        json.encode(taskToSave.reminderSettings),
        taskToSave.recurringSettings != null
            ? json.encode(taskToSave.recurringSettings)
            : null,
        taskToSave.isArchived ? 1 : 0,
        taskToSave.isDeleted ? 1 : 0,
        taskToSave.createdAt.toIso8601String(),
        taskToSave.updatedAt.toIso8601String(),
      ]);
    } catch (e) {
      await _db.query('ROLLBACK');
      logger.w('任務寫入資料庫錯誤，錯誤碼$e');
      rethrow;
    }
  }
}
