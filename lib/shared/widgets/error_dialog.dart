import 'package:flutter/material.dart';

/// 錯誤跳窗（有context）
/// 顯示錯誤對話框的通用方法
/// 提供美觀的視覺效果和流暢的使用者體驗
void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54, // 改變背景灰灰
    builder: (BuildContext context) {
      return Dialog(
        // 設置對話框形狀和邊距
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0, // 移除預設陰影
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // 主要陰影：提供基本深度感
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 0.5,
                offset: const Offset(0, 4),
              ),
              // 次要陰影：增加層次感
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題區域
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // 內容區域
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // 按鈕區域
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '確定',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 錯誤跳窗（沒有context）
void showDialogNC(String title, String message) {
  AlertDialog(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop;
        },
        child: const Text('確定'),
      ),
    ],
  );
}
