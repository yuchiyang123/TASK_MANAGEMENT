import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? routeName;
  final String? errorMessage;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Widget>? customActions;

  const ErrorPage({
    super.key,
    this.routeName,
    this.errorMessage,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.red,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '返回上一頁',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 錯誤圖標動畫
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Icon(
                Icons.error_outline,
                size: 80,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // 錯誤標題
            const Text(
              '找不到頁面',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // 路由名稱（如果有提供）
            if (routeName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '請求路徑: $routeName',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // 錯誤訊息（如果有提供）
            if (errorMessage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 32),

            // 返回首頁按鈕
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', // 請替換為你的首頁路由名稱
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '返回首頁',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 重試按鈕
            TextButton(
              onPressed: () {
                // 重新整理當前頁面
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ErrorPage(
                      routeName: routeName,
                      errorMessage: errorMessage,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),
                  ),
                );
              },
              child: const Text(
                '重新整理',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),

            // 自定義操作按鈕（如果有提供）
            if (customActions != null) ...[
              const SizedBox(height: 24),
              ...customActions!,
            ],
          ],
        ),
      ),
    );
  }
}
