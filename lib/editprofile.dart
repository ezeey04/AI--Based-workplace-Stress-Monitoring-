import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Same purple palette as the login / home / profile pages
/// (own class name so it never clashes with AppColors, HomeColors, ProfileColors)
class EditColors {
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

class editprofile extends StatefulWidget {
  const editprofile({super.key});

  @override
  State<editprofile> createState() => _editprofileState();
}

class _editprofileState extends State<editprofile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController experienceController = TextEditingController();

  String? gender_;

  String photo_ = "";

  File? selectedImage;

  bool loading = true;

  bool updating = false;

  bool _failed = false;

  bool _photoHovered = false;

  static const int _minAge = 18;

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    qualificationController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  // ---------------- VALIDATORS ----------------

  String? _validateName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your name.';
    if (t.length < 2) return 'Name is too short.';
    if (t.length > 50) return 'Name must be 50 characters or fewer.';
    if (!RegExp(r"^[A-Za-z][A-Za-z .'-]*$").hasMatch(t)) {
      return 'Name can only contain letters, spaces, . \' and -';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your email address.';
    if (t.length > 100) return 'Email is too long.';
    if (!RegExp(
        r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$')
        .hasMatch(t)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your phone number.';
    if (!RegExp(r'^[0-9]+$').hasMatch(t)) {
      return 'Phone number can contain digits only.';
    }
    if (t.length != 10) return 'Phone number must be exactly 10 digits.';
    if (!RegExp(r'^[6-9]').hasMatch(t)) {
      return 'Phone number must start with 6, 7, 8 or 9.';
    }
    if (RegExp(r'^(\d)\1+$').hasMatch(t)) {
      return 'Phone number looks invalid.';
    }
    return null;
  }

  String? _validateGender(String? v) {
    if (v == null || v.isEmpty) return 'Please select your gender.';
    return null;
  }

  String? _validateDob(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please select your date of birth.';

    final dob = DateTime.tryParse(t);
    if (dob == null) return 'Invalid date of birth.';

    final now = DateTime.now();
    if (dob.isAfter(now)) return 'Date of birth cannot be in the future.';

    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    if (age < _minAge) return 'You must be at least $_minAge years old.';
    if (age > 100) return 'Please enter a valid date of birth.';
    return null;
  }

  String? _validateQualification(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your qualification.';
    if (t.length < 2) return 'Qualification is too short.';
    if (t.length > 60) return 'Qualification must be 60 characters or fewer.';
    if (!RegExp(r'[A-Za-z]').hasMatch(t)) {
      return 'Qualification must contain letters.';
    }
    return null;
  }

  String? _validateExperience(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your experience.';

    // accepts: 3, 3.5, 3 years, 2 yrs, 6 months, fresher
    if (t.toLowerCase() == 'fresher') return null;

    final m = RegExp(r'^(\d{1,2}(?:\.\d)?)\s*(years?|yrs?|months?)?$',
        caseSensitive: false)
        .firstMatch(t);
    if (m == null) {
      return 'Use a format like "3 years", "6 months" or "Fresher".';
    }

    final value = double.parse(m.group(1)!);
    final unit = (m.group(2) ?? 'years').toLowerCase();
    final years = unit.startsWith('month') ? value / 12 : value;

    if (years > 50) return 'Experience looks too high.';
    return null;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditColors.bg,
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
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            color: EditColors.accent,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_failed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: EditColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: EditColors.coral),
            const SizedBox(height: 12),
            const Text(
              'Could not load your profile',
              style: TextStyle(
                color: EditColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: EditColors.subtitle, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: getdata,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: TextButton.styleFrom(foregroundColor: EditColors.accent),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal Details'),
          _card([
            _FormField(
              label: 'Name',
              hint: 'Your full name',
              icon: Icons.person_outline_rounded,
              controller: nameController,
              validator: _validateName,
              textInputAction: TextInputAction.next,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z .'-]")),
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            _FormField(
              label: 'Email',
              hint: 'you@company.com',
              icon: Icons.mail_outline_rounded,
              controller: emailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              formatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            _FormField(
              label: 'Phone',
              hint: 'Your 10 digit phone number',
              icon: Icons.phone_outlined,
              controller: phoneController,
              validator: _validatePhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            _GenderField(
              value: gender_,
              validator: _validateGender,
              onChanged: (v) => setState(() => gender_ = v),
            ),
            _FormField(
              label: 'Date of Birth',
              hint: 'Select your date of birth',
              icon: Icons.cake_outlined,
              controller: dobController,
              validator: _validateDob,
              readOnly: true,
              onTap: selectDate,
              suffix: const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: EditColors.icon,
              ),
            ),
          ]),
          const SizedBox(height: 22),
          _sectionTitle('Professional Details'),
          _card([
            _FormField(
              label: 'Qualification',
              hint: 'e.g. B.Tech, MBA',
              icon: Icons.school_outlined,
              controller: qualificationController,
              validator: _validateQualification,
              textInputAction: TextInputAction.next,
              formatters: [LengthLimitingTextInputFormatter(60)],
            ),
            _FormField(
              label: 'Experience',
              hint: 'e.g. 3 years',
              icon: Icons.work_outline_rounded,
              controller: experienceController,
              validator: _validateExperience,
              textInputAction: TextInputAction.done,
              formatters: [LengthLimitingTextInputFormatter(15)],
            ),
          ]),
          const SizedBox(height: 28),
          _UpdateButton(loading: updating, onTap: _submit),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: EditColors.title,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          fontFamily: 'serif',
        ),
      ),
    );
  }

  Widget _card(List<Widget> fields) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EditColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: EditColors.softShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < fields.length; i++) ...[
            fields[i],
            if (i != fields.length - 1) const SizedBox(height: 18),
          ],
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
          colors: [EditColors.gradA, EditColors.gradB, EditColors.gradC],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: EditColors.cardShadow,
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
                      'Edit Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // keeps the title centred
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: 24),
              _buildPhoto(),
              const SizedBox(height: 14),
              const Text(
                'Tap the photo to change it',
                style: TextStyle(
                  color: EditColors.leftText,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    const size = 116.0;

    Widget fallback() => const Center(
      child: Icon(Icons.person_rounded, color: Colors.white, size: 60),
    );

    Widget image;
    if (selectedImage != null) {
      image = Image.file(selectedImage!, fit: BoxFit.cover);
    } else if (photo_.isNotEmpty && photo_ != 'null') {
      image = Image.network(
        photo_,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    } else {
      image = fallback();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _photoHovered = true),
      onExit: (_) => setState(() => _photoHovered = false),
      child: GestureDetector(
        onTap: selectphoto,
        child: AnimatedScale(
          scale: _photoHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: SizedBox(
            width: size + 6,
            height: size + 6,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(4),
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
                  child: ClipOval(child: image),
                ),
                // camera badge
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border:
                      Border.all(color: EditColors.badgeBg, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: EditColors.cardShadow,
                          blurRadius: 14,
                          offset: Offset(0, 6),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: EditColors.accent,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- ACTIONS ----------------

  // SELECT PHOTO

  Future<void> selectphoto() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
    );

    if (image == null) return;

    final ext = image.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      Fluttertoast.showToast(msg: 'Please choose a JPG, PNG or WEBP image');
      return;
    }

    final file = File(image.path);
    if (await file.length() > 5 * 1024 * 1024) {
      Fluttertoast.showToast(msg: 'Image must be smaller than 5 MB');
      return;
    }

    if (!mounted) return;
    setState(() => selectedImage = file);
  }

  // SELECT DATE

  Future<void> selectDate() async {
    final now = DateTime.now();
    final latestAllowed = DateTime(now.year - _minAge, now.month, now.day);

    DateTime initialDate = DateTime(2000, 1, 1);

    if (dobController.text.isNotEmpty) {
      initialDate = DateTime.tryParse(dobController.text) ?? initialDate;
    }
    if (initialDate.isAfter(latestAllowed)) initialDate = latestAllowed;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: latestAllowed,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: EditColors.accent,
              onPrimary: Colors.white,
              onSurface: EditColors.ink,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String date =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      setState(() {
        dobController.text = date;
      });
    }
  }

  void _submit() {
    if (updating) return;

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    editdata();
  }

  // GET PROFILE

  Future<void> getdata() async {
    setState(() {
      loading = true;
      _failed = false;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();

      String url = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';

      final urls = Uri.parse(
        '$url/teammemberviewprofile_post/',
      );

      final response = await http.post(
        urls,
        body: {
          'lid': lid,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);

        if (jsondata['status'] == 'ok') {
          String gender =
          jsondata['gender'].toString().trim().toLowerCase();

          if (!mounted) return;

          setState(() {
            nameController.text = jsondata['name'].toString();
            emailController.text = jsondata['email'].toString();
            final rawPhone =
            jsondata['phone'].toString().replaceAll(RegExp(r'\D'), '');
            phoneController.text = rawPhone.length > 10
                ? rawPhone.substring(rawPhone.length - 10)
                : rawPhone;
            dobController.text = jsondata['dob'].toString();
            qualificationController.text =
                jsondata['qualification'].toString();
            experienceController.text = jsondata['experience'].toString();
            photo_ = jsondata['photo'].toString();

            // EXISTING GENDER
            if (gender == 'male') {
              gender_ = 'Male';
            } else if (gender == 'female') {
              gender_ = 'Female';
            } else if (gender == 'other') {
              gender_ = 'Other';
            } else {
              gender_ = null;
            }

            loading = false;
          });
          return;
        } else {
          Fluttertoast.showToast(msg: 'Profile loading failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error');
      }

      if (mounted) {
        setState(() {
          loading = false;
          _failed = true;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not connect to the server');
      if (mounted) {
        setState(() {
          loading = false;
          _failed = true;
        });
      }
    }
  }

  // UPDATE PROFILE

  Future<void> editdata() async {
    setState(() {
      updating = true;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();

      String url = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';

      final urls = Uri.parse(
        '$url/mobileeditprofile/',
      );

      var request = http.MultipartRequest(
        'POST',
        urls,
      );

      request.fields['lid'] = lid;
      request.fields['name'] = nameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['phone'] = phoneController.text.trim();
      request.fields['gender'] = gender_ ?? '';
      request.fields['dob'] = dobController.text;
      request.fields['qualification'] = qualificationController.text.trim();
      request.fields['experience'] = experienceController.text.trim();

      // PHOTO

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            selectedImage!.path,
          ),
        );
      }

      var response =
      await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();

        var jsondata = jsonDecode(responseData);

        if (jsondata['status'] == 'ok') {
          Fluttertoast.showToast(
            msg: 'Profile updated successfully',
          );

          if (!mounted) return;

          // RETURN TRUE TO VIEW PROFILE
          Navigator.pop(
            context,
            true,
          );
          return;
        } else {
          Fluttertoast.showToast(
            msg: 'Profile update failed',
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Server error',
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not connect to the server');
    }

    if (mounted) {
      setState(() {
        updating = false;
      });
    }
  }
}

// =====================================================
//  WIDGETS
// =====================================================

/// Shared input decoration (same look as the login page fields)
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
    hintStyle: const TextStyle(color: EditColors.hint, fontSize: 14.5),
    filled: true,
    fillColor: focused ? Colors.white : EditColors.fill,
    prefixIcon: Icon(
      icon,
      size: 20,
      color: (focused || hovered) ? EditColors.accent : EditColors.icon,
    ),
    suffixIcon: suffix == null
        ? null
        : Padding(
      padding: const EdgeInsets.only(right: 4),
      child: suffix,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
    errorStyle: const TextStyle(
      color: EditColors.coral,
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
    ),
    errorMaxLines: 2,
    enabledBorder: border(hovered ? EditColors.borderHover : EditColors.border),
    focusedBorder: border(EditColors.accent),
    errorBorder: border(EditColors.coral),
    focusedErrorBorder: border(EditColors.coral),
  );
}

Widget _fieldLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: EditColors.ink,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Text field with label, hover border, focus ring
class _FormField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final List<TextInputFormatter>? formatters;

  const _FormField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.formatters,
  });

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  final FocusNode _focus = FocusNode();
  bool _hovered = false;

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
        _fieldLabel(widget.label),
        MouseRegion(
          cursor: widget.readOnly
              ? SystemMouseCursors.click
              : SystemMouseCursors.text,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              boxShadow: focused
                  ? const [
                BoxShadow(
                  color: EditColors.focusRing,
                  spreadRadius: 4,
                  blurRadius: 0,
                ),
              ]
                  : const [],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focus,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.formatters,
              validator: widget.validator,
              cursorColor: EditColors.accent,
              style: const TextStyle(color: EditColors.ink, fontSize: 14.5),
              decoration: _inputDecoration(
                hint: widget.hint,
                icon: widget.icon,
                hovered: _hovered && !focused,
                focused: focused,
                suffix: widget.suffix,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gender dropdown styled like the other fields
class _GenderField extends StatefulWidget {
  final String? value;
  final String? Function(String?) validator;
  final ValueChanged<String?> onChanged;

  const _GenderField({
    required this.value,
    required this.validator,
    required this.onChanged,
  });

  @override
  State<_GenderField> createState() => _GenderFieldState();
}

class _GenderFieldState extends State<_GenderField> {
  final FocusNode _focus = FocusNode();
  bool _hovered = false;

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
        _fieldLabel('Gender'),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              boxShadow: focused
                  ? const [
                BoxShadow(
                  color: EditColors.focusRing,
                  spreadRadius: 4,
                  blurRadius: 0,
                ),
              ]
                  : const [],
            ),
            child: DropdownButtonFormField<String>(
              value: widget.value,
              focusNode: _focus,
              validator: widget.validator,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: EditColors.icon,
              ),
              style: const TextStyle(color: EditColors.ink, fontSize: 14.5),
              decoration: _inputDecoration(
                hint: 'Select your gender',
                icon: Icons.wc_rounded,
                hovered: _hovered && !focused,
                focused: focused,
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient "Update Profile" button. HOVER: lifts, shadow grows.
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
              colors: [EditColors.gradA, EditColors.btnB],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: hovered
                    ? EditColors.btnShadowHover
                    : EditColors.btnShadow,
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
                      'Update Profile',
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