import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Same purple palette as the login / home / profile / edit profile pages
/// (own class name so it never clashes with the other color classes)
class WorkColors {
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
  static const amber = Color(0xFFD98A12);

  static const border = Color(0xFFE6DCF3);
  static const borderHover = Color(0xFFC9B6E8);
  static const fill = Color(0xFFFBF9FD);
  static const icon = Color(0xFF8A7AA3);
  static const hint = Color(0xFFA8A0B8);

  static const focusRing = Color.fromRGBO(112, 64, 201, 0.10);
  static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
  static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
  static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
}

class viewwork extends StatefulWidget {
  const viewwork({super.key});

  @override
  State<viewwork> createState() => _viewworkState();
}

class _viewworkState extends State<viewwork> {
  List<Map<String, dynamic>> works = [];

  String selectedStatus = 'All';

  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  bool loading = true;
  bool _failed = false;

  static const List<String> _statuses = [
    'All',
    'Pending',
    'Working',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
    getdata();
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ---------------- HELPERS ----------------

  String _clean(dynamic v) {
    final s = (v ?? '').toString().trim();
    return (s.isEmpty || s == 'null') ? '-' : s;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return WorkColors.amber;
      case 'working':
        return WorkColors.accent;
      case 'completed':
        return WorkColors.green;
      default:
        return WorkColors.subtitle;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'working':
        return Icons.autorenew_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// search + status filter, pending work first
  List<Map<String, dynamic>> _filteredWorks() {
    final search = searchController.text.trim().toLowerCase();
    final List<Map<String, dynamic>> result = [];

    for (var i in works) {
      final worktitle = i['worktitle'].toString().toLowerCase();
      final description = i['work_description'].toString().toLowerCase();
      final status = i['status'].toString().toLowerCase();

      final searchMatch =
          worktitle.contains(search) || description.contains(search);
      final statusMatch =
          selectedStatus == 'All' || status == selectedStatus.toLowerCase();

      if (searchMatch && statusMatch) result.add(i);
    }

    // PENDING WORK FIRST
    result.sort((a, b) {
      final aPending = a['status'].toString().toLowerCase() == 'pending';
      final bPending = b['status'].toString().toLowerCase() == 'pending';
      if (aPending && !bPending) return -1;
      if (!aPending && bPending) return 1;
      return 0;
    });

    return result;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkColors.bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          color: WorkColors.accent,
          onRefresh: getdata,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                _buildHeader(context),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
                      child: _buildContent(),
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

  Widget _buildContent() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            color: WorkColors.accent,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_failed) {
      return _messageCard(
        icon: Icons.cloud_off_rounded,
        iconColor: WorkColors.coral,
        title: 'Could not load your work',
        message: 'Please check your connection and try again.',
        action: TextButton.icon(
          onPressed: getdata,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
          style: TextButton.styleFrom(foregroundColor: WorkColors.accent),
        ),
      );
    }

    final filtered = _filteredWorks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearch(),
        const SizedBox(height: 14),
        _buildStatusChips(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2),
          child: Text(
            '${filtered.length} ${filtered.length == 1 ? 'task' : 'Tasks'}',
            style: const TextStyle(
              color: WorkColors.title,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
        ),
        if (filtered.isEmpty)
          _messageCard(
            icon: works.isEmpty
                ? Icons.assignment_outlined
                : Icons.search_off_rounded,
            iconColor: WorkColors.accent,
            title: works.isEmpty ? 'No assigned work' : 'No matching work',
            message: works.isEmpty
                ? 'Work assigned to you will appear here.'
                : 'Try a different search or status filter.',
          )
        else
          for (int i = 0; i < filtered.length; i++) ...[
            _workCard(filtered[i]),
            if (i != filtered.length - 1) const SizedBox(height: 16),
          ],
      ],
    );
  }

  Widget _buildSearch() {
    final focused = _searchFocus.hasFocus;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        boxShadow: focused
            ? const [
          BoxShadow(
            color: WorkColors.focusRing,
            spreadRadius: 4,
            blurRadius: 0,
          ),
        ]
            : const [],
      ),
      child: TextField(
        controller: searchController,
        focusNode: _searchFocus,
        cursorColor: WorkColors.accent,
        style: const TextStyle(color: WorkColors.ink, fontSize: 14.5),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search work...',
          hintStyle: const TextStyle(color: WorkColors.hint, fontSize: 14.5),
          filled: true,
          fillColor: focused ? Colors.white : WorkColors.fill,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 21,
            color: focused ? WorkColors.accent : WorkColors.icon,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.close_rounded,
                size: 19, color: WorkColors.icon),
            onPressed: () {
              searchController.clear();
              setState(() {});
            },
          )
              : null,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          enabledBorder: border(WorkColors.border),
          focusedBorder: border(WorkColors.accent),
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final s in _statuses) ...[
            _statusChip(s),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String label) {
    final selected = selectedStatus == label;

    return GestureDetector(
      onTap: () => setState(() => selectedStatus = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
            colors: [WorkColors.gradA, WorkColors.btnB],
          )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : WorkColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : WorkColors.subtitle,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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
        border: Border.all(color: WorkColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: WorkColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: WorkColors.subtitle, fontSize: 13.5),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }

  Widget _workCard(Map<String, dynamic> w) {
    final status = _clean(w['status']);
    final statusColor = _statusColor(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WorkColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: WorkColors.softShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          // tap the card to see the feedback given for this work
          onTap: () => showFeedback(w),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _clean(w['worktitle']),
                        style: const TextStyle(
                          color: WorkColors.title,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status), size: 14, color: statusColor),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _clean(w['work_description']),
                  style: const TextStyle(
                    color: WorkColors.subtitle,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(Icons.person_outline_rounded, _clean(w['teamleader'])),
                    _chip(Icons.calendar_today_rounded, _clean(w['date'])),
                  ],
                ),
                const SizedBox(height: 18),
                // completed work can't be updated any more
                if (status.toLowerCase() != 'completed') ...[
                  _ActionButton(
                    label: 'Update Status',
                    icon: Icons.edit_note_rounded,
                    filled: true,
                    onTap: () => _updateStatus(w),
                  ),
                  const SizedBox(height: 10),
                ],
                _ActionButton(
                  label: 'View Feedback',
                  icon: Icons.feedback_outlined,
                  filled: false,
                  onTap: () => showFeedback(w),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: WorkColors.badgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: WorkColors.accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: WorkColors.accent,
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
          colors: [WorkColors.gradA, WorkColors.gradB, WorkColors.gradC],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: WorkColors.cardShadow,
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
                      'Assigned Work',
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
                child: const Icon(Icons.assignment_rounded,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pull down to refresh',
                style: TextStyle(color: WorkColors.leftText, fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ACTIONS ----------------

  // UPDATE STATUS

  String? _updatingId; // id of the work being updated (blocks double taps)

  Future<void> _updateStatus(Map<String, dynamic> work) async {
    if (_updatingId != null) return;

    final current = work['status'].toString();
    final options = ['Pending', 'Working', 'Completed']
        .where((s) => s.toLowerCase() != current.toLowerCase())
        .toList();

    // 1. choose the new status
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: WorkColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Update status',
                style: TextStyle(
                  color: WorkColors.title,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _clean(work['worktitle']),
                style: const TextStyle(
                  color: WorkColors.subtitle,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 14),
              for (final s in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => Navigator.pop(context, s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                          color: WorkColors.border, width: 1.5),
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _statusColor(s).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child:
                      Icon(_statusIcon(s), size: 20, color: _statusColor(s)),
                    ),
                    title: Text(
                      s,
                      style: const TextStyle(
                        color: WorkColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: WorkColors.borderHover),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (chosen == null || !mounted) return;

    // 2. completed can't be changed afterwards, so confirm first
    if (chosen == 'Completed') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Mark as completed?',
            style: TextStyle(
              color: WorkColors.title,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'You will not be able to change the status after this.',
            style: TextStyle(color: WorkColors.subtitle),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style:
              TextButton.styleFrom(foregroundColor: WorkColors.subtitle),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: WorkColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    // 3. send it to the server
    await _sendStatus(work['id'].toString(), chosen);
  }

  Future<void> _sendStatus(String id, String status) async {
    setState(() => _updatingId = id);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';

      final urls = Uri.parse('$url/mobileupdatestatus/');

      final response = await http.post(urls, body: {
        'id': id,
        'status': status,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsondata = jsonDecode(response.body);

        if (jsondata['status'].toString() == 'ok') {
          Fluttertoast.showToast(msg: 'Status updated to $status');
          _updatingId = null;
          if (mounted) await getdata(); // reload the list
          return;
        } else {
          Fluttertoast.showToast(msg: 'Status update failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not connect to the server');
    }

    if (mounted) setState(() => _updatingId = null);
  }

  // VIEW FEEDBACK POPUP
  void showFeedback(Map<String, dynamic> w) {
    final feedback = w['feedback'].toString();
    final empty = feedback.trim().isEmpty ||
        feedback == 'null' ||
        feedback == 'No feedback';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WorkColors.badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.feedback_rounded,
                          size: 20, color: WorkColors.accent),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Feedback',
                      style: TextStyle(
                        color: WorkColors.title,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _clean(w['worktitle']),
                  style: const TextStyle(
                    color: WorkColors.ink,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(Icons.person_outline_rounded,
                        _clean(w['teamleader'])),
                    _chip(Icons.calendar_today_rounded, _clean(w['date'])),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WorkColors.fill,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: WorkColors.border, width: 1.5),
                  ),
                  child: Text(
                    empty ? 'No feedback available' : feedback,
                    style: TextStyle(
                      color: empty ? WorkColors.hint : WorkColors.ink,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: WorkColors.accent,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // GET WORK DATA
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

      final urls = Uri.parse('$url/mobileviewwork/');

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
              'status': i['status'].toString(),
              'worktitle': i['worktitle'].toString(),
              'work_description': i['work_description'].toString(),
              'teamleader': i['teamleader'].toString(),
              'feedback': i['feedback'].toString(),
            });
          }

          if (!mounted) return;

          setState(() {
            works = temp;
            loading = false;
          });
          return;
        } else {
          Fluttertoast.showToast(msg: 'No work found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
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

/// Full-width button. filled = purple gradient, otherwise outlined.
/// HOVER: lifts slightly.
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.filled ? Colors.white : WorkColors.accent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: widget.filled
              ? const LinearGradient(
            begin: Alignment(-1, -0.09),
            end: Alignment(1, 0.09),
            colors: [WorkColors.gradA, WorkColors.btnB],
          )
              : null,
          color: widget.filled ? null : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: widget.filled
              ? null
              : Border.all(
            color: _hovered
                ? WorkColors.borderHover
                : WorkColors.border,
            width: 1.5,
          ),
          boxShadow: widget.filled
              ? [
            BoxShadow(
              color: WorkColors.btnShadow,
              blurRadius: _hovered ? 26 : 22,
              offset: Offset(0, _hovered ? 14 : 10),
              spreadRadius: -10,
            ),
          ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: widget.onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: fg, size: 19),
                const SizedBox(width: 9),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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