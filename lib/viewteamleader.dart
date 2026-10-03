import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Same purple palette as the login / home / profile / edit profile pages
/// (own class name so it never clashes with the other color classes)
class TlColors {
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
  static const icon = Color(0xFF8A7AA3);

  static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
  static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
}

class viewteamleader extends StatefulWidget {
  const viewteamleader({super.key});

  @override
  State<viewteamleader> createState() => _viewteamleaderState();
}

class _viewteamleaderState extends State<viewteamleader> {
  List<Map<String, dynamic>> teamleadders = [];

  bool loading = true;
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
      backgroundColor: TlColors.bg,
      body: RefreshIndicator(
        color: TlColors.accent,
        onRefresh: getdata,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            color: TlColors.accent,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_failed) {
      return _messageCard(
        icon: Icons.cloud_off_rounded,
        iconColor: TlColors.coral,
        title: 'Could not load team leaders',
        message: 'Please check your connection and try again.',
        action: TextButton.icon(
          onPressed: getdata,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
          style: TextButton.styleFrom(foregroundColor: TlColors.accent),
        ),
      );
    }

    if (teamleadders.isEmpty) {
      return _messageCard(
        icon: Icons.groups_2_outlined,
        iconColor: TlColors.accent,
        title: 'No team leader found',
        message: 'Team leader details will appear here once assigned.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2),
          child: Text(
            teamleadders.length == 1 ? 'Your team leader' : 'Your Team Leaders',
            style: const TextStyle(
              color: TlColors.title,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
        ),
        for (int i = 0; i < teamleadders.length; i++) ...[
          _leaderCard(teamleadders[i]),
          if (i != teamleadders.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _messageCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TlColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TlColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TlColors.subtitle, fontSize: 13.5),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }

  Widget _leaderCard(Map<String, dynamic> t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TlColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: TlColors.softShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        children: [
          _avatar(t['photo'].toString()),
          const SizedBox(height: 14),
          Text(
            t['name'].toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TlColors.title,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: TlColors.badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Team Leader',
              style: TextStyle(
                color: TlColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: TlColors.border, height: 1),
          const SizedBox(height: 16),
          _infoRow(Icons.mail_outline_rounded, 'Email', t['email'].toString()),
          const SizedBox(height: 14),
          _infoRow(Icons.phone_outlined, 'Phone', t['phone'].toString()),
          const SizedBox(height: 14),
          _infoRow(Icons.wc_rounded, 'Gender', t['gender'].toString()),
          const SizedBox(height: 14),
          _infoRow(Icons.cake_outlined, 'Date of Birth', t['dob'].toString()),
        ],
      ),
    );
  }

  Widget _avatar(String photo) {
    const size = 104.0;

    Widget fallback() => const Center(
      child: Icon(Icons.person_rounded, color: Colors.white, size: 54),
    );

    Widget image;
    if (photo.isNotEmpty && photo != 'null') {
      image = Image.network(
        photo,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => fallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    } else {
      image = fallback();
    }

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [TlColors.gradA, TlColors.gradC],
        ),
        border: Border.all(color: TlColors.badgeBg, width: 3),
        boxShadow: const [
          BoxShadow(
            color: TlColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipOval(child: image),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final shown = (value.isEmpty || value == 'null') ? '-' : value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: TlColors.badgeBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: TlColors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: TlColors.subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                shown,
                style: const TextStyle(
                  color: TlColors.ink,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
          colors: [TlColors.gradA, TlColors.gradB, TlColors.gradC],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: TlColors.cardShadow,
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
                      'Team Leader',
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
              const SizedBox(height: 22),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(255, 255, 255, 0.22),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.55),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.groups_2_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pull down to refresh',
                style: TextStyle(color: TlColors.leftText, fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ACTIONS ----------------

  Future<void> getdata() async {
    if (mounted) {
      setState(() {
        loading = true;
        _failed = false;
      });
    }

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';

      final urls = Uri.parse('$url/mobileviewteamleader/');

      final response = await http.post(urls, body: {
        'lid': lid,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);

        if (jsondata['status'].toString() == 'ok') {
          List<Map<String, dynamic>> temp = [];

          for (var i in jsondata['data']) {
            temp.add({
              'id': i['id'].toString(),
              'name': i['name'].toString(),
              'email': i['email'].toString(),
              'phone': i['phone'].toString(),
              'photo': i['photo'].toString(),
              'gender': i['gender'].toString(),
              'dob': i['dob'].toString(),
            });
          }

          if (!mounted) return;

          setState(() {
            teamleadders = temp;
            loading = false;
          });
          return;
        } else {
          Fluttertoast.showToast(msg: 'Team leader loading failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not connect to the server');
    }

    if (mounted) {
      setState(() {
        loading = false;
        _failed = true;
      });
    }
  }
}

// =====================================================
//  WIDGETS
// =====================================================

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