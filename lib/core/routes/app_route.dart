import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/features/auth/screens/login_screen.dart';
import 'package:task_management/features/auth/screens/register_screen.dart';
import 'package:task_management/features/error/screen/error_screen.dart';
import 'package:task_management/features/auth/states/auth_state.dart';

// 路由名稱定義
class RouteName {
  RouteName._();

  static const auth = _Auth._();
  static const main = _Main._();
}

class _Auth {
  const _Auth._();
  String get login => '/auth/login';
  String get register => '/auth/register';
}

class _Main {
  const _Main._();
  String get home => '/';
  String get profile => '/profile';
}

// Router Provider
final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter(ref);
});

// 路由管理
class AppRouter {
  final Logger _logger = Logger();
  final Ref _ref;

  AppRouter(this._ref);

  Route<dynamic> generateRoute(RouteSettings settings) {
    final publicRoutes = [
      RouteName.auth.login,
      RouteName.auth.register,
    ];

    // 如果是公開路由，直接返回對應頁面
    if (publicRoutes.contains(settings.name)) {
      return _buildRoute(settings);
    }

    // 需要驗證的路由，使用 FutureBuilder 包裝
    return MaterialPageRoute(
      builder: (context) => FutureBuilder<bool>(
        future: _handleRouteIntercept(settings),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 如果驗證成功，返回請求的頁面
          if (snapshot.hasData && snapshot.data == true) {
            return _buildPageContent(settings);
          }

          // 驗證失敗或有錯誤，返回登入頁
          return const LoginPage();
        },
      ),
    );
  }

  Future<bool> _handleRouteIntercept(RouteSettings settings) async {
    _logger.d('Route: ${settings.name}, Arguments: ${settings.arguments}');

    final publicRoutes = [
      RouteName.auth.login,
      RouteName.auth.register,
    ];

    if (!publicRoutes.contains(settings.name)) {
      final authService = await _ref.read(authServiceProvider.future);
      return authService.isAuthenticated();
    }
    return true;
  }

  Route<dynamic> _buildRoute(RouteSettings settings) {
    return CustomRouteBuilder(
      page: _buildPageContent(settings),
    );
  }

  Widget _buildPageContent(RouteSettings settings) {
    switch (settings.name) {
      case '/auth/login':
        return const LoginPage();
      case '/auth/register':
        return const RegisterPage();
      // case '/':
      //   return const HomePage();
      default:
        return ErrorPage(routeName: settings.name);
    }
  }
}

// 自定義路由構建器
class CustomRouteBuilder extends PageRouteBuilder {
  final Widget page;

  CustomRouteBuilder({
    required this.page,
    RouteTransitionsBuilder? transitionsBuilder,
    super.opaque,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: transitionsBuilder ??
              ((context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              }),
        );
}

// 導航擴展方法
extension NavigatorExt on BuildContext {
  Future<T?> pushToLogin<T>() {
    return Navigator.pushNamed(this, RouteName.auth.login);
  }

  Future<T?> pushToRegister<T>({String? initialEmail}) {
    return Navigator.pushNamed(
      this,
      RouteName.auth.register,
      arguments: {'email': initialEmail},
    );
  }

  Future<T?> pushToHome<T>() {
    return Navigator.pushNamed(this, RouteName.main.home);
  }
}
