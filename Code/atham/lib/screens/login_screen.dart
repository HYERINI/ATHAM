import 'package:atham/flutter_flow/flutter_flow_theme.dart';
import 'package:atham/flutter_flow/flutter_flow_widgets.dart';
import 'package:atham/responsive/responsive_layout.dart';
import 'package:atham/responsive/web_screen_layout.dart';
import 'package:atham/screens/find_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:atham/methods/auth_methods.dart';
import 'package:atham/responsive/mobile_screen_layout.dart';
import 'package:atham/screens/signup_screen.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/utils/utils.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
          (route) => false);

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 120, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/AthamLogo.png',
                        height: 100,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 20),
                        child: Text('ATHAME으로 당신의 옷을 편하게 관리해보세요',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      // Container(
                      //   alignment: Alignment.centerLeft,
                      //   padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                      //   child: Text(
                      //     'Login',
                      //     style: Theme.of(context).textTheme.displaySmall,
                      //     textAlign: TextAlign.left,
                      //   ),
                      // ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
              TextFieldInput(
                hintText: '이메일을 입력하세요',
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                hintText: '비밀번호를 입력하세요',
                textInputType: TextInputType.text,
                textEditingController: _passwordController,
                isPass: true,
              ),
              const SizedBox(
                height: 24,
              ),
              InkWell(
                child: Container(
                  child: !_isLoading
                      ? const Text(
                          '로그인하기!',
                        )
                      : const CircularProgressIndicator(
                          color: primaryColor,
                        ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: blueColor,
                  ),
                ),
                onTap: loginUser,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text(
                      '비밀번호를 잊으셨어요?',
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FindPWScreen(),
                      ),
                    ),
                    child: Container(
                      child: const Text(
                        '  비밀번호 찾기!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(
                height: 12,
              ),
              Flexible(
                child: Container(),
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text(
                      '아직 계정이 없다면?',
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    ),
                    child: Container(
                      child: const Text(
                        '   회원가입하기!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Flexible(
          //       child: Container(),
          //       flex: 2,
          //     ),
          //     SvgPicture.asset(
          //       'assets/ic_instagram.svg',
          //       color: primaryColor,
          //       height: 64,
          //     ),
          //     const SizedBox(
          //       height: 64,
          //     ),
          //     TextFieldInput(
          //       hintText: 'Enter your email',
          //       textInputType: TextInputType.emailAddress,
          //       textEditingController: _emailController,
          //     ),
          //     const SizedBox(
          //       height: 24,
          //     ),
          //     TextFieldInput(
          //       hintText: 'Enter your password',
          //       textInputType: TextInputType.text,
          //       textEditingController: _passwordController,
          //       isPass: true,
          //     ),
          //     const SizedBox(
          //       height: 24,
          //     ),
          //     InkWell(
          //       child: Container(
          //         child: !_isLoading
          //             ? const Text(
          //                 'Log in',
          //               )
          //             : const CircularProgressIndicator(
          //                 color: primaryColor,
          //               ),
          //         width: double.infinity,
          //         alignment: Alignment.center,
          //         padding: const EdgeInsets.symmetric(vertical: 12),
          //         decoration: const ShapeDecoration(
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.all(Radius.circular(4)),
          //           ),
          //           color: blueColor,
          //         ),
          //       ),
          //       onTap: loginUser,
          //     ),
          //     const SizedBox(
          //       height: 12,
          //     ),
          //     Flexible(
          //       child: Container(),
          //       flex: 2,
          //     ),

          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Container(
          //           child: const Text(
          //             'Forgot Password?',
          //           ),
          //           padding: const EdgeInsets.symmetric(vertical: 8),
          //         ),
          //         GestureDetector(
          //           onTap: () => Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (context) => const FindPWScreen(),
          //             ),
          //           ),
          //           child: Container(
          //             child: const Text(
          //               ' Find Password.',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             padding: const EdgeInsets.symmetric(vertical: 8),
          //           ),
          //         ),
          //       ],
          //     ),

          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Container(
          //           child: const Text(
          //             'Dont have an account?',
          //           ),
          //           padding: const EdgeInsets.symmetric(vertical: 8),
          //         ),
          //         GestureDetector(
          //           onTap: () => Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (context) => const SignupScreen(),
          //             ),
          //           ),
          //           child: Container(
          //             child: const Text(
          //               ' Signup.',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             padding: const EdgeInsets.symmetric(vertical: 8),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
