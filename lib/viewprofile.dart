import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'editprofile.dart';

/// Same purple palette as the login and home pages
/// (own class name so it never clashes with AppColors / HomeColors)
class ProfileColors {
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
  static const icon = Color(0xFF8A7AA3);

  static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
  static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
  static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
  static const btnShadowHover = Color.fromRGBO(91, 48, 170, 0.6);
}

class viewprofile extends StatefulWidget {
  const viewprofile({super.key});

  @override
  State<viewprofile> createState() => _viewprofileState();
}

class _viewprofileState extends State<viewprofile> {
  String name_ = "";
  String email_ = "";
  String photo_ = "";
  String phone_ = "";
  String gender_ = "";
  String dob_ = "";
  String qualification_ = "";
  String experience_ = "";

  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    getdata();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.bg,
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            color: ProfileColors.accent,
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
          border: Border.all(color: ProfileColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: ProfileColors.coral),
            const SizedBox(height: 12),
            const Text(
              'Could not load your profile',
              style: TextStyle(
                color: ProfileColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ProfileColors.subtitle, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: getdata,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: TextButton.styleFrom(
                foregroundColor: ProfileColors.accent,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Personal Details'),
        _InfoCard(
          rows: [
            _InfoRow(Icons.mail_outline_rounded, 'Email', email_),
            _InfoRow(Icons.phone_outlined, 'Phone', phone_),
            _InfoRow(Icons.wc_rounded, 'Gender', gender_),
            _InfoRow(Icons.cake_outlined, 'Date of birth', dob_),
          ],
        ),
        const SizedBox(height: 22),
        _sectionTitle('Professional Details'),
        _InfoCard(
          rows: [
            _InfoRow(Icons.school_outlined, 'Qualification', qualification_),
            _InfoRow(Icons.work_outline_rounded, 'Experience', experience_),
          ],
        ),
        const SizedBox(height: 28),
        _EditButton(onTap: _openEdit),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: ProfileColors.title,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          fontFamily: 'serif',
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [
            ProfileColors.gradA,
            ProfileColors.gradB,
            ProfileColors.gradC,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: ProfileColors.cardShadow,
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
                      'My Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.edit_rounded,
                    tooltip: 'Edit profile',
                    onTap: _openEdit,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _buildAvatar(),
              const SizedBox(height: 16),
              Text(
                name_.isEmpty ? (_loading ? 'Loading...' : '—') : name_,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.16),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.24),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: ProfileColors.leftText,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'TEAM MEMBER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const size = 112.0;

    Widget fallback() => const Center(
      child: Icon(Icons.person_rounded, color: Colors.white, size: 58),
    );

    return Container(
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
      child: ClipOval(
        child: photo_.isEmpty || photo_ == 'null'
            ? fallback()
            : Image.network(
          photo_,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => fallback(),
        ),
      ),
    );
  }

  // ---------------- LOGIC ----------------

  Future<void> _openEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => editprofile(),
      ),
    );

    // reload so changes made in the edit page show up immediately
    if (mounted) getdata();
  }

  Future<void> getdata() async {
    setState(() {
      _loading = true;
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
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          if (!mounted) return;

          setState(() {
            name_ = data['name'].toString();
            email_ = data['email'].toString();
            phone_ = data['phone'].toString();
            photo_ = data['photo'].toString();
            gender_ = data['gender'].toString();
            dob_ = data['dob'].toString();
            qualification_ = data['qualification'].toString();
            experience_ = data['experience'].toString();
            _loading = false;
          });
          return;
        } else {
          Fluttertoast.showToast(msg: 'Profile loading failed');
        }
      }

      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not connect to the server');
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }
}

// =====================================================
//  WIDGETS
// =====================================================

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);
}

/// White rounded card that holds several rows
class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ProfileColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: ProfileColors.softShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _InfoTile(row: rows[i]),
            if (i != rows.length - 1)
              const Divider(
                height: 1,
                indent: 70,
                color: ProfileColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

/// One detail row. HOVER: lavender background, icon tile fills with purple.
class _InfoTile extends StatefulWidget {
  final _InfoRow row;

  const _InfoTile({required this.row});

  @override
  State<_InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<_InfoTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final value = widget.row.value.trim();
    final shown = (value.isEmpty || value == 'null') ? '—' : value;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _hovered ? const Color(0xFFFBF9FD) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: _hovered ? null : ProfileColors.badgeBg,
                gradient: _hovered
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ProfileColors.gradA, ProfileColors.gradC],
                )
                    : null,
              ),
              child: Icon(
                widget.row.icon,
                size: 21,
                color: _hovered ? Colors.white : ProfileColors.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.row.label,
                    style: const TextStyle(
                      color: ProfileColors.subtitle,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    shown,
                    style: const TextStyle(
                      color: ProfileColors.ink,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient "Edit Profile" button. HOVER: lifts, shadow grows.
class _EditButton extends StatefulWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1, -0.09),
            end: Alignment(1, 0.09),
            colors: [ProfileColors.gradA, ProfileColors.btnB],
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? ProfileColors.btnShadowHover
                  : ProfileColors.btnShadow,
              blurRadius: _hovered ? 32 : 28,
              offset: Offset(0, _hovered ? 18 : 14),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: widget.onTap,
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 9),
                  Text(
                    'Edit Profile',
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