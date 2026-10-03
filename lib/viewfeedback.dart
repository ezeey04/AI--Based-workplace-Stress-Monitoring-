import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Same purple palette as the login / home / profile / edit profile pages
/// (own class name so it never clashes with the other color classes)
class FbColors {
  static const bg = Color(0xFFFAF7FC);

  static const gradA = Color(0xFF7C4AD8);
  static const gradB = Color(0xFF6538BD);
  static const gradC = Color(0xFF4B2992);

  static const title = Color(0xFF4D2B91);
  static const ink = Color(0xFF352746);
  static const subtitle = Color(0xFF76698D);
  static const leftText = Color(0xFFEAE1FB);

  static const accent = Color(0xFF7040C9);
  static const badgeBg = Color(0xFFF1E9FF);
  static const coral = Color(0xFFE0457B);

  static const border = Color(0xFFE6DCF3);
  static const fill = Color(0xFFFBF9FD);

  static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
  static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
}

class viewfeedback extends StatefulWidget {
  const viewfeedback({super.key});

  @override
  State<viewfeedback> createState() => _viewfeedbackState();
}

class _viewfeedbackState extends State<viewfeedback> {
  List<Map<String, dynamic>> feedbacks = [];

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
      backgroundColor: FbColors.bg,
      body: RefreshIndicator(
        color: FbColors.accent,
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
            color: FbColors.accent,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_failed) {
      return _messageCard(
        icon: Icons.cloud_off_rounded,
        iconColor: FbColors.coral,
        title: 'Could not load feedback',
        message: 'Please check your connection and try again.',
        action: TextButton.icon(
          onPressed: getdata,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
          style: TextButton.styleFrom(foregroundColor: FbColors.accent),
        ),
      );
    }

    if (feedbacks.isEmpty) {
      return _messageCard(
        icon: Icons.feedback_outlined,
        iconColor: FbColors.accent,
        title: 'No feedback yet',
        message: 'Feedback from your team leader will appear here.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2),
          child: Text(
            '${feedbacks.length} ${feedbacks.length == 1 ? 'feedback' : 'Feedbacks'}',
            style: const TextStyle(
              color: FbColors.title,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
        ),
        for (int i = 0; i < feedbacks.length; i++) ...[
          _feedbackCard(feedbacks[i]),
          if (i != feedbacks.length - 1) const SizedBox(height: 16),
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
        border: Border.all(color: FbColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: FbColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: FbColors.subtitle, fontSize: 13.5),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }

  String _clean(dynamic v) {
    final s = (v ?? '').toString().trim();
    return (s.isEmpty || s == 'null') ? '-' : s;
  }

  Widget _feedbackCard(Map<String, dynamic> f) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FbColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: FbColors.softShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // work title + date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: FbColors.badgeBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.work_outline_rounded,
                    size: 21, color: FbColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Work',
                      style: TextStyle(
                        color: FbColors.subtitle,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _clean(f['worktitle']),
                      style: const TextStyle(
                        color: FbColors.title,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // team leader + date chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.person_outline_rounded, _clean(f['teamleader'])),
              _chip(Icons.calendar_today_rounded, _clean(f['date'])),
            ],
          ),
          const SizedBox(height: 14),
          // feedback text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FbColors.fill,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: FbColors.border, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.format_quote_rounded,
                        size: 18, color: FbColors.accent),
                    SizedBox(width: 6),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        color: FbColors.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _clean(f['feedback']),
                  style: const TextStyle(
                    color: FbColors.ink,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: FbColors.badgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FbColors.accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: FbColors.accent,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
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
          colors: [FbColors.gradA, FbColors.gradB, FbColors.gradC],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: FbColors.cardShadow,
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
                      'View Feedback',
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
                child: const Icon(Icons.feedback_rounded,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pull down to refresh',
                style: TextStyle(color: FbColors.leftText, fontSize: 13.5),
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

      final urls = Uri.parse('$url/mobileviewfeedback/');

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
              'date': i['date'].toString(),
              'feedback': i['feedback'].toString(),
              'worktitle': i['worktitle'].toString(),
              'teamleader': i['teamleader'].toString(),
            });
          }

          if (!mounted) return;

          setState(() {
            feedbacks = temp;
            loading = false;
          });
          return;
        } else {
          Fluttertoast.showToast(msg: 'Feedback loading failed');
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