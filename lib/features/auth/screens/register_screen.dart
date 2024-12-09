import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/features/auth/states/auth_state.dart';
import 'package:task_management/features/auth/states/register_state.dart';
import 'package:task_management/features/auth/widgets/bezierContainer.dart';
import 'package:task_management/features/auth/screens/login_screen.dart';
import 'package:task_management/shared/models/users.dart';
import 'package:task_management/features/auth/Exception/auth_exception.dart';
import 'package:task_management/shared/widgets/error_dialog.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.title});

  final String? title;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final logger = Logger();

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            const Text('返回',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              onChanged: (value) {
                if (title == '使用者姓名') {
                  ref
                      .read(RegisterFormProvider.notifier)
                      .updatedUserName(value);
                } else if (title == 'Email') {
                  ref.read(RegisterFormProvider.notifier).updatedEmail(value);
                } else if (title == '密碼') {
                  ref
                      .read(RegisterFormProvider.notifier)
                      .updatedPassword(value);
                } else {
                  ref
                      .read(RegisterFormProvider.notifier)
                      .updatedConfirmPassword(value);
                }
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    // 監聽表單狀態
    final formState = ref.watch(RegisterFormProvider);

    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: InkWell(
          onTap: () async {
            try {
              final authService = await ref.read(authServiceProvider.future);
              if (!authService.validatePasswordMatch(
                  formState.password, formState.confirmPassword)) {
                logger.w(
                    '密碼：${formState.password}｜重複密碼：${formState.confirmPassword}');
                if (!mounted) return;
                showErrorDialog(context, '密碼不一致', '請確認密碼是否一致');
              }
              final newUser = User(
                username: formState.username,
                email: formState.email,
                passwordHash: formState.password,
              );
              authService.register(newUser, formState.password);
            } on AuthException catch (e) {
              // 確保他生命週期過了狀態不會一直存在
              if (!mounted) return;
              // 處理特定錯誤
              switch (e.code) {
                case AuthErrorCodes.USERNAME_DUPLICATE:
                  showErrorDialog(context, '用戶名已被使用', '請選擇其他用戶名');
                  break;
                case AuthErrorCodes.EMAIL_DUPLICATE:
                  showErrorDialog(context, 'Email已被註冊', '請使用其他Email地址');
                  break;
                case AuthErrorCodes.INVALID_PASSWORD:
                  showErrorDialog(context, '密碼格式錯誤', e.message);
                  break;
                default:
                  showErrorDialog(context, '註冊失敗', e.message);
              }
            } catch (e) {
              logger.w('註冊失敗 錯誤碼：$e');
              showErrorDialog(context, '註冊失敗', '請聯絡管理員');
              throw '註冊失敗';
            }
          },
          child: const Text(
            '註冊',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ));
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '您已經擁有帳號了嗎 ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '登入',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
          text: 'd',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xffe46b10)),
          children: [
            TextSpan(
              text: 'ev',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'rnz',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("使用者姓名"),
        _entryField("Email"),
        _entryField("密碼", isPassword: true),
        _entryField("再輸入一次密碼", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    const SizedBox(
                      height: 50,
                    ),
                    _emailPasswordWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    const SizedBox(height: 1),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
