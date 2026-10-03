import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/login.dart';

/// Same purple palette as the login / home / profile / edit profile pages
/// (own class name so it never clashes with the other color classes)
class PwdColors {
  static const bg = Color(0xFFFAF7FC);

  static const gradA = Color(0xFF7C4AD8);
  static const gradB = Color(0xFF6538BD);
  static const gradC = Color(0xFF4B2992);
  static const btnB = Color(0xFF4D2997);

  static const title = Color(0xFF4D2B91);
  static const ink = Color(0xFF352746);
  static const subtitle = Color(0xFF76698D);
  static const leftText = Color(0xFFEAE1FB);

  static const accent = Color(0xFF7040C9);
  static const badgeBg = Color(0xFFF1E9FF);
  static const coral = Color(0xFFE0457B);
  static const green = Color(0xFF2E9F6B);
  static const amber = Color(0xFFE0A030);

  static const border = Color(0xFFE6DCF3);
  static const borderHover = Color(0xFFC9B6E8);
  static const fill = Color(0xFFFBF9FD);
  static const icon = Color(0xFF8A7AA3);
  static const hint = Color(0xFFA8A0B8);

  static const focusRing = Color.fromRGBO(112, 64, 201, 0.10);
  static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
  static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
  static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
  static const btnShadowHover = Color.fromRGBO(91, 48, 170, 0.6);
}

class changepassword extends StatefulWidget {
  const changepassword({super.key});

  @override
  State<changepassword> createState() => _changepasswordState();
}

class _changepasswordState extends State<changepassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController currentcontroller = TextEditingController();
  final TextEditingController newcontroller = TextEditingController();
  final TextEditingController confirmcontroller = TextEditingController();

  final GlobalKey<FormFieldState<String>> _confirmKey =
  GlobalKey<FormFieldState<String>>();

  bool updating = false;

  @override
  void initState() {
    super.initState();
    // refresh strength meter as the user types the new password,
    // and re-check the confirm field live if it already has text
    newcontroller.addListener(() {
      setState(() {});
      if (confirmcontroller.text.isNotEmpty) {
        _confirmKey.currentState?.validate();
      }
    });
    // refresh the "passwords match" indicator while typing
    confirmcontroller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    currentcontroller.dispose();
    newcontroller.dispose();
    confirmcontroller.dispose();
    super.dispose();
  }

  // ---------------- VALIDATORS ----------------

  String? _validateCurrent(String? v) {
    if ((v ?? '').isEmpty) return 'Please enter your current password.';
    return null;
  }

  String? _validateNew(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return 'Please enter a new password.';
    if (t.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Z]').hasMatch(t)) {
      return 'Include at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(t)) {
      return 'Include at least one lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(t)) return 'Include at least one number.';
    if (t == currentcontroller.text) {
      return 'New password must differ from the current one.';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'Please confirm your new password.';
    if (v != newcontroller.text) return 'Passwords do not match.';
    return null;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PwdColors.bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              _buildHeader(context),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 32),
                    child: _buildForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 2),
            child: Text(
              'Update your password',
              style: TextStyle(
                color: PwdColors.title,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                fontFamily: 'serif',
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: PwdColors.border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: PwdColors.softShadow,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Column(
              children: [
                _PasswordField(
                  label: 'Current Password',
                  hint: 'Enter your current password',
                  controller: currentcontroller,
                  validator: _validateCurrent,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 18),
                _PasswordField(
                  label: 'New Password',
                  hint: 'Enter a new password',
                  controller: newcontroller,
                  validator: _validateNew,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                _StrengthMeter(password: newcontroller.text),
                const SizedBox(height: 18),
                _PasswordField(
                  fieldKey: _confirmKey,
                  label: 'Confirm Password',
                  hint: 'Re-enter the new password',
                  controller: confirmcontroller,
                  validator: _validateConfirm,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  // validate while typing (no need to press the button)
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                _buildMatchIndicator(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Use at least 8 characters with uppercase, lowercase and a number.',
              style: TextStyle(color: PwdColors.subtitle, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 26),
          _UpdateButton(loading: updating, onTap: _submit),
        ],
      ),
    );
  }

  /// Green "Passwords match" hint shown live under the confirm field
  Widget _buildMatchIndicator() {
    final confirm = confirmcontroller.text;
    final matches = confirm.isNotEmpty && confirm == newcontroller.text;
    if (!matches) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.only(top: 8, left: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: PwdColors.green),
          SizedBox(width: 6),
          Text(
            'Passwords match',
            style: TextStyle(
              color: PwdColors.green,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [PwdColors.gradA, PwdColors.gradB, PwdColors.gradC],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: PwdColors.cardShadow,
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
            top: -90,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 255, 255, 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 255, 255, 0.04),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _HeaderButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Change Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(255, 255, 255, 0.22),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.55),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(15, 6, 40, 0.35),
                      blurRadius: 26,
                      offset: Offset(0, 12),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_reset_rounded,
                    color: Colors.white, size: 46),
              ),
              const SizedBox(height: 14),
              const Text(
                'Keep your account secure',
                style: TextStyle(color: PwdColors.leftText, fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ACTIONS ----------------

  void _submit() {
    FocusScope.of(context).unfocus();
    if (updating) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    senddata();
  }

  Future<void> senddata() async {
    setState(() => updating = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';

      final urls = Uri.parse('$url/teammemberchangepassword_post/');

      final response = await http.post(urls, body: {
        'lid': lid,
        'current': currentcontroller.text,
        'new': newcontroller.text,
        'confirm': confirmcontroller.text,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final status = jsonDecode(response.body)['status'].toString();

        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Password changed successfully');
          if (!mounted) return;
          // clear the back stack so the user must log in with the new password
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => loginpage()),
                (route) => false,
          );
          return;
        } else {
          Fluttertoast.showToast(
              msg: 'Password change failed. Check your current password.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not connect to the server');
    }

    if (mounted) setState(() => updating = false);
  }
}

// =====================================================
//  WIDGETS
// =====================================================

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  required bool hovered,
  required bool focused,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1.5]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: PwdColors.hint, fontSize: 14.5),
    filled: true,
    fillColor: focused ? Colors.white : PwdColors.fill,
    prefixIcon: Icon(
      icon,
      size: 20,
      color: (focused || hovered) ? PwdColors.accent : PwdColors.icon,
    ),
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
    errorStyle: const TextStyle(
      color: PwdColors.coral,
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
    ),
    errorMaxLines: 2,
    enabledBorder: border(hovered ? PwdColors.borderHover : PwdColors.border),
    focusedBorder: border(PwdColors.accent),
    errorBorder: border(PwdColors.coral),
    focusedErrorBorder: border(PwdColors.coral),
  );
}

/// Password field with label, show/hide toggle, hover border and focus ring
class _PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode? autovalidateMode;
  final Key? fieldKey;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
    this.fieldKey,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  final FocusNode _focus = FocusNode();
  bool _hovered = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: PwdColors.ink,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.text,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              boxShadow: focused
                  ? const [
                BoxShadow(
                  color: PwdColors.focusRing,
                  spreadRadius: 4,
                  blurRadius: 0,
                ),
              ]
                  : const [],
            ),
            child: TextFormField(
              key: widget.fieldKey,
              controller: widget.controller,
              focusNode: _focus,
              autovalidateMode: widget.autovalidateMode,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onSubmitted,
              validator: widget.validator,
              cursorColor: PwdColors.accent,
              style: const TextStyle(color: PwdColors.ink, fontSize: 14.5),
              decoration: _inputDecoration(
                hint: widget.hint,
                icon: Icons.lock_outline_rounded,
                hovered: _hovered && !focused,
                focused: focused,
                suffix: IconButton(
                  splashRadius: 20,
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: PwdColors.icon,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Simple 4-step strength bar for the new password
class _StrengthMeter extends StatelessWidget {
  final String password;

  const _StrengthMeter({required this.password});

  int get _score {
    if (password.isEmpty) return 0;
    int s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      s++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      PwdColors.border,
      PwdColors.coral,
      PwdColors.amber,
      PwdColors.accent,
      PwdColors.green,
    ];
    final active = colors[score];

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < score ? active : PwdColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (i != 3) const SizedBox(width: 5),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            labels[score],
            textAlign: TextAlign.right,
            style: TextStyle(
              color: active,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient action button. HOVER: lifts, shadow grows.
class _UpdateButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;

  const _UpdateButton({required this.loading, required this.onTap});

  @override
  State<_UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<_UpdateButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hovered = _hovered && !widget.loading;

    return Opacity(
      opacity: widget.loading ? 0.75 : 1,
      child: MouseRegion(
        cursor: widget.loading
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
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
              colors: [PwdColors.gradA, PwdColors.btnB],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: hovered
                    ? PwdColors.btnShadowHover
                    : PwdColors.btnShadow,
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
              onTap: widget.loading ? null : widget.onTap,
              child: Center(
                child: widget.loading
                    ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      'Updating...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
                    : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        color: Colors.white, size: 19),
                    SizedBox(width: 9),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
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
}

/// Round translucent icon button used in the header
class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Color.fromRGBO(255, 255, 255, _hovered ? 0.28 : 0.16),
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, _hovered ? 0.4 : 0.22),
              ),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}