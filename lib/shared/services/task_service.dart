import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:task_management/shared/models/tasks.dart';
import 'package:task_management/core/config/database_config.dart';
import 'package:task_management/features/task/exception/task_exception.dart';
import 'package:logger/logger.dart';
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

  Future<Task> insertTask(Task task) async {
    try {
      if (task.title.isEmpty) {
        throw const TaskException(
          message: '任務標題不得為空',
          code: TaskErrorCodes.EMPTY_TITLE,
        );
      }

      if (task.dueDate != null &&
          task.startDate != null &&
          task.dueDate!.isBefore(task.startDate!)) {
        throw const TaskException(
          message: '截止日期不能早於開始日期',
          code: TaskErrorCodes.INVALID_DUE_DATE,
        );
      }

      if (task.progress < 0 || task.progress > 100) {
        throw const TaskException(
          message: '進度必須在 0-100 之間',
          code: TaskErrorCodes.INVALID_PROGRESS,
        );
      }

      // 開始交易
      await _db.query('START TRANSACTION');

      // 檢查分類是否存在
      if (task.categoryId != null) {
        final categoryExists = await _db.query(
            'SELECT id FROM task_categories WHERE id = ?', [task.categoryId]);
        if (categoryExists.isEmpty) {
          throw const TaskException(
            message: '找不到指定的任務分類',
            code: TaskErrorCodes.CATEGORY_NOT_FOUND,
          );
        }
      }

      // 檢查負責人是否存在
      if (task.assigneeId != null) {
        final userExists = await _db
            .query('SELECT id FROM users WHERE id = ?', [task.assigneeId]);
        if (userExists.isEmpty) {
          throw const TaskException(
            message: '找不到指定的負責人',
            code: TaskErrorCodes.ASSIGNEE_NOT_FOUND,
          );
        }
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
      await _db.query('COMMIT');
      return taskToSave.copyWith(id: result.insertId);
    } catch (e) {
      await _db.query('ROLLBACK');
      logger.w('任務標題：${task.title}，任務寫入資料庫錯誤，錯誤碼$e');
      rethrow;
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      if (task.title.isEmpty) {
        throw const TaskException(
          message: '任務標題不得為空',
          code: TaskErrorCodes.EMPTY_TITLE,
        );
      }

      if (task.dueDate != null &&
          task.startDate != null &&
          task.dueDate!.isBefore(task.startDate!)) {
        throw const TaskException(
          message: '截止日期不能早於開始日期',
          code: TaskErrorCodes.INVALID_DUE_DATE,
        );
      }

      if (task.progress < 0 || task.progress > 100) {
        throw const TaskException(
          message: '進度必須在 0-100 之間',
          code: TaskErrorCodes.INVALID_PROGRESS,
        );
      }

      // 開始交易
      await _db.query('START TRANSACTION');

      final taksExist =
          await _db.query('SELECT id FORM TASKS WHERE id =?', [task.id]);

      if (taksExist.isEmpty) {
        throw const TaskException(
          message: '找不到指定的任務',
          code: TaskErrorCodes.TASK_NOT_FOUND,
        );
      }

      // 檢查分類是否存在
      if (task.categoryId != null) {
        final categoryExists = await _db.query(
            'SELECT id FROM task_categories WHERE id = ?', [task.categoryId]);
        if (categoryExists.isEmpty) {
          throw const TaskException(
            message: '找不到指定的任務分類',
            code: TaskErrorCodes.CATEGORY_NOT_FOUND,
          );
        }
      }

      // 檢查負責人是否存在
      if (task.assigneeId != null) {
        final userExists = await _db
            .query('SELECT id FROM users WHERE id = ?', [task.assigneeId]);
        if (userExists.isEmpty) {
          throw const TaskException(
            message: '找不到指定的負責人',
            code: TaskErrorCodes.ASSIGNEE_NOT_FOUND,
          );
        }
      }

      final taskToUpdate = task.copyWith(
        updatedAt: DateTime.now(),
      );

      final result = await _db.query('''
        UPDATE tasks 
        SET 
          title = ?,
          description = ?,
          status = ?,
          priority = ?,
          category_id = ?,
          assignee_id = ?,
          parent_task_id = ?,
          start_date = ?,
          due_date = ?,
          estimated_minutes = ?,
          actual_minutes = ?,
          progress = ?,
          tags = ?,
          attachments = ?,
          reminder_settings = ?,
          recurring_settings = ?,
          is_archived = ?,
          is_deleted = ?,
          updated_at = ?
        WHERE 
          id = ? 
          AND is_deleted = 0
        ''', [
        taskToUpdate.title,
        taskToUpdate.description,
        taskToUpdate.status,
        taskToUpdate.priority,
        taskToUpdate.categoryId,
        taskToUpdate.assigneeId,
        taskToUpdate.parentTaskId,
        taskToUpdate.startDate?.toIso8601String(),
        taskToUpdate.dueDate?.toIso8601String(),
        taskToUpdate.estimatedMinutes,
        taskToUpdate.actualMinutes,
        taskToUpdate.progress,
        json.encode(taskToUpdate.tags),
        json.encode(taskToUpdate.attachments),
        json.encode(taskToUpdate.reminderSettings),
        taskToUpdate.recurringSettings != null
            ? json.encode(taskToUpdate.recurringSettings)
            : null,
        taskToUpdate.isArchived ? 1 : 0,
        taskToUpdate.isDeleted ? 1 : 0,
        DateTime.now().toIso8601String(),
        taskToUpdate.id
      ]);

      await _db.query('COMMIT');
      return taskToUpdate;
    } catch (e) {
      await _db.query('ROLLBACK');
      logger.w('id為${task.id}，插入資料錯誤錯誤碼：$e');
      rethrow;
    }
  }
}
