import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'login.dart';


// ================================================================
// THEME COLORS (Purple)
// ================================================================

class AppColors {
  static const Color background = Color(0xFFFAF6FB);
  static const Color surface = Colors.white;
  static const Color surfaceLight = Color(0xFFF3ECF8);
  static const Color purple = Color(0xFF6C3FC9);
  static const Color purpleDark = Color(0xFF4B2A94);
  static const Color textPrimary = Color(0xFF2D2340);
  static const Color textSecondary = Color(0xFF77717F);
}

void main() {
  runApp(const forgot());
}

class forgot extends StatelessWidget {
  const forgot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const forgotpage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.purple,

        colorScheme: const ColorScheme.light(
          primary: AppColors.purple,
          secondary: AppColors.purple,
          surface: AppColors.surface,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          shape: Border(
            bottom: BorderSide(
              color: AppColors.purple,
              width: 2,
            ),
          ),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.purple,
          selectionColor: Color(0x336C3FC9),
          selectionHandleColor: AppColors.purple,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
          ),

          floatingLabelStyle: const TextStyle(
            color: AppColors.purple,
          ),

          prefixIconColor: AppColors.purple,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5DDF0),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5DDF0),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.purple,
              width: 1.6,
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppColors.purple.withOpacity(0.30),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 14,
            ),

            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


// ================================================================
// SHARED UI HELPERS
// ================================================================

Widget _headerIcon(IconData icon) {
  return Container(
    width: 110,
    height: 110,

    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.surface,

      border: Border.all(
        color: AppColors.purple.withOpacity(0.6),
        width: 2,
      ),

      boxShadow: [
        BoxShadow(
          color: AppColors.purple.withOpacity(0.20),
          blurRadius: 30,
          spreadRadius: 2,
        ),
      ],
    ),

    child: Icon(
      icon,
      size: 52,
      color: AppColors.purple,
    ),
  );
}


Widget _headerText(String title, String subtitle) {
  return Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,

        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),

      const SizedBox(height: 8),

      Text(
        subtitle,
        textAlign: TextAlign.center,

        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}


Widget _formCard({
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,

    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: AppColors.surface,

      borderRadius: BorderRadius.circular(18),

      border: Border.all(
        color: const Color(0xFFE5DDF0),
      ),

      boxShadow: [
        BoxShadow(
          color: AppColors.purple.withOpacity(0.08),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),

    child: Column(
      children: children,
    ),
  );
}


// ================================================================
// FORGOT PASSWORD PAGE
// ================================================================

class forgotpage extends StatefulWidget {
  const forgotpage({super.key});

  @override
  State<forgotpage> createState() => _forgotpageState();
}

class _forgotpageState extends State<forgotpage> {

  final TextEditingController emailcontroller =
  TextEditingController();

  @override
  void dispose() {
    emailcontroller.dispose();
    super.dispose();
  }


  Future<void> _verifyEmail() async {

    String email = emailcontroller.text.trim();

    SharedPreferences sh =
    await SharedPreferences.getInstance();

    String? url = sh.getString('url');

    if (url == null) {
      Fluttertoast.showToast(
        msg: 'Base URL not set',
      );
      return;
    }

    final urls = Uri.parse(
      '$url/forgotpasswordflutter/',
    );

    try {

      final response = await http.post(
        urls,
        body: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {

        var data = jsonDecode(response.body);

        if (data['status'] == 'ok') {

          Fluttertoast.showToast(
            msg: 'OTP sent to your email',
          );

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpPage(email: email),
            ),
          );

        } else {

          Fluttertoast.showToast(
            msg: data['message']?.toString() ?? 'Error',
          );
        }

      } else {

        Fluttertoast.showToast(
          msg: 'Network error',
        );
      }

    } catch (e) {

      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password?',
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),

          child: Column(
            children: [

              _headerIcon(
                Icons.lock_reset,
              ),

              const SizedBox(height: 22),

              _headerText(
                'Reset your password',
                'Enter your registered email and we will send you a one-time password.',
              ),

              const SizedBox(height: 26),

              _formCard(
                children: [

                  TextFormField(
                    controller: emailcontroller,

                    keyboardType:
                    TextInputType.emailAddress,

                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),

                    decoration:
                    const InputDecoration(
                      labelText: 'Enter Email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: _verifyEmail,

                      icon: const Icon(
                        Icons.verified_user,
                      ),

                      label: const Text(
                        'Verify Email',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ================================================================
// OTP PAGE
// ================================================================

class OtpPage extends StatefulWidget {

  final String email;

  const OtpPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpPage> createState() =>
      _OtpPageState();
}


class _OtpPageState extends State<OtpPage> {

  final TextEditingController otpController =
  TextEditingController();


  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }


  Future<void> _verifyOtp() async {

    SharedPreferences sh =
    await SharedPreferences.getInstance();

    String? url = sh.getString('url');

    if (url == null) return;

    final urls = Uri.parse(
      '$url/verifyOtpflutterPost/',
    );

    final response = await http.post(
      urls,

      body: {
        'entered_otp':
        otpController.text.trim(),

        'email': widget.email,
      },
    );


    if (response.statusCode == 200) {

      var data = jsonDecode(
        response.body,
      );

      if (data['status'] == 'ok') {

        if (!mounted) return;

        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) =>
                NewPasswordPage(
                  email: widget.email,
                ),
          ),
        );

      } else {

        Fluttertoast.showToast(
          msg: 'Invalid OTP',
        );
      }

    } else {

      Fluttertoast.showToast(
        msg: 'Network Error',
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter OTP',
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              _headerIcon(
                Icons.sms,
              ),

              const SizedBox(height: 22),

              _headerText(
                'Verify OTP',
                'We sent a code to ${widget.email}. Enter it below to continue.',
              ),

              const SizedBox(height: 26),

              _formCard(
                children: [

                  TextFormField(
                    controller: otpController,

                    keyboardType:
                    TextInputType.number,

                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                    ),

                    decoration:
                    const InputDecoration(
                      labelText: "Enter OTP",
                      prefixIcon: Icon(
                        Icons.numbers,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: _verifyOtp,

                      icon: const Icon(
                        Icons.check_circle_outline,
                      ),

                      label: const Text(
                        "Verify OTP",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ================================================================
// NEW PASSWORD PAGE
// ================================================================

class NewPasswordPage extends StatefulWidget {

  final String email;

  const NewPasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<NewPasswordPage> createState() =>
      _NewPasswordPageState();
}


class _NewPasswordPageState
    extends State<NewPasswordPage> {

  final TextEditingController passController =
  TextEditingController();

  final TextEditingController confirmController =
  TextEditingController();


  @override
  void dispose() {
    passController.dispose();
    confirmController.dispose();
    super.dispose();
  }


  Future<void> _changePassword() async {

    SharedPreferences sh =
    await SharedPreferences.getInstance();

    String? url = sh.getString('url');

    if (url == null) return;

    final urls = Uri.parse(
      '$url/changePasswordflutter/',
    );

    final response = await http.post(
      urls,

      body: {
        'newPassword':
        passController.text.trim(),

        'confirmPassword':
        confirmController.text.trim(),

        'email': widget.email,
      },
    );


    if (response.statusCode == 200) {

      var data = jsonDecode(
        response.body,
      );

      if (data['status'] == 'ok') {

        Fluttertoast.showToast(
          msg: 'Password changed successfully',
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder: (context) =>
                loginpage(),
          ),
        );

      } else {

        Fluttertoast.showToast(
          msg: data['message']?.toString() ??
              'Error',
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reset Password',
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              _headerIcon(
                Icons.lock_outline,
              ),

              const SizedBox(height: 22),

              _headerText(
                'Create new password',
                'Choose a strong password you have not used before.',
              ),

              const SizedBox(height: 26),

              _formCard(
                children: [

                  TextFormField(
                    controller: passController,

                    obscureText: true,

                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),

                    decoration:
                    const InputDecoration(
                      labelText: "New Password",
                      prefixIcon: Icon(
                        Icons.password,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: confirmController,

                    obscureText: true,

                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),

                    decoration:
                    const InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: Icon(
                        Icons.password_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: _changePassword,

                      icon: const Icon(
                        Icons.save,
                      ),

                      label: const Text(
                        "Change Password",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}