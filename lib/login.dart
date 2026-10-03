import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/home.dart';
import 'package:untitled/forgetpassword.dart';

void main() {
  runApp(const myapp());
}

/// EXACT colour values copied from the HTML login page CSS
class AppColors {
  static const bg = Color(0xFFFAF7FC);

  static const gradA = Color(0xFF7C4AD8);
  static const gradB = Color(0xFF6538BD);
  static const gradC = Color(0xFF4B2992);

  static const btnA = Color(0xFF7C4AD8);
  static const btnB = Color(0xFF4D2997);

  static const title = Color(0xFF4D2B91);
  static const ink = Color(0xFF352746);
  static const subtitle = Color(0xFF76698D);
  static const leftText = Color(0xFFEAE1FB);

  static const accent = Color(0xFF7040C9);
  static const badgeBg = Color(0xFFF1E9FF);
  static const coral = Color(0xFFE0457B);

  static const border = Color(0xFFE6DCF3);
  static const borderHover = Color(0xFFC9B6E8); // .input-box:hover
  static const fill = Color(0xFFFBF9FD);
  static const icon = Color(0xFF8A7AA3);
  static const hint = Color(0xFFA8A0B8);
  static const security = Color(0xFF9A8FB0);

  static const purpleGlow = Color.fromRGBO(116, 68, 208, 0.12);
  static const coralGlow = Color.fromRGBO(224, 69, 123, 0.09);
  static const focusRing = Color.fromRGBO(112, 64, 201, 0.10);
  static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
  static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
  static const btnShadowHover = Color.fromRGBO(91, 48, 170, 0.6);
}

class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.gradA),
      ),
      home: const loginpage(),
    );
  }
}

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  final TextEditingController usernamecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;

  /// ids of the widgets the mouse pointer is currently over
  final Set<String> _hover = {};

  void _setHover(String id, bool hovering) {
    final changed = hovering ? _hover.add(id) : _hover.remove(id);
    if (changed) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ---------------- VALIDATORS ----------------

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your email address.';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v)) return 'Please enter a valid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.trim().isEmpty) return 'Please enter your password.';
    if (v.length < 4) return 'Password is too short.';
    return null;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -180,
            left: -160,
            child: _glow(520, AppColors.purpleGlow),
          ),
          Positioned(
            bottom: -160,
            right: -140,
            child: _glow(460, AppColors.coralGlow),
          ),
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildFormSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(28, topPad + 28, 28, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [AppColors.gradA, AppColors.gradB, AppColors.gradC],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 40,
            offset: Offset(0, 20),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -100 - 28,
            right: -90 - 28,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 255, 255, 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -100 - 28,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 255, 255, 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.16),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Calmora ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Illustration – HOVER: gently grows (like .illustration-3d:hover)
              Center(
                child: MouseRegion(
                  onEnter: (_) => _setHover('illus', true),
                  onExit: (_) => _setHover('illus', false),
                  child: AnimatedScale(
                    scale: _hover.contains('illus') ? 1.07 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(255, 255, 255, 0.12),
                        border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(255, 255, 255, 0.18),
                          ),
                          child: const Icon(
                            Icons.self_improvement_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Understand and manage\nworkplace stress, together.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'One console for admins, HR, and team leaders to track wellbeing, assign work, and catch burnout risk early.',
                style: TextStyle(
                  color: AppColors.leftText,
                  fontSize: 14.5,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.badgeBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(radius: 3, backgroundColor: AppColors.accent),
                  SizedBox(width: 6),
                  Text(
                    'SECURE SIGN IN',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Welcome Back',
              style: TextStyle(
                color: AppColors.title,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log in with your registered email to continue.',
              style: TextStyle(color: AppColors.subtitle, fontSize: 14.5),
            ),
            const SizedBox(height: 30),

            // EMAIL
            _label('Email'),
            _field(
              id: 'email',
              controller: usernamecontroller,
              focusNode: _emailFocus,
              hint: 'you@company.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              validator: _validateEmail,
              onSubmitted: (_) => _passFocus.requestFocus(),
            ),
            const SizedBox(height: 18),

            // PASSWORD
            _label('Password'),
            _field(
              id: 'pass',
              controller: passwordcontroller,
              focusNode: _passFocus,
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: _validatePassword,
              onSubmitted: (_) => _submit(),
              // HOVER: eye turns purple with a soft lavender circle
              suffix: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => _setHover('eye', true),
                onExit: (_) => _setHover('eye', false),
                child: IconButton(
                  splashRadius: 20,
                  hoverColor: AppColors.badgeBg,
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: (_passFocus.hasFocus || _hover.contains('eye'))
                        ? AppColors.accent
                        : AppColors.icon,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // FORGOT PASSWORD – HOVER: underline
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => forgot(),
                    ),
                  );
                },
                onHover: (h) => _setHover('forgot', h),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 36),
                ),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    decoration: _hover.contains('forgot')
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: AppColors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            _buildLoginButton(),
            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shield_outlined, size: 13, color: AppColors.security),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Your data is encrypted and access is role-based',
                    style: TextStyle(color: AppColors.security, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _field({
    required String id,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmitted,
  }) {
    final focused = focusNode.hasFocus;
    final hovered = _hover.contains(id) && !focused;

    OutlineInputBorder border(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: color, width: width),
        );

    // HOVER: border darkens to #C9B6E8 (input-box:hover in the CSS)
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      onEnter: (_) => _setHover(id, true),
      onExit: (_) => _setHover(id, false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: focused
              ? const [
            BoxShadow(
              color: AppColors.focusRing,
              spreadRadius: 4,
              blurRadius: 0,
            ),
          ]
              : const [],
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          cursorColor: AppColors.accent,
          style: const TextStyle(color: AppColors.ink, fontSize: 14.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14.5),
            filled: true,
            fillColor: focused ? Colors.white : AppColors.fill,
            prefixIcon: Icon(
              icon,
              size: 20,
              color: (focused || hovered) ? AppColors.accent : AppColors.icon,
            ),
            suffixIcon: suffix,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            errorStyle: const TextStyle(
              color: AppColors.coral,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            enabledBorder:
            border(hovered ? AppColors.borderHover : AppColors.border),
            focusedBorder: border(AppColors.accent),
            errorBorder: border(AppColors.coral),
            focusedErrorBorder: border(AppColors.coral),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final hovered = _hover.contains('btn') && !_loading;

    return Opacity(
      opacity: _loading ? 0.75 : 1,
      child: MouseRegion(
        cursor:
        _loading ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => _setHover('btn', true),
        onExit: (_) => _setHover('btn', false),
        // HOVER: lifts 2px, shadow grows, arrow slides right
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-1, -0.09),
              end: Alignment(1, 0.09),
              colors: [AppColors.btnA, AppColors.btnB],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: hovered
                    ? AppColors.btnShadowHover
                    : AppColors.btnShadow,
                blurRadius: hovered ? 32 : 28,
                offset: Offset(0, hovered ? 18 : 14),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: _loading ? null : _submit,
              child: Center(
                child: _loading
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Logging in...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 9),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      offset: Offset(hovered ? 0.17 : 0, 0),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- LOGIC ----------------

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    senddata();
  }

  Future<void> senddata() async {
    String username = usernamecontroller.text.trim();
    String password = passwordcontroller.text;

    setState(() => _loading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();

      String url = sh.getString('url') ?? '';

      if (url.isEmpty) {
        Fluttertoast.showToast(msg: 'Server URL is not set');
        return;
      }

      final urls = Uri.parse('$url/mobileteammemberlogin_post/');

      final response = await http.post(
        urls,
        body: {
          'username': username,
          'password': password,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String status = data['status'];

        if (status == 'ok') {
          String lid = data['lid'].toString();

          await sh.setString('lid', lid);

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          Fluttertoast.showToast(msg: 'Invalid email or password');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not connect to the server');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}