import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 提供全局的 Loading 狀態管理
final loadingProvider = ChangeNotifierProvider((ref) => LoadingController());

/// Loading 的狀態類別
/// 使用不可變的資料模型來確保狀態的可預測性
@immutable
class LoadingState {
  final bool isVisible;
  final DateTime? showTime;

  const LoadingState({
    this.isVisible = false,
    this.showTime,
  });

  LoadingState copyWith({
    bool? isVisible,
    DateTime? showTime,
  }) {
    return LoadingState(
      isVisible: isVisible ?? this.isVisible,
      showTime: showTime ?? this.showTime,
    );
  }
}

/// Loading 動畫元件
/// 提供可自定義的動畫效果和樣式
class LoadingAnimation extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const LoadingAnimation({
    super.key,
    this.color = Colors.white,
    this.size = 100,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LoadingIndicator(
        indicatorType: Indicator.circleStrokeSpin,
        colors: [color],
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Loading 控制器
/// 負責管理 Loading 的狀態和生命週期
class LoadingController extends ChangeNotifier {
  LoadingState _state = const LoadingState();
  static const Duration _minimumShowDuration = Duration(seconds: 1);

  bool get isVisible => _state.isVisible;

  /// 顯示 Loading 並支援自定義配置
  void show(
    BuildContext context, {
    Color loadingColor = Colors.white,
    double size = 100,
    double strokeWidth = 2,
  }) {
    if (_state.isVisible) return;

    _state = _state.copyWith(
      isVisible: true,
      showTime: DateTime.now(),
    );
    notifyListeners();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54, // 半透明背景
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: LoadingAnimation(
            color: loadingColor,
            size: size,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }

  /// 隱藏 Loading 並支援無縫切換到下一個對話框
  Future<void> hide(BuildContext context, {Widget? nextDialog}) async {
    if (!_state.isVisible) return;

    final currentTime = DateTime.now();
    final showTime = _state.showTime;
    if (showTime != null) {
      final elapsedTime = currentTime.difference(showTime);
      if (elapsedTime < _minimumShowDuration) {
        await Future.delayed(_minimumShowDuration - elapsedTime);
      }
    }

    _state = _state.copyWith(
      isVisible: false,
      showTime: null,
    );
    notifyListeners();

    if (context.mounted) {
      if (nextDialog != null) {
        // 無縫切換到下一個對話框
        await Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, _, __) => nextDialog,
            transitionDuration: Duration.zero,
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  /// 處理錯誤並顯示錯誤對話框
  Future<void> hideWithError(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await hide(
      context,
      nextDialog: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}
