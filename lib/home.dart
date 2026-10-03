// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:untitled/viewwork.dart';
// // import 'package:untitled/changepassword.dart';
// // import 'package:untitled/login.dart';
// // import 'package:untitled/viewfeedback.dart';
// // import 'package:untitled/viewprofile.dart';
// // import 'package:untitled/viewteamleader.dart';
// //
// // /// Same purple palette as the login page.
// // /// (Named HomeColors so it never clashes with AppColors in login.dart)
// // class HomeColors {
// //   static const bg = Color(0xFFFAF7FC);
// //
// //   static const gradA = Color(0xFF7C4AD8);
// //   static const gradB = Color(0xFF6538BD);
// //   static const gradC = Color(0xFF4B2992);
// //
// //   static const btnB = Color(0xFF4D2997);
// //
// //   static const title = Color(0xFF4D2B91);
// //   static const ink = Color(0xFF352746);
// //   static const subtitle = Color(0xFF76698D);
// //   static const leftText = Color(0xFFEAE1FB);
// //
// //   static const accent = Color(0xFF7040C9);
// //   static const badgeBg = Color(0xFFF1E9FF);
// //   static const coral = Color(0xFFE0457B);
// //
// //   static const border = Color(0xFFE6DCF3);
// //   static const borderHover = Color(0xFFC9B6E8);
// //
// //   static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
// //   static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
// //   static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
// // }
// //
// // class _MenuItem {
// //   final IconData icon;
// //   final String title;
// //   final String subtitle;
// //   final WidgetBuilder page;
// //
// //   const _MenuItem(this.icon, this.title, this.subtitle, this.page);
// // }
// //
// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});
// //
// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }
// //
// // class _HomePageState extends State<HomePage> {
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //
// //   // ---------------- PROFILE DATA ----------------
// //
// //   String _name = '';
// //   String? _photoUrl;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadProfile();
// //   }
// //
// //   Future<void> _loadProfile() async {
// //     try {
// //       final sh = await SharedPreferences.getInstance();
// //
// //       final baseUrl = sh.getString('url') ?? '';
// //       // works even if lid was saved as an int
// //       final lid = sh.get('lid')?.toString() ?? '';
// //
// //       debugPrint('PROFILE baseUrl=$baseUrl lid=$lid');
// //
// //       // show the last known name right away while the request runs
// //       final cached = sh.getString('name') ?? '';
// //       if (cached.isNotEmpty && mounted) {
// //         setState(() => _name = cached);
// //       }
// //
// //       // same URL as viewprofile.dart (note the trailing slash)
// //       final res = await http.post(
// //         Uri.parse('$baseUrl/teammemberviewprofile_post/'),
// //         body: {'lid': lid},
// //       ).timeout(const Duration(seconds: 15));
// //
// //       debugPrint('PROFILE status=${res.statusCode} body=${res.body}');
// //
// //       final data = jsonDecode(res.body);
// //
// //       if (data['status'] == 'ok') {
// //         await sh.setString('name', (data['name'] ?? '').toString());
// //         if (!mounted) return;
// //         setState(() {
// //           _name = (data['name'] ?? '').toString();
// //           final p = (data['photo'] ?? '').toString();
// //           _photoUrl = p.isEmpty ? null : p;
// //         });
// //       }
// //     } catch (e) {
// //       // keep the fallback icon and generic text if loading fails
// //       debugPrint('PROFILE ERROR: $e');
// //     }
// //   }
// //
// //   // ---------------- MENU ITEMS ----------------
// //
// //   late final _MenuItem _work = _MenuItem(
// //     Icons.work_rounded,
// //     'My Work',
// //     'See the tasks assigned to you and update their status',
// //         (context) => viewwork(),
// //   );
// //
// //   late final List<_MenuItem> _items = [
// //     _MenuItem(
// //       Icons.person_rounded,
// //       'Profile',
// //       'View your details',
// //           (context) => viewprofile(),
// //     ),
// //     _MenuItem(
// //       Icons.lock_rounded,
// //       'Change Password',
// //       'Keep your account safe',
// //           (context) => changepassword(),
// //     ),
// //     _MenuItem(
// //       Icons.groups_rounded,
// //       'My Leaders',
// //       'Your team leaders',
// //           (context) => viewteamleader(),
// //     ),
// //     _MenuItem(
// //       Icons.feedback_rounded,
// //       'Feedback',
// //       'See feedback for you',
// //           (context) => viewfeedback(),
// //     ),
// //   ];
// //
// //   String get _greeting {
// //     final h = DateTime.now().hour;
// //     if (h < 12) return 'Good morning';
// //     if (h < 17) return 'Good afternoon';
// //     return 'Good evening';
// //   }
// //
// //   // ---------------- ACTIONS ----------------
// //
// //   Future<void> _open(_MenuItem item) async {
// //     await Navigator.push(context, MaterialPageRoute(builder: item.page));
// //     // reload in case the profile (name / photo) was edited
// //     if (mounted) _loadProfile();
// //   }
// //
// //   Future<void> logout() async {
// //     SharedPreferences sh = await SharedPreferences.getInstance();
// //
// //     await sh.remove('lid');
// //     await sh.remove('name');
// //
// //     if (!mounted) return;
// //
// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => loginpage(),
// //       ),
// //           (route) => false,
// //     );
// //   }
// //
// //   Future<void> _confirmLogout() async {
// //     final ok = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         backgroundColor: Colors.white,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(22),
// //         ),
// //         title: const Text(
// //           'Log out?',
// //           style: TextStyle(
// //             color: HomeColors.title,
// //             fontWeight: FontWeight.w700,
// //           ),
// //         ),
// //         content: const Text(
// //           'You will need to sign in again to continue.',
// //           style: TextStyle(color: HomeColors.subtitle),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             style: TextButton.styleFrom(
// //               foregroundColor: HomeColors.subtitle,
// //             ),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: HomeColors.coral,
// //               foregroundColor: Colors.white,
// //               elevation: 0,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //             child: const Text('Log out'),
// //           ),
// //         ],
// //       ),
// //     );
// //
// //     if (ok == true) {
// //       await logout();
// //     }
// //   }
// //
// //   // ---------------- UI ----------------
// //
// //   /// Profile photo if available, otherwise a fallback icon.
// //   Widget _photoOrIcon(IconData fallback, double iconSize) {
// //     final icon = Icon(fallback, color: Colors.white, size: iconSize);
// //
// //     if (_photoUrl == null) return icon;
// //
// //     return Image.network(
// //       _photoUrl!,
// //       fit: BoxFit.cover,
// //       width: double.infinity,
// //       height: double.infinity,
// //       errorBuilder: (_, __, ___) => icon,
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final width = MediaQuery.of(context).size.width;
// //     final columns = width >= 900 ? 4 : 2;
// //
// //     return Scaffold(
// //       key: _scaffoldKey,
// //       backgroundColor: HomeColors.bg,
// //       drawer: _buildDrawer(),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             _buildHeader(context),
// //             Center(
// //               child: ConstrainedBox(
// //                 constraints: const BoxConstraints(maxWidth: 900),
// //                 child: Padding(
// //                   padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Text(
// //                         'Quick access',
// //                         style: TextStyle(
// //                           color: HomeColors.title,
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.w700,
// //                           fontFamily: 'serif',
// //                         ),
// //                       ),
// //                       const SizedBox(height: 14),
// //
// //                       // featured card
// //                       _FeaturedCard(
// //                         item: _work,
// //                         onTap: () => _open(_work),
// //                       ),
// //                       const SizedBox(height: 16),
// //
// //                       GridView.count(
// //                         crossAxisCount: columns,
// //                         shrinkWrap: true,
// //                         physics: const NeverScrollableScrollPhysics(),
// //                         mainAxisSpacing: 16,
// //                         crossAxisSpacing: 16,
// //                         childAspectRatio: 1.05,
// //                         children: _items
// //                             .map((item) => _MenuCard(
// //                           item: item,
// //                           onTap: () => _open(item),
// //                         ))
// //                             .toList(),
// //                       ),
// //
// //                       const SizedBox(height: 24),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: const [
// //                           Icon(Icons.shield_outlined,
// //                               size: 13, color: Color(0xFF9A8FB0)),
// //                           SizedBox(width: 7),
// //                           Flexible(
// //                             child: Text(
// //                               'Your data is encrypted and private',
// //                               style: TextStyle(
// //                                 color: Color(0xFF9A8FB0),
// //                                 fontSize: 12.5,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHeader(BuildContext context) {
// //     final topPad = MediaQuery.of(context).padding.top;
// //
// //     return Container(
// //       width: double.infinity,
// //       clipBehavior: Clip.antiAlias,
// //       padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 34),
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment(-0.5, -1),
// //           end: Alignment(0.5, 1),
// //           colors: [HomeColors.gradA, HomeColors.gradB, HomeColors.gradC],
// //           stops: [0.0, 0.5, 1.0],
// //         ),
// //         borderRadius: BorderRadius.only(
// //           bottomLeft: Radius.circular(36),
// //           bottomRight: Radius.circular(36),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: HomeColors.cardShadow,
// //             blurRadius: 40,
// //             offset: Offset(0, 20),
// //             spreadRadius: -10,
// //           ),
// //         ],
// //       ),
// //       child: Stack(
// //         clipBehavior: Clip.hardEdge,
// //         children: [
// //           Positioned(
// //             top: -90,
// //             right: -80,
// //             child: Container(
// //               width: 240,
// //               height: 240,
// //               decoration: const BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: Color.fromRGBO(255, 255, 255, 0.06),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             bottom: -80,
// //             left: -70,
// //             child: Container(
// //               width: 190,
// //               height: 190,
// //               decoration: const BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: Color.fromRGBO(255, 255, 255, 0.04),
// //               ),
// //             ),
// //           ),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Row(
// //                 children: [
// //                   _HeaderButton(
// //                     icon: Icons.menu_rounded,
// //                     tooltip: 'Menu',
// //                     onTap: () => _scaffoldKey.currentState?.openDrawer(),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Expanded(
// //                     child: Text(
// //                       'Calmora',
// //                       overflow: TextOverflow.ellipsis,
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 17,
// //                         fontWeight: FontWeight.w700,
// //                         letterSpacing: 0.2,
// //                       ),
// //                     ),
// //                   ),
// //                   _HeaderButton(
// //                     icon: Icons.logout_rounded,
// //                     tooltip: 'Log out',
// //                     onTap: _confirmLogout,
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 30),
// //               Row(
// //                 children: [
// //                   // avatar: profile photo, falls back to icon
// //                   Container(
// //                     width: 58,
// //                     height: 58,
// //                     clipBehavior: Clip.antiAlias,
// //                     alignment: Alignment.center,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: const Color.fromRGBO(255, 255, 255, 0.16),
// //                       border: Border.all(
// //                         color: const Color.fromRGBO(255, 255, 255, 0.28),
// //                         width: 1.5,
// //                       ),
// //                     ),
// //                     child: _photoOrIcon(Icons.person_rounded, 30),
// //                   ),
// //                   const SizedBox(width: 14),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           _greeting,
// //                           style: const TextStyle(
// //                             color: HomeColors.leftText,
// //                             fontSize: 14,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 2),
// //                         // logged-in user's name
// //                         Text(
// //                           _name,
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 28,
// //                             fontWeight: FontWeight.w600,
// //                             fontFamily: 'serif',
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 14),
// //               const Text(
// //                 'Manage your work, feedback and profile in one place.',
// //                 style: TextStyle(
// //                   color: HomeColors.leftText,
// //                   fontSize: 14.5,
// //                   height: 1.6,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ---------------- DRAWER ----------------
// //
// //   Widget _buildDrawer() {
// //     void go(_MenuItem item) {
// //       Navigator.pop(context);
// //       _open(item);
// //     }
// //
// //     return Drawer(
// //       backgroundColor: Colors.white,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.only(
// //           topRight: Radius.circular(28),
// //           bottomRight: Radius.circular(28),
// //         ),
// //       ),
// //       child: Column(
// //         children: [
// //           // drawer header
// //           Container(
// //             width: double.infinity,
// //             padding: EdgeInsets.fromLTRB(
// //               22,
// //               MediaQuery.of(context).padding.top + 28,
// //               22,
// //               26,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment(-0.5, -1),
// //                 end: Alignment(0.5, 1),
// //                 colors: [
// //                   HomeColors.gradA,
// //                   HomeColors.gradB,
// //                   HomeColors.gradC,
// //                 ],
// //                 stops: [0.0, 0.5, 1.0],
// //               ),
// //               borderRadius: BorderRadius.only(
// //                 topRight: Radius.circular(28),
// //                 bottomRight: Radius.circular(28),
// //               ),
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Container(
// //                   width: 54,
// //                   height: 54,
// //                   clipBehavior: Clip.antiAlias,
// //                   alignment: Alignment.center,
// //                   decoration: BoxDecoration(
// //                     color: const Color.fromRGBO(255, 255, 255, 0.16),
// //                     borderRadius: BorderRadius.circular(16),
// //                     border: Border.all(
// //                       color: const Color.fromRGBO(255, 255, 255, 0.24),
// //                     ),
// //                   ),
// //                   child: _photoOrIcon(Icons.monitor_heart_outlined, 28),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   _name.isEmpty ? 'Workplace Wellbeing' : _name,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 const Text(
// //                   'Team member',
// //                   style: TextStyle(
// //                     color: HomeColors.leftText,
// //                     fontSize: 13.5,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           Expanded(
// //             child: ListView(
// //               padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
// //               children: [
// //                 _DrawerTile(
// //                   icon: Icons.person_rounded,
// //                   label: 'Profile',
// //                   onTap: () => go(_items[0]),
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.lock_rounded,
// //                   label: 'Change Password',
// //                   onTap: () => go(_items[1]),
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.groups_rounded,
// //                   label: 'View My Leaders',
// //                   onTap: () => go(_items[2]),
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.feedback_rounded,
// //                   label: 'View Feedback',
// //                   onTap: () => go(_items[3]),
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.work_rounded,
// //                   label: 'View Work',
// //                   onTap: () => go(_work),
// //                 ),
// //                 const Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
// //                   child: Divider(color: HomeColors.border, height: 1),
// //                 ),
// //                 _DrawerTile(
// //                   icon: Icons.logout_rounded,
// //                   label: 'Logout',
// //                   danger: true,
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     _confirmLogout();
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // =====================================================
// // //  WIDGETS
// // // =====================================================
// //
// // /// Round translucent icon button used in the header
// // class _HeaderButton extends StatefulWidget {
// //   final IconData icon;
// //   final String tooltip;
// //   final VoidCallback onTap;
// //
// //   const _HeaderButton({
// //     required this.icon,
// //     required this.tooltip,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   State<_HeaderButton> createState() => _HeaderButtonState();
// // }
// //
// // class _HeaderButtonState extends State<_HeaderButton> {
// //   bool _hovered = false;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Tooltip(
// //       message: widget.tooltip,
// //       child: MouseRegion(
// //         cursor: SystemMouseCursors.click,
// //         onEnter: (_) => setState(() => _hovered = true),
// //         onExit: (_) => setState(() => _hovered = false),
// //         child: GestureDetector(
// //           onTap: widget.onTap,
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 200),
// //             width: 42,
// //             height: 42,
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(13),
// //               color: Color.fromRGBO(255, 255, 255, _hovered ? 0.28 : 0.16),
// //               border: Border.all(
// //                 color: Color.fromRGBO(255, 255, 255, _hovered ? 0.4 : 0.22),
// //               ),
// //             ),
// //             child: Icon(widget.icon, color: Colors.white, size: 22),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // /// Big gradient card for the main action (View Work)
// // class _FeaturedCard extends StatefulWidget {
// //   final _MenuItem item;
// //   final VoidCallback onTap;
// //
// //   const _FeaturedCard({required this.item, required this.onTap});
// //
// //   @override
// //   State<_FeaturedCard> createState() => _FeaturedCardState();
// // }
// //
// // class _FeaturedCardState extends State<_FeaturedCard> {
// //   bool _hovered = false;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MouseRegion(
// //       cursor: SystemMouseCursors.click,
// //       onEnter: (_) => setState(() => _hovered = true),
// //       onExit: (_) => setState(() => _hovered = false),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         curve: Curves.easeOut,
// //         transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             begin: Alignment(-1, -0.09),
// //             end: Alignment(1, 0.09),
// //             colors: [HomeColors.gradA, HomeColors.btnB],
// //           ),
// //           borderRadius: BorderRadius.circular(22),
// //           boxShadow: [
// //             BoxShadow(
// //               color: HomeColors.btnShadow,
// //               blurRadius: _hovered ? 32 : 26,
// //               offset: Offset(0, _hovered ? 18 : 14),
// //               spreadRadius: -10,
// //             ),
// //           ],
// //         ),
// //         child: Material(
// //           color: Colors.transparent,
// //           child: InkWell(
// //             borderRadius: BorderRadius.circular(22),
// //             onTap: widget.onTap,
// //             child: Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 58,
// //                     height: 58,
// //                     decoration: BoxDecoration(
// //                       color: const Color.fromRGBO(255, 255, 255, 0.18),
// //                       borderRadius: BorderRadius.circular(17),
// //                       border: Border.all(
// //                         color: const Color.fromRGBO(255, 255, 255, 0.25),
// //                       ),
// //                     ),
// //                     child: Icon(widget.item.icon,
// //                         color: Colors.white, size: 30),
// //                   ),
// //                   const SizedBox(width: 16),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           widget.item.title,
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 19,
// //                             fontWeight: FontWeight.w700,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           widget.item.subtitle,
// //                           style: const TextStyle(
// //                             color: HomeColors.leftText,
// //                             fontSize: 13,
// //                             height: 1.45,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   AnimatedSlide(
// //                     duration: const Duration(milliseconds: 200),
// //                     offset: Offset(_hovered ? 0.2 : 0, 0),
// //                     child: const Icon(
// //                       Icons.arrow_forward_rounded,
// //                       color: Colors.white,
// //                       size: 22,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // /// Grid card. HOVER: lifts, border darkens, icon tile fills with purple.
// // class _MenuCard extends StatefulWidget {
// //   final _MenuItem item;
// //   final VoidCallback onTap;
// //
// //   const _MenuCard({required this.item, required this.onTap});
// //
// //   @override
// //   State<_MenuCard> createState() => _MenuCardState();
// // }
// //
// // class _MenuCardState extends State<_MenuCard> {
// //   bool _hovered = false;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MouseRegion(
// //       cursor: SystemMouseCursors.click,
// //       onEnter: (_) => setState(() => _hovered = true),
// //       onExit: (_) => setState(() => _hovered = false),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         curve: Curves.easeOut,
// //         transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(20),
// //           border: Border.all(
// //             color: _hovered ? HomeColors.borderHover : HomeColors.border,
// //             width: 1.5,
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: HomeColors.softShadow,
// //               blurRadius: _hovered ? 30 : 18,
// //               offset: Offset(0, _hovered ? 16 : 8),
// //               spreadRadius: -8,
// //             ),
// //           ],
// //         ),
// //         child: Material(
// //           color: Colors.transparent,
// //           child: InkWell(
// //             borderRadius: BorderRadius.circular(20),
// //             onTap: widget.onTap,
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   AnimatedContainer(
// //                     duration: const Duration(milliseconds: 200),
// //                     width: 48,
// //                     height: 48,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(14),
// //                       color: _hovered ? null : HomeColors.badgeBg,
// //                       gradient: _hovered
// //                           ? const LinearGradient(
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                         colors: [HomeColors.gradA, HomeColors.gradC],
// //                       )
// //                           : null,
// //                     ),
// //                     child: Icon(
// //                       widget.item.icon,
// //                       size: 24,
// //                       color: _hovered ? Colors.white : HomeColors.accent,
// //                     ),
// //                   ),
// //                   const Spacer(),
// //                   Text(
// //                     widget.item.title,
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                     style: const TextStyle(
// //                       color: HomeColors.ink,
// //                       fontSize: 15.5,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 3),
// //                   Text(
// //                     widget.item.subtitle,
// //                     maxLines: 2,
// //                     overflow: TextOverflow.ellipsis,
// //                     style: const TextStyle(
// //                       color: HomeColors.subtitle,
// //                       fontSize: 12.5,
// //                       height: 1.35,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // /// Drawer row with a tinted icon tile
// // class _DrawerTile extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final VoidCallback onTap;
// //   final bool danger;
// //
// //   const _DrawerTile({
// //     required this.icon,
// //     required this.label,
// //     required this.onTap,
// //     this.danger = false,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = danger ? HomeColors.coral : HomeColors.accent;
// //     final textColor = danger ? HomeColors.coral : HomeColors.ink;
// //
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 4),
// //       child: ListTile(
// //         onTap: onTap,
// //         hoverColor: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
// //         splashColor: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(14),
// //         ),
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 10),
// //         leading: Container(
// //           width: 40,
// //           height: 40,
// //           decoration: BoxDecoration(
// //             color: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Icon(icon, color: color, size: 21),
// //         ),
// //         title: Text(
// //           label,
// //           style: TextStyle(
// //             color: textColor,
// //             fontSize: 15,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         trailing: danger
// //             ? null
// //             : const Icon(
// //           Icons.chevron_right_rounded,
// //           color: HomeColors.borderHover,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
//
// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:flutter/material.dart';
// // import 'package:camera/camera.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:untitled/viewwork.dart';
// // import 'package:untitled/changepassword.dart';
// // import 'package:untitled/login.dart';
// // import 'package:untitled/viewfeedback.dart';
// // import 'package:untitled/viewprofile.dart';
// // import 'package:untitled/viewteamleader.dart';
// //
// // /// Same purple palette as the login page.
// // /// (Named HomeColors so it never clashes with AppColors in login.dart)
// // class HomeColors {
// // static const bg = Color(0xFFFAF7FC);
// //
// // static const gradA = Color(0xFF7C4AD8);
// // static const gradB = Color(0xFF6538BD);
// // static const gradC = Color(0xFF4B2992);
// //
// // static const btnB = Color(0xFF4D2997);
// //
// // static const title = Color(0xFF4D2B91);
// // static const ink = Color(0xFF352746);
// // static const subtitle = Color(0xFF76698D);
// // static const leftText = Color(0xFFEAE1FB);
// //
// // static const accent = Color(0xFF7040C9);
// // static const badgeBg = Color(0xFFF1E9FF);
// // static const coral = Color(0xFFE0457B);
// //
// // static const border = Color(0xFFE6DCF3);
// // static const borderHover = Color(0xFFC9B6E8);
// //
// // static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
// // static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
// // static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
// // }
// //
// // class _MenuItem {
// // final IconData icon;
// // final String title;
// // final String subtitle;
// // final WidgetBuilder page;
// //
// // const _MenuItem(this.icon, this.title, this.subtitle, this.page);
// // }
// //
// // class HomePage extends StatefulWidget {
// // const HomePage({super.key});
// //
// // @override
// // State<HomePage> createState() => _HomePageState();
// // }
// //
// // class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
// // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //
// // // ---------------- PROFILE DATA ----------------
// //
// // String _name = '';
// // String? _photoUrl;
// //
// // // ---------------- AUTOMATIC EMOTION MONITORING ----------------
// // //
// // // No emotion button is required.
// // //
// // // Every 10 seconds:
// // //  1. Capture a photo from the front camera.
// // //  2. Upload it to mobileemotion_predict_post/.
// // //  3. Django + FER predicts the emotion and score.
// // //  4. Send that returned emotion/score to mobileemotion_post/
// // //     so it is stored for the logged-in user.
// // //
// // // Backend flow:
// // //   POST /mobileemotion_predict_post/
// // //       image=<camera image>
// // //
// // //   response:
// // //       {status:"ok", emotion:"happy", score:0.91}
// // //
// // //   POST /mobileemotion_post/
// // //       lid=<user id>
// // //       emotion=<emotion>
// // //       score=<score>
// //
// // static const String _emotionPredictEndpoint =
// // '/mobileemotion_predict_post/';
// //
// // static const String _emotionSaveEndpoint =
// // '/mobileemotion_post/';
// //
// // CameraController? _cameraController;
// // Timer? _emotionTimer;
// //
// // bool _emotionMonitoring = false;
// // bool _emotionProcessing = false;
// //
// // String _lastEmotion = 'Detecting...';
// // double? _lastEmotionScore;
// // DateTime? _lastEmotionAt;
// //
// // @override
// // void initState() {
// // super.initState();
// // WidgetsBinding.instance.addObserver(this);
// // _loadProfile();
// // _startEmotionMonitoring();
// // }
// //
// // Future<void> _startEmotionMonitoring() async {
// // if (_emotionMonitoring || !mounted) return;
// //
// // try {
// // final cameras = await availableCameras();
// //
// // if (cameras.isEmpty || !mounted) {
// // debugPrint('EMOTION: no camera available');
// // return;
// // }
// //
// // final frontCamera = cameras.firstWhere(
// // (camera) => camera.lensDirection == CameraLensDirection.front,
// // orElse: () => cameras.first,
// // );
// //
// // final controller = CameraController(
// // frontCamera,
// // ResolutionPreset.medium,
// // enableAudio: false,
// // );
// //
// // await controller.initialize();
// //
// // if (!mounted) {
// // await controller.dispose();
// // return;
// // }
// //
// // _cameraController = controller;
// // _emotionMonitoring = true;
// //
// // // Perform the first detection shortly after entering HomePage.
// // await _captureAndSendEmotion();
// //
// // // Continue automatically every 10 seconds.
// // _emotionTimer?.cancel();
// // _emotionTimer = Timer.periodic(
// // const Duration(seconds: 10),
// // (_) => _captureAndSendEmotion(),
// // );
// //
// // debugPrint('EMOTION: automatic monitoring started');
// // } catch (e) {
// // debugPrint('EMOTION START ERROR: $e');
// // await _stopEmotionMonitoring();
// // }
// // }
// //
// // Future<void> _captureAndSendEmotion() async {
// // if (!_emotionMonitoring ||
// // _emotionProcessing ||
// // !mounted ||
// // _cameraController == null ||
// // !_cameraController!.value.isInitialized) {
// // return;
// // }
// //
// // _emotionProcessing = true;
// //
// // XFile? imageFile;
// //
// // try {
// // // Capture the current user's face automatically.
// // imageFile = await _cameraController!.takePicture();
// //
// // final sh = await SharedPreferences.getInstance();
// // final baseUrl = (sh.getString('url') ?? '').replaceFirst(
// // RegExp(r'\/$'),
// // '',
// // );
// // final lid = sh.get('lid')?.toString() ?? '';
// //
// // if (baseUrl.isEmpty || lid.isEmpty) {
// // debugPrint('EMOTION: missing baseUrl/lid');
// // return;
// // }
// //
// // // -----------------------------------------------------------
// // // STEP 1: Send image to Django FER prediction endpoint.
// // // -----------------------------------------------------------
// // final predictRequest = http.MultipartRequest(
// // 'POST',
// // Uri.parse('$baseUrl$_emotionPredictEndpoint'),
// // );
// //
// // predictRequest.files.add(
// // await http.MultipartFile.fromPath(
// // 'image',
// // imageFile.path,
// // ),
// // );
// //
// // final streamedResponse = await predictRequest.send().timeout(
// // const Duration(seconds: 30),
// // );
// //
// // final responseBody =
// // await streamedResponse.stream.bytesToString();
// //
// // debugPrint(
// // 'EMOTION PREDICT status=${streamedResponse.statusCode} '
// // 'body=$responseBody',
// // );
// //
// // if (streamedResponse.statusCode < 200 ||
// // streamedResponse.statusCode >= 300) {
// // debugPrint('EMOTION: prediction request failed');
// // return;
// // }
// //
// // final prediction = jsonDecode(responseBody);
// //
// // if (prediction['status'] != 'ok') {
// // final message =
// // prediction['message']?.toString() ?? 'No face detected';
// //
// // _setDetectedEmotion(
// // emotion: message,
// // score: null,
// // );
// //
// // return;
// // }
// //
// // final emotionName =
// // prediction['emotion']?.toString() ?? '';
// //
// // final dynamic scoreValue = prediction['score'];
// //
// // final double? score = scoreValue == null
// // ? null
// //     : double.tryParse(scoreValue.toString());
// //
// // if (emotionName.isEmpty || score == null) {
// // debugPrint('EMOTION: invalid prediction response');
// // return;
// // }
// //
// // _setDetectedEmotion(
// // emotion: emotionName,
// // score: score,
// // );
// //
// // // -----------------------------------------------------------
// // // STEP 2: Save Django FER result to the logged-in user.
// // // -----------------------------------------------------------
// // final saveResponse = await http.post(
// // Uri.parse('$baseUrl$_emotionSaveEndpoint'),
// // body: {
// // 'lid': lid,
// // 'emotion': emotionName,
// // 'score': score.toString(),
// // },
// // ).timeout(
// // const Duration(seconds: 15),
// // );
// //
// // debugPrint(
// // 'EMOTION SAVE status=${saveResponse.statusCode} '
// // 'body=${saveResponse.body}',
// // );
// //
// // if (saveResponse.statusCode < 200 ||
// // saveResponse.statusCode >= 300) {
// // debugPrint('EMOTION: save request failed');
// // }
// // } catch (e) {
// // // A temporary camera/network error must not stop future 10-second
// // // monitoring attempts.
// // debugPrint('EMOTION CAPTURE/SEND ERROR: $e');
// // } finally {
// // _emotionProcessing = false;
// //
// // // Remove the temporary camera image.
// // if (imageFile != null) {
// // try {
// // await File(imageFile.path).delete();
// // } catch (_) {}
// // }
// // }
// // }
// //
// // void _setDetectedEmotion({
// // required String emotion,
// // required double? score,
// // }) {
// // if (!mounted) return;
// //
// // setState(() {
// // _lastEmotion = emotion;
// // _lastEmotionScore = score;
// // _lastEmotionAt = DateTime.now();
// // });
// //
// // debugPrint(
// // 'EMOTION DETECTED: $emotion'
// // '${score == null ? '' : ' score=$score'}',
// // );
// // }
// //
// // Future<void> _stopEmotionMonitoring() async {
// // _emotionTimer?.cancel();
// // _emotionTimer = null;
// // _emotionMonitoring = false;
// // _emotionProcessing = false;
// //
// // final controller = _cameraController;
// // _cameraController = null;
// //
// // await controller?.dispose();
// //
// // debugPrint('EMOTION: automatic monitoring stopped');
// // }
// //
// // Future<void> _restartEmotionMonitoring() async {
// // await _stopEmotionMonitoring();
// //
// // if (mounted) {
// // await _startEmotionMonitoring();
// // }
// // }
// //
// // @override
// // void didChangeAppLifecycleState(AppLifecycleState state) {
// // if (state == AppLifecycleState.resumed) {
// // _restartEmotionMonitoring();
// // } else if (state == AppLifecycleState.inactive ||
// // state == AppLifecycleState.paused ||
// // state == AppLifecycleState.detached) {
// // _stopEmotionMonitoring();
// // }
// // }
// //
// // @override
// // void dispose() {
// // WidgetsBinding.instance.removeObserver(this);
// // _stopEmotionMonitoring();
// // super.dispose();
// // }
// //
// // Future<void> _loadProfile() async {
// // try {
// // final sh = await SharedPreferences.getInstance();
// //
// // final baseUrl = sh.getString('url') ?? '';
// // // works even if lid was saved as an int
// // final lid = sh.get('lid')?.toString() ?? '';
// //
// // debugPrint('PROFILE baseUrl=$baseUrl lid=$lid');
// //
// // // show the last known name right away while the request runs
// // final cached = sh.getString('name') ?? '';
// // if (cached.isNotEmpty && mounted) {
// // setState(() => _name = cached);
// // }
// //
// // // same URL as viewprofile.dart (note the trailing slash)
// // final res = await http.post(
// // Uri.parse('$baseUrl/teammemberviewprofile_post/'),
// // body: {'lid': lid},
// // ).timeout(const Duration(seconds: 15));
// //
// // debugPrint('PROFILE status=${res.statusCode} body=${res.body}');
// //
// // final data = jsonDecode(res.body);
// //
// // if (data['status'] == 'ok') {
// // await sh.setString('name', (data['name'] ?? '').toString());
// // if (!mounted) return;
// // setState(() {
// // _name = (data['name'] ?? '').toString();
// // final p = (data['photo'] ?? '').toString();
// // _photoUrl = p.isEmpty ? null : p;
// // });
// // }
// // } catch (e) {
// // // keep the fallback icon and generic text if loading fails
// // debugPrint('PROFILE ERROR: $e');
// // }
// // }
// //
// // // ---------------- MENU ITEMS ----------------
// //
// // late final _MenuItem _work = _MenuItem(
// // Icons.work_rounded,
// // 'My Work',
// // 'See the tasks assigned to you and update their status',
// // (context) => viewwork(),
// // );
// //
// // late final List<_MenuItem> _items = [
// // _MenuItem(
// // Icons.person_rounded,
// // 'Profile',
// // 'View your details',
// // (context) => viewprofile(),
// // ),
// // _MenuItem(
// // Icons.lock_rounded,
// // 'Change Password',
// // 'Keep your account safe',
// // (context) => changepassword(),
// // ),
// // _MenuItem(
// // Icons.groups_rounded,
// // 'My Leaders',
// // 'Your team leaders',
// // (context) => viewteamleader(),
// // ),
// // _MenuItem(
// // Icons.feedback_rounded,
// // 'Feedback',
// // 'See feedback for you',
// // (context) => viewfeedback(),
// // ),
// // ];
// //
// // String get _greeting {
// // final h = DateTime.now().hour;
// // if (h < 12) return 'Good morning';
// // if (h < 17) return 'Good afternoon';
// // return 'Good evening';
// // }
// //
// // // ---------------- ACTIONS ----------------
// //
// // Future<void> _open(_MenuItem item) async {
// // await Navigator.push(context, MaterialPageRoute(builder: item.page));
// // // reload in case the profile (name / photo) was edited
// // if (mounted) _loadProfile();
// // }
// //
// // Future<void> logout() async {
// // SharedPreferences sh = await SharedPreferences.getInstance();
// //
// // await sh.remove('lid');
// // await sh.remove('name');
// //
// // if (!mounted) return;
// //
// // Navigator.pushAndRemoveUntil(
// // context,
// // MaterialPageRoute(
// // builder: (context) => loginpage(),
// // ),
// // (route) => false,
// // );
// // }
// //
// // Future<void> _confirmLogout() async {
// // final ok = await showDialog<bool>(
// // context: context,
// // builder: (context) => AlertDialog(
// // backgroundColor: Colors.white,
// // shape: RoundedRectangleBorder(
// // borderRadius: BorderRadius.circular(22),
// // ),
// // title: const Text(
// // 'Log out?',
// // style: TextStyle(
// // color: HomeColors.title,
// // fontWeight: FontWeight.w700,
// // ),
// // ),
// // content: const Text(
// // 'You will need to sign in again to continue.',
// // style: TextStyle(color: HomeColors.subtitle),
// // ),
// // actions: [
// // TextButton(
// // onPressed: () => Navigator.pop(context, false),
// // style: TextButton.styleFrom(
// // foregroundColor: HomeColors.subtitle,
// // ),
// // child: const Text('Cancel'),
// // ),
// // ElevatedButton(
// // onPressed: () => Navigator.pop(context, true),
// // style: ElevatedButton.styleFrom(
// // backgroundColor: HomeColors.coral,
// // foregroundColor: Colors.white,
// // elevation: 0,
// // shape: RoundedRectangleBorder(
// // borderRadius: BorderRadius.circular(12),
// // ),
// // ),
// // child: const Text('Log out'),
// // ),
// // ],
// // ),
// // );
// //
// // if (ok == true) {
// // await logout();
// // }
// // }
// //
// // // ---------------- UI ----------------
// //
// // /// Profile photo if available, otherwise a fallback icon.
// // Widget _photoOrIcon(IconData fallback, double iconSize) {
// // final icon = Icon(fallback, color: Colors.white, size: iconSize);
// //
// // if (_photoUrl == null) return icon;
// //
// // return Image.network(
// // _photoUrl!,
// // fit: BoxFit.cover,
// // width: double.infinity,
// // height: double.infinity,
// // errorBuilder: (_, __, ___) => icon,
// // );
// // }
// //
// // @override
// // Widget build(BuildContext context) {
// // final width = MediaQuery.of(context).size.width;
// // final columns = width >= 900 ? 4 : 2;
// //
// // return Scaffold(
// // key: _scaffoldKey,
// // backgroundColor: HomeColors.bg,
// // drawer: _buildDrawer(),
// // body: SingleChildScrollView(
// // child: Column(
// // children: [
// // _buildHeader(context),
// // Center(
// // child: ConstrainedBox(
// // constraints: const BoxConstraints(maxWidth: 900),
// // child: Padding(
// // padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // const Text(
// // 'Quick access',
// // style: TextStyle(
// // color: HomeColors.title,
// // fontSize: 20,
// // fontWeight: FontWeight.w700,
// // fontFamily: 'serif',
// // ),
// // ),
// // const SizedBox(height: 14),
// //
// // // Automatic emotion-monitoring status.
// // _EmotionStatusCard(
// // emotion: _lastEmotion,
// // score: _lastEmotionScore,
// // isMonitoring: _emotionMonitoring,
// // lastDetectedAt: _lastEmotionAt,
// // ),
// // const SizedBox(height: 16),
// //
// // // featured card
// // _FeaturedCard(
// // item: _work,
// // onTap: () => _open(_work),
// // ),
// // const SizedBox(height: 16),
// //
// // GridView.count(
// // crossAxisCount: columns,
// // shrinkWrap: true,
// // physics: const NeverScrollableScrollPhysics(),
// // mainAxisSpacing: 16,
// // crossAxisSpacing: 16,
// // childAspectRatio: 1.05,
// // children: _items
// //     .map((item) => _MenuCard(
// // item: item,
// // onTap: () => _open(item),
// // ))
// //     .toList(),
// // ),
// //
// // const SizedBox(height: 24),
// // Row(
// // mainAxisAlignment: MainAxisAlignment.center,
// // children: const [
// // Icon(Icons.shield_outlined,
// // size: 13, color: Color(0xFF9A8FB0)),
// // SizedBox(width: 7),
// // Flexible(
// // child: Text(
// // 'Your data is encrypted and private',
// // style: TextStyle(
// // color: Color(0xFF9A8FB0),
// // fontSize: 12.5,
// // ),
// // ),
// // ),
// // ],
// // ),
// // ],
// // ),
// // ),
// // ),
// // ),
// // ],
// // ),
// // ),
// // );
// // }
// //
// // Widget _buildHeader(BuildContext context) {
// // final topPad = MediaQuery.of(context).padding.top;
// //
// // return Container(
// // width: double.infinity,
// // clipBehavior: Clip.antiAlias,
// // padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 34),
// // decoration: const BoxDecoration(
// // gradient: LinearGradient(
// // begin: Alignment(-0.5, -1),
// // end: Alignment(0.5, 1),
// // colors: [HomeColors.gradA, HomeColors.gradB, HomeColors.gradC],
// // stops: [0.0, 0.5, 1.0],
// // ),
// // borderRadius: BorderRadius.only(
// // bottomLeft: Radius.circular(36),
// // bottomRight: Radius.circular(36),
// // ),
// // boxShadow: [
// // BoxShadow(
// // color: HomeColors.cardShadow,
// // blurRadius: 40,
// // offset: Offset(0, 20),
// // spreadRadius: -10,
// // ),
// // ],
// // ),
// // child: Stack(
// // clipBehavior: Clip.hardEdge,
// // children: [
// // Positioned(
// // top: -90,
// // right: -80,
// // child: Container(
// // width: 240,
// // height: 240,
// // decoration: const BoxDecoration(
// // shape: BoxShape.circle,
// // color: Color.fromRGBO(255, 255, 255, 0.06),
// // ),
// // ),
// // ),
// // Positioned(
// // bottom: -80,
// // left: -70,
// // child: Container(
// // width: 190,
// // height: 190,
// // decoration: const BoxDecoration(
// // shape: BoxShape.circle,
// // color: Color.fromRGBO(255, 255, 255, 0.04),
// // ),
// // ),
// // ),
// // Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // Row(
// // children: [
// // _HeaderButton(
// // icon: Icons.menu_rounded,
// // tooltip: 'Menu',
// // onTap: () => _scaffoldKey.currentState?.openDrawer(),
// // ),
// // const SizedBox(width: 12),
// // const Expanded(
// // child: Text(
// // 'Calmora',
// // overflow: TextOverflow.ellipsis,
// // style: TextStyle(
// // color: Colors.white,
// // fontSize: 17,
// // fontWeight: FontWeight.w700,
// // letterSpacing: 0.2,
// // ),
// // ),
// // ),
// // _HeaderButton(
// // icon: Icons.logout_rounded,
// // tooltip: 'Log out',
// // onTap: _confirmLogout,
// // ),
// // ],
// // ),
// // const SizedBox(height: 30),
// // Row(
// // children: [
// // // avatar: profile photo, falls back to icon
// // Container(
// // width: 58,
// // height: 58,
// // clipBehavior: Clip.antiAlias,
// // alignment: Alignment.center,
// // decoration: BoxDecoration(
// // shape: BoxShape.circle,
// // color: const Color.fromRGBO(255, 255, 255, 0.16),
// // border: Border.all(
// // color: const Color.fromRGBO(255, 255, 255, 0.28),
// // width: 1.5,
// // ),
// // ),
// // child: _photoOrIcon(Icons.person_rounded, 30),
// // ),
// // const SizedBox(width: 14),
// // Expanded(
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // Text(
// // _greeting,
// // style: const TextStyle(
// // color: HomeColors.leftText,
// // fontSize: 14,
// // ),
// // ),
// // const SizedBox(height: 2),
// // // logged-in user's name
// // Text(
// // _name,
// // maxLines: 1,
// // overflow: TextOverflow.ellipsis,
// // style: const TextStyle(
// // color: Colors.white,
// // fontSize: 28,
// // fontWeight: FontWeight.w600,
// // fontFamily: 'serif',
// // ),
// // ),
// // ],
// // ),
// // ),
// // ],
// // ),
// // const SizedBox(height: 14),
// // const Text(
// // 'Manage your work, feedback and profile in one place.',
// // style: TextStyle(
// // color: HomeColors.leftText,
// // fontSize: 14.5,
// // height: 1.6,
// // ),
// // ),
// // ],
// // ),
// // ],
// // ),
// // );
// // }
// //
// // // ---------------- DRAWER ----------------
// //
// // Widget _buildDrawer() {
// // void go(_MenuItem item) {
// // Navigator.pop(context);
// // _open(item);
// // }
// //
// // return Drawer(
// // backgroundColor: Colors.white,
// // shape: const RoundedRectangleBorder(
// // borderRadius: BorderRadius.only(
// // topRight: Radius.circular(28),
// // bottomRight: Radius.circular(28),
// // ),
// // ),
// // child: Column(
// // children: [
// // // drawer header
// // Container(
// // width: double.infinity,
// // padding: EdgeInsets.fromLTRB(
// // 22,
// // MediaQuery.of(context).padding.top + 28,
// // 22,
// // 26,
// // ),
// // decoration: const BoxDecoration(
// // gradient: LinearGradient(
// // begin: Alignment(-0.5, -1),
// // end: Alignment(0.5, 1),
// // colors: [
// // HomeColors.gradA,
// // HomeColors.gradB,
// // HomeColors.gradC,
// // ],
// // stops: [0.0, 0.5, 1.0],
// // ),
// // borderRadius: BorderRadius.only(
// // topRight: Radius.circular(28),
// // bottomRight: Radius.circular(28),
// // ),
// // ),
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // Container(
// // width: 54,
// // height: 54,
// // clipBehavior: Clip.antiAlias,
// // alignment: Alignment.center,
// // decoration: BoxDecoration(
// // color: const Color.fromRGBO(255, 255, 255, 0.16),
// // borderRadius: BorderRadius.circular(16),
// // border: Border.all(
// // color: const Color.fromRGBO(255, 255, 255, 0.24),
// // ),
// // ),
// // child: _photoOrIcon(Icons.monitor_heart_outlined, 28),
// // ),
// // const SizedBox(height: 16),
// // Text(
// // _name.isEmpty ? 'Workplace Wellbeing' : _name,
// // maxLines: 1,
// // overflow: TextOverflow.ellipsis,
// // style: const TextStyle(
// // color: Colors.white,
// // fontSize: 20,
// // fontWeight: FontWeight.w700,
// // ),
// // ),
// // const SizedBox(height: 4),
// // const Text(
// // 'Team member',
// // style: TextStyle(
// // color: HomeColors.leftText,
// // fontSize: 13.5,
// // ),
// // ),
// // ],
// // ),
// // ),
// //
// // Expanded(
// // child: ListView(
// // padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
// // children: [
// // _DrawerTile(
// // icon: Icons.person_rounded,
// // label: 'Profile',
// // onTap: () => go(_items[0]),
// // ),
// // _DrawerTile(
// // icon: Icons.lock_rounded,
// // label: 'Change Password',
// // onTap: () => go(_items[1]),
// // ),
// // _DrawerTile(
// // icon: Icons.groups_rounded,
// // label: 'View My Leaders',
// // onTap: () => go(_items[2]),
// // ),
// // _DrawerTile(
// // icon: Icons.feedback_rounded,
// // label: 'View Feedback',
// // onTap: () => go(_items[3]),
// // ),
// // _DrawerTile(
// // icon: Icons.work_rounded,
// // label: 'View Work',
// // onTap: () => go(_work),
// // ),
// // const Padding(
// // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
// // child: Divider(color: HomeColors.border, height: 1),
// // ),
// // _DrawerTile(
// // icon: Icons.logout_rounded,
// // label: 'Logout',
// // danger: true,
// // onTap: () {
// // Navigator.pop(context);
// // _confirmLogout();
// // },
// // ),
// // ],
// // ),
// // ),
// // ],
// // ),
// // );
// // }
// // }
// //
// //
// // class _EmotionStatusCard extends StatelessWidget {
// // final String emotion;
// // final double? score;
// // final bool isMonitoring;
// // final DateTime? lastDetectedAt;
// //
// // const _EmotionStatusCard({
// // required this.emotion,
// // required this.score,
// // required this.isMonitoring,
// // required this.lastDetectedAt,
// // });
// //
// // @override
// // Widget build(BuildContext context) {
// // final time = lastDetectedAt == null
// // ? 'Waiting for first reading...'
// //     : 'Last checked ${_formatTime(lastDetectedAt!)}';
// //
// // return Container(
// // width: double.infinity,
// // padding: const EdgeInsets.all(16),
// // decoration: BoxDecoration(
// // color: Colors.white,
// // borderRadius: BorderRadius.circular(20),
// // border: Border.all(color: HomeColors.border, width: 1.5),
// // boxShadow: const [
// // BoxShadow(
// // color: HomeColors.softShadow,
// // blurRadius: 18,
// // offset: Offset(0, 8),
// // spreadRadius: -8,
// // ),
// // ],
// // ),
// // child: Row(
// // children: [
// // Container(
// // width: 48,
// // height: 48,
// // decoration: BoxDecoration(
// // color: HomeColors.badgeBg,
// // borderRadius: BorderRadius.circular(14),
// // ),
// // child: Icon(
// // isMonitoring
// // ? Icons.face_retouching_natural_rounded
// //     : Icons.face_retouching_off_rounded,
// // color: HomeColors.accent,
// // size: 25,
// // ),
// // ),
// // const SizedBox(width: 13),
// // Expanded(
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // Text(
// // isMonitoring
// // ? 'Emotion monitoring active'
// //     : 'Emotion monitoring unavailable',
// // style: const TextStyle(
// // color: HomeColors.ink,
// // fontSize: 14.5,
// // fontWeight: FontWeight.w700,
// // ),
// // ),
// // const SizedBox(height: 3),
// // Text(
// // _details(),
// // maxLines: 2,
// // overflow: TextOverflow.ellipsis,
// // style: const TextStyle(
// // color: HomeColors.subtitle,
// // fontSize: 12.5,
// // height: 1.35,
// // ),
// // ),
// // ],
// // ),
// // ),
// // if (isMonitoring)
// // const SizedBox(
// // width: 9,
// // height: 9,
// // child: DecoratedBox(
// // decoration: BoxDecoration(
// // color: Colors.green,
// // shape: BoxShape.circle,
// // ),
// // ),
// // ),
// // ],
// // ),
// // );
// // }
// //
// // String _details() {
// // final timeText = lastDetectedAt == null
// // ? 'Waiting for first reading...'
// //     : 'Last checked ${_formatTime(lastDetectedAt!)}';
// //
// // final scoreText = score == null
// // ? ''
// //     : '  •  ${(score! * 100).toStringAsFixed(1)}%';
// //
// // return 'Current: $emotion$scoreText  •  $timeText';
// // }
// //
// // static String _formatTime(DateTime value) {
// // final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
// // final minute = value.minute.toString().padLeft(2, '0');
// // final second = value.second.toString().padLeft(2, '0');
// // final suffix = value.hour >= 12 ? 'PM' : 'AM';
// // return '$hour:$minute:$second $suffix';
// // }
// // }
// //
// // // =====================================================
// // //  WIDGETS
// // // =====================================================
// //
// // /// Round translucent icon button used in the header
// // class _HeaderButton extends StatefulWidget {
// // final IconData icon;
// // final String tooltip;
// // final VoidCallback onTap;
// //
// // const _HeaderButton({
// // required this.icon,
// // required this.tooltip,
// // required this.onTap,
// // });
// //
// // @override
// // State<_HeaderButton> createState() => _HeaderButtonState();
// // }
// //
// // class _HeaderButtonState extends State<_HeaderButton> {
// // bool _hovered = false;
// //
// // @override
// // Widget build(BuildContext context) {
// // return Tooltip(
// // message: widget.tooltip,
// // child: MouseRegion(
// // cursor: SystemMouseCursors.click,
// // onEnter: (_) => setState(() => _hovered = true),
// // onExit: (_) => setState(() => _hovered = false),
// // child: GestureDetector(
// // onTap: widget.onTap,
// // child: AnimatedContainer(
// // duration: const Duration(milliseconds: 200),
// // width: 42,
// // height: 42,
// // decoration: BoxDecoration(
// // borderRadius: BorderRadius.circular(13),
// // color: Color.fromRGBO(255, 255, 255, _hovered ? 0.28 : 0.16),
// // border: Border.all(
// // color: Color.fromRGBO(255, 255, 255, _hovered ? 0.4 : 0.22),
// // ),
// // ),
// // child: Icon(widget.icon, color: Colors.white, size: 22),
// // ),
// // ),
// // ),
// // );
// // }
// // }
// //
// // /// Big gradient card for the main action (View Work)
// // class _FeaturedCard extends StatefulWidget {
// // final _MenuItem item;
// // final VoidCallback onTap;
// //
// // const _FeaturedCard({required this.item, required this.onTap});
// //
// // @override
// // State<_FeaturedCard> createState() => _FeaturedCardState();
// // }
// //
// // class _FeaturedCardState extends State<_FeaturedCard> {
// // bool _hovered = false;
// //
// // @override
// // Widget build(BuildContext context) {
// // return MouseRegion(
// // cursor: SystemMouseCursors.click,
// // onEnter: (_) => setState(() => _hovered = true),
// // onExit: (_) => setState(() => _hovered = false),
// // child: AnimatedContainer(
// // duration: const Duration(milliseconds: 200),
// // curve: Curves.easeOut,
// // transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
// // decoration: BoxDecoration(
// // gradient: const LinearGradient(
// // begin: Alignment(-1, -0.09),
// // end: Alignment(1, 0.09),
// // colors: [HomeColors.gradA, HomeColors.btnB],
// // ),
// // borderRadius: BorderRadius.circular(22),
// // boxShadow: [
// // BoxShadow(
// // color: HomeColors.btnShadow,
// // blurRadius: _hovered ? 32 : 26,
// // offset: Offset(0, _hovered ? 18 : 14),
// // spreadRadius: -10,
// // ),
// // ],
// // ),
// // child: Material(
// // color: Colors.transparent,
// // child: InkWell(
// // borderRadius: BorderRadius.circular(22),
// // onTap: widget.onTap,
// // child: Padding(
// // padding: const EdgeInsets.all(20),
// // child: Row(
// // children: [
// // Container(
// // width: 58,
// // height: 58,
// // decoration: BoxDecoration(
// // color: const Color.fromRGBO(255, 255, 255, 0.18),
// // borderRadius: BorderRadius.circular(17),
// // border: Border.all(
// // color: const Color.fromRGBO(255, 255, 255, 0.25),
// // ),
// // ),
// // child: Icon(widget.item.icon,
// // color: Colors.white, size: 30),
// // ),
// // const SizedBox(width: 16),
// // Expanded(
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // Text(
// // widget.item.title,
// // style: const TextStyle(
// // color: Colors.white,
// // fontSize: 19,
// // fontWeight: FontWeight.w700,
// // ),
// // ),
// // const SizedBox(height: 4),
// // Text(
// // widget.item.subtitle,
// // style: const TextStyle(
// // color: HomeColors.leftText,
// // fontSize: 13,
// // height: 1.45,
// // ),
// // ),
// // ],
// // ),
// // ),
// // const SizedBox(width: 8),
// // AnimatedSlide(
// // duration: const Duration(milliseconds: 200),
// // offset: Offset(_hovered ? 0.2 : 0, 0),
// // child: const Icon(
// // Icons.arrow_forward_rounded,
// // color: Colors.white,
// // size: 22,
// // ),
// // ),
// // ],
// // ),
// // ),
// // ),
// // ),
// // ),
// // );
// // }
// // }
// //
// // /// Grid card. HOVER: lifts, border darkens, icon tile fills with purple.
// // class _MenuCard extends StatefulWidget {
// // final _MenuItem item;
// // final VoidCallback onTap;
// //
// // const _MenuCard({required this.item, required this.onTap});
// //
// // @override
// // State<_MenuCard> createState() => _MenuCardState();
// // }
// //
// // class _MenuCardState extends State<_MenuCard> {
// // bool _hovered = false;
// //
// // @override
// // Widget build(BuildContext context) {
// // return MouseRegion(
// // cursor: SystemMouseCursors.click,
// // onEnter: (_) => setState(() => _hovered = true),
// // onExit: (_) => setState(() => _hovered = false),
// // child: AnimatedContainer(
// // duration: const Duration(milliseconds: 200),
// // curve: Curves.easeOut,
// // transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
// // decoration: BoxDecoration(
// // color: Colors.white,
// // borderRadius: BorderRadius.circular(20),
// // border: Border.all(
// // color: _hovered ? HomeColors.borderHover : HomeColors.border,
// // width: 1.5,
// // ),
// // boxShadow: [
// // BoxShadow(
// // color: HomeColors.softShadow,
// // blurRadius: _hovered ? 30 : 18,
// // offset: Offset(0, _hovered ? 16 : 8),
// // spreadRadius: -8,
// // ),
// // ],
// // ),
// // child: Material(
// // color: Colors.transparent,
// // child: InkWell(
// // borderRadius: BorderRadius.circular(20),
// // onTap: widget.onTap,
// // child: Padding(
// // padding: const EdgeInsets.all(16),
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // AnimatedContainer(
// // duration: const Duration(milliseconds: 200),
// // width: 48,
// // height: 48,
// // decoration: BoxDecoration(
// // borderRadius: BorderRadius.circular(14),
// // color: _hovered ? null : HomeColors.badgeBg,
// // gradient: _hovered
// // ? const LinearGradient(
// // begin: Alignment.topLeft,
// // end: Alignment.bottomRight,
// // colors: [HomeColors.gradA, HomeColors.gradC],
// // )
// //     : null,
// // ),
// // child: Icon(
// // widget.item.icon,
// // size: 24,
// // color: _hovered ? Colors.white : HomeColors.accent,
// // ),
// // ),
// // const Spacer(),
// // Text(
// // widget.item.title,
// // maxLines: 1,
// // overflow: TextOverflow.ellipsis,
// // style: const TextStyle(
// // color: HomeColors.ink,
// // fontSize: 15.5,
// // fontWeight: FontWeight.w700,
// // ),
// // ),
// // const SizedBox(height: 3),
// // Text(
// // widget.item.subtitle,
// // maxLines: 2,
// // overflow: TextOverflow.ellipsis,
// // style: const TextStyle(
// // color: HomeColors.subtitle,
// // fontSize: 12.5,
// // height: 1.35,
// // ),
// // ),
// // ],
// // ),
// // ),
// // ),
// // ),
// // ),
// // );
// // }
// // }
// //
// // /// Drawer row with a tinted icon tile
// // class _DrawerTile extends StatelessWidget {
// // final IconData icon;
// // final String label;
// // final VoidCallback onTap;
// // final bool danger;
// //
// // const _DrawerTile({
// // required this.icon,
// // required this.label,
// // required this.onTap,
// // this.danger = false,
// // });
// //
// // @override
// // Widget build(BuildContext context) {
// // final color = danger ? HomeColors.coral : HomeColors.accent;
// // final textColor = danger ? HomeColors.coral : HomeColors.ink;
// //
// // return Padding(
// // padding: const EdgeInsets.only(bottom: 4),
// // child: ListTile(
// // onTap: onTap,
// // hoverColor: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
// // splashColor: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
// // shape: RoundedRectangleBorder(
// // borderRadius: BorderRadius.circular(14),
// // ),
// // contentPadding: const EdgeInsets.symmetric(horizontal: 10),
// // leading: Container(
// // width: 40,
// // height: 40,
// // decoration: BoxDecoration(
// // color: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
// // borderRadius: BorderRadius.circular(12),
// // ),
// // child: Icon(icon, color: color, size: 21),
// // ),
// // title: Text(
// // label,
// // style: TextStyle(
// // color: textColor,
// // fontSize: 15,
// // fontWeight: FontWeight.w600,
// // ),
// // ),
// // trailing: danger
// // ? null
// //     : const Icon(
// // Icons.chevron_right_rounded,
// // color: HomeColors.borderHover,
// // ),
// // ),
// // );
// // }
// // }
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' as math;
//
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:untitled/viewwork.dart';
// import 'package:untitled/changepassword.dart';
// import 'package:untitled/login.dart';
// import 'package:untitled/viewfeedback.dart';
// import 'package:untitled/viewprofile.dart';
// import 'package:untitled/viewteamleader.dart';
//
// /// Same purple palette as the login page.
// /// (Named HomeColors so it never clashes with AppColors in login.dart)
// class HomeColors {
//   static const bg = Color(0xFFFAF7FC);
//
//   static const gradA = Color(0xFF7C4AD8);
//   static const gradB = Color(0xFF6538BD);
//   static const gradC = Color(0xFF4B2992);
//
//   static const btnB = Color(0xFF4D2997);
//
//   static const title = Color(0xFF4D2B91);
//   static const ink = Color(0xFF352746);
//   static const subtitle = Color(0xFF76698D);
//   static const leftText = Color(0xFFEAE1FB);
//
//   static const accent = Color(0xFF7040C9);
//   static const badgeBg = Color(0xFFF1E9FF);
//   static const coral = Color(0xFFE0457B);
//
//   static const border = Color(0xFFE6DCF3);
//   static const borderHover = Color(0xFFC9B6E8);
//
//   static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
//   static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
//   static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
// }
//
// class _MenuItem {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final WidgetBuilder page;
//
//   const _MenuItem(this.icon, this.title, this.subtitle, this.page);
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   // ---------------- PROFILE DATA ----------------
//
//   String _name = '';
//   String? _photoUrl;
//
//   // ---------------- AUTOMATIC EMOTION MONITORING ----------------
//   //
//   // No emotion button is required.
//   //
//   // Every 10 seconds:
//   //  1. Capture a photo from the front camera.
//   //  2. Upload it to mobileemotion_predict_post/.
//   //  3. Django + FER predicts the emotion and score.
//   //  4. Send that returned emotion/score to mobileemotion_post/
//   //     so it is stored for the logged-in user.
//   //
//   // Backend flow:
//   //   POST /mobileemotion_predict_post/
//   //       image=<camera image>
//   //
//   //   response:
//   //       {status:"ok", emotion:"happy", score:0.91}
//   //
//   //   POST /mobileemotion_post/
//   //       lid=<user id>
//   //       emotion=<emotion>
//   //       score=<score>
//
//   static const String _emotionPredictEndpoint =
//       '/mobileemotion_predict_post/';
//
//   static const String _emotionSaveEndpoint = '/mobileemotion_post/';
//
//   CameraController? _cameraController;
//   Timer? _emotionTimer;
//
//   bool _emotionMonitoring = false;
//   bool _emotionProcessing = false;
//
//   String _lastEmotion = 'Detecting...';
//   double? _lastEmotionScore;
//   DateTime? _lastEmotionAt;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _loadProfile();
//     _startEmotionMonitoring();
//   }
//
//   Future<void> _startEmotionMonitoring() async {
//     if (_emotionMonitoring || !mounted) return;
//
//     try {
//       final cameras = await availableCameras();
//
//       if (cameras.isEmpty || !mounted) {
//         debugPrint('EMOTION: no camera available');
//         return;
//       }
//
//       final frontCamera = cameras.firstWhere(
//             (camera) => camera.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras.first,
//       );
//
//       final controller = CameraController(
//         frontCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//
//       await controller.initialize();
//
//       if (!mounted) {
//         await controller.dispose();
//         return;
//       }
//
//       _cameraController = controller;
//       _emotionMonitoring = true;
//
//       // Perform the first detection shortly after entering HomePage.
//       await _captureAndSendEmotion();
//
//       // Continue automatically every 10 seconds.
//       _emotionTimer?.cancel();
//       _emotionTimer = Timer.periodic(
//         const Duration(seconds: 10),
//             (_) => _captureAndSendEmotion(),
//       );
//
//       debugPrint('EMOTION: automatic monitoring started');
//     } catch (e) {
//       debugPrint('EMOTION START ERROR: $e');
//       await _stopEmotionMonitoring();
//     }
//   }
//
//   Future<void> _captureAndSendEmotion() async {
//     if (!_emotionMonitoring ||
//         _emotionProcessing ||
//         !mounted ||
//         _cameraController == null ||
//         !_cameraController!.value.isInitialized) {
//       return;
//     }
//
//     _emotionProcessing = true;
//
//     XFile? imageFile;
//
//     try {
//       // Capture the current user's face automatically.
//       imageFile = await _cameraController!.takePicture();
//
//       final sh = await SharedPreferences.getInstance();
//       final baseUrl = (sh.getString('url') ?? '').replaceFirst(
//         RegExp(r'\/$'),
//         '',
//       );
//       final lid = sh.get('lid')?.toString() ?? '';
//
//       if (baseUrl.isEmpty || lid.isEmpty) {
//         debugPrint('EMOTION: missing baseUrl/lid');
//         return;
//       }
//
//       // -----------------------------------------------------------
//       // STEP 1: Send image to Django FER prediction endpoint.
//       // -----------------------------------------------------------
//       final predictRequest = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl$_emotionPredictEndpoint'),
//       );
//
//       predictRequest.files.add(
//         await http.MultipartFile.fromPath(
//           'image',
//           imageFile.path,
//         ),
//       );
//
//       final streamedResponse = await predictRequest.send().timeout(
//         const Duration(seconds: 30),
//       );
//
//       final responseBody = await streamedResponse.stream.bytesToString();
//
//       debugPrint(
//         'EMOTION PREDICT status=${streamedResponse.statusCode} '
//             'body=$responseBody',
//       );
//
//       if (streamedResponse.statusCode < 200 ||
//           streamedResponse.statusCode >= 300) {
//         debugPrint('EMOTION: prediction request failed');
//         return;
//       }
//
//       final prediction = jsonDecode(responseBody);
//
//       if (prediction['status'] != 'ok') {
//         final message =
//             prediction['message']?.toString() ?? 'No face detected';
//
//         _setDetectedEmotion(
//           emotion: message,
//           score: null,
//         );
//
//         return;
//       }
//
//       final emotionName = prediction['emotion']?.toString() ?? '';
//
//       final dynamic scoreValue = prediction['score'];
//
//       final double? score =
//       scoreValue == null ? null : double.tryParse(scoreValue.toString());
//
//       if (emotionName.isEmpty || score == null) {
//         debugPrint('EMOTION: invalid prediction response');
//         return;
//       }
//
//       _setDetectedEmotion(
//         emotion: emotionName,
//         score: score,
//       );
//
//       // -----------------------------------------------------------
//       // STEP 2: Save Django FER result to the logged-in user.
//       // -----------------------------------------------------------
//       final saveResponse = await http.post(
//         Uri.parse('$baseUrl$_emotionSaveEndpoint'),
//         body: {
//           'lid': lid,
//           'emotion': emotionName,
//           'score': score.toString(),
//         },
//       ).timeout(
//         const Duration(seconds: 15),
//       );
//
//       debugPrint(
//         'EMOTION SAVE status=${saveResponse.statusCode} '
//             'body=${saveResponse.body}',
//       );
//
//       if (saveResponse.statusCode < 200 || saveResponse.statusCode >= 300) {
//         debugPrint('EMOTION: save request failed');
//       }
//     } catch (e) {
//       // A temporary camera/network error must not stop future 10-second
//       // monitoring attempts.
//       debugPrint('EMOTION CAPTURE/SEND ERROR: $e');
//     } finally {
//       _emotionProcessing = false;
//
//       // Remove the temporary camera image.
//       if (imageFile != null) {
//         try {
//           await File(imageFile.path).delete();
//         } catch (_) {}
//       }
//     }
//   }
//
//   void _setDetectedEmotion({
//     required String emotion,
//     required double? score,
//   }) {
//     if (!mounted) return;
//
//     setState(() {
//       _lastEmotion = emotion;
//       _lastEmotionScore = score;
//       _lastEmotionAt = DateTime.now();
//     });
//
//     debugPrint(
//       'EMOTION DETECTED: $emotion'
//           '${score == null ? '' : ' score=$score'}',
//     );
//   }
//
//   Future<void> _stopEmotionMonitoring() async {
//     _emotionTimer?.cancel();
//     _emotionTimer = null;
//     _emotionMonitoring = false;
//     _emotionProcessing = false;
//
//     final controller = _cameraController;
//     _cameraController = null;
//
//     await controller?.dispose();
//
//     debugPrint('EMOTION: automatic monitoring stopped');
//   }
//
//   Future<void> _restartEmotionMonitoring() async {
//     await _stopEmotionMonitoring();
//
//     if (mounted) {
//       await _startEmotionMonitoring();
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _restartEmotionMonitoring();
//     } else if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       _stopEmotionMonitoring();
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _stopEmotionMonitoring();
//     super.dispose();
//   }
//
//   Future<void> _loadProfile() async {
//     try {
//       final sh = await SharedPreferences.getInstance();
//
//       final baseUrl = sh.getString('url') ?? '';
//       // works even if lid was saved as an int
//       final lid = sh.get('lid')?.toString() ?? '';
//
//       debugPrint('PROFILE baseUrl=$baseUrl lid=$lid');
//
//       // show the last known name right away while the request runs
//       final cached = sh.getString('name') ?? '';
//       if (cached.isNotEmpty && mounted) {
//         setState(() => _name = cached);
//       }
//
//       // same URL as viewprofile.dart (note the trailing slash)
//       final res = await http.post(
//         Uri.parse('$baseUrl/teammemberviewprofile_post/'),
//         body: {'lid': lid},
//       ).timeout(const Duration(seconds: 15));
//
//       debugPrint('PROFILE status=${res.statusCode} body=${res.body}');
//
//       final data = jsonDecode(res.body);
//
//       if (data['status'] == 'ok') {
//         await sh.setString('name', (data['name'] ?? '').toString());
//         if (!mounted) return;
//         setState(() {
//           _name = (data['name'] ?? '').toString();
//           final p = (data['photo'] ?? '').toString();
//           _photoUrl = p.isEmpty ? null : p;
//         });
//       }
//     } catch (e) {
//       // keep the fallback icon and generic text if loading fails
//       debugPrint('PROFILE ERROR: $e');
//     }
//   }
//
//   // ---------------- MENU ITEMS ----------------
//
//   late final _MenuItem _work = _MenuItem(
//     Icons.work_rounded,
//     'My Work',
//     'See the tasks assigned to you and update their status',
//         (context) => viewwork(),
//   );
//
//   late final List<_MenuItem> _items = [
//     _MenuItem(
//       Icons.person_rounded,
//       'Profile',
//       'View your details',
//           (context) => viewprofile(),
//     ),
//     _MenuItem(
//       Icons.lock_rounded,
//       'Change Password',
//       'Keep your account safe',
//           (context) => changepassword(),
//     ),
//     _MenuItem(
//       Icons.groups_rounded,
//       'My Leaders',
//       'Your team leaders',
//           (context) => viewteamleader(),
//     ),
//     _MenuItem(
//       Icons.feedback_rounded,
//       'Feedback',
//       'See feedback for you',
//           (context) => viewfeedback(),
//     ),
//   ];
//
//   String get _greeting {
//     final h = DateTime.now().hour;
//     if (h < 12) return 'Good morning';
//     if (h < 17) return 'Good afternoon';
//     return 'Good evening';
//   }
//
//   // ---------------- ACTIONS ----------------
//
//   Future<void> _open(_MenuItem item) async {
//     await Navigator.push(context, MaterialPageRoute(builder: item.page));
//     // reload in case the profile (name / photo) was edited
//     if (mounted) _loadProfile();
//   }
//
//   Future<void> logout() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//
//     await sh.remove('lid');
//     await sh.remove('name');
//
//     if (!mounted) return;
//
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (context) => loginpage(),
//       ),
//           (route) => false,
//     );
//   }
//
//   Future<void> _confirmLogout() async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(22),
//         ),
//         title: const Text(
//           'Log out?',
//           style: TextStyle(
//             color: HomeColors.title,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         content: const Text(
//           'You will need to sign in again to continue.',
//           style: TextStyle(color: HomeColors.subtitle),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             style: TextButton.styleFrom(
//               foregroundColor: HomeColors.subtitle,
//             ),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: HomeColors.coral,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text('Log out'),
//           ),
//         ],
//       ),
//     );
//
//     if (ok == true) {
//       await logout();
//     }
//   }
//
//   // ---------------- UI ----------------
//
//   /// Profile photo if available, otherwise a fallback icon.
//   Widget _photoOrIcon(IconData fallback, double iconSize) {
//     final icon = Icon(fallback, color: Colors.white, size: iconSize);
//
//     if (_photoUrl == null) return icon;
//
//     return Image.network(
//       _photoUrl!,
//       fit: BoxFit.cover,
//       width: double.infinity,
//       height: double.infinity,
//       errorBuilder: (_, __, ___) => icon,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final columns = width >= 900 ? 4 : 2;
//
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: HomeColors.bg,
//       drawer: _buildDrawer(),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildHeader(context),
//             Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 900),
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Quick access',
//                         style: TextStyle(
//                           color: HomeColors.title,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'serif',
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//
//                       // Automatic emotion-monitoring status.
//                       _EmotionStatusCard(
//                         emotion: _lastEmotion,
//                         score: _lastEmotionScore,
//                         isMonitoring: _emotionMonitoring,
//                         lastDetectedAt: _lastEmotionAt,
//                       ),
//                       const SizedBox(height: 16),
//
//                       // featured card
//                       _FeaturedCard(
//                         item: _work,
//                         onTap: () => _open(_work),
//                       ),
//                       const SizedBox(height: 16),
//
//                       GridView.count(
//                         crossAxisCount: columns,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         mainAxisSpacing: 16,
//                         crossAxisSpacing: 16,
//                         childAspectRatio: 1.05,
//                         children: _items
//                             .map((item) => _MenuCard(
//                           item: item,
//                           onTap: () => _open(item),
//                         ))
//                             .toList(),
//                       ),
//
//                       const SizedBox(height: 24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.shield_outlined,
//                               size: 13, color: Color(0xFF9A8FB0)),
//                           SizedBox(width: 7),
//                           Flexible(
//                             child: Text(
//                               'Your data is encrypted and private',
//                               style: TextStyle(
//                                 color: Color(0xFF9A8FB0),
//                                 fontSize: 12.5,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context) {
//     final topPad = MediaQuery.of(context).padding.top;
//
//     return Container(
//       width: double.infinity,
//       clipBehavior: Clip.antiAlias,
//       padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 34),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment(-0.5, -1),
//           end: Alignment(0.5, 1),
//           colors: [HomeColors.gradA, HomeColors.gradB, HomeColors.gradC],
//           stops: [0.0, 0.5, 1.0],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(36),
//           bottomRight: Radius.circular(36),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: HomeColors.cardShadow,
//             blurRadius: 40,
//             offset: Offset(0, 20),
//             spreadRadius: -10,
//           ),
//         ],
//       ),
//       child: Stack(
//         clipBehavior: Clip.hardEdge,
//         children: [
//           Positioned(
//             top: -90,
//             right: -80,
//             child: Container(
//               width: 240,
//               height: 240,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color.fromRGBO(255, 255, 255, 0.06),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -80,
//             left: -70,
//             child: Container(
//               width: 190,
//               height: 190,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color.fromRGBO(255, 255, 255, 0.04),
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   _HeaderButton(
//                     icon: Icons.menu_rounded,
//                     tooltip: 'Menu',
//                     onTap: () => _scaffoldKey.currentState?.openDrawer(),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Calmora',
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.2,
//                       ),
//                     ),
//                   ),
//                   _HeaderButton(
//                     icon: Icons.logout_rounded,
//                     tooltip: 'Log out',
//                     onTap: _confirmLogout,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   // avatar: profile photo, falls back to icon
//                   Container(
//                     width: 58,
//                     height: 58,
//                     clipBehavior: Clip.antiAlias,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: const Color.fromRGBO(255, 255, 255, 0.16),
//                       border: Border.all(
//                         color: const Color.fromRGBO(255, 255, 255, 0.28),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: _photoOrIcon(Icons.person_rounded, 30),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _greeting,
//                           style: const TextStyle(
//                             color: HomeColors.leftText,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         // logged-in user's name
//                         Text(
//                           _name,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.w600,
//                             fontFamily: 'serif',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),
//               const Text(
//                 'Manage your work, feedback and profile in one place.',
//                 style: TextStyle(
//                   color: HomeColors.leftText,
//                   fontSize: 14.5,
//                   height: 1.6,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- DRAWER ----------------
//
//   Widget _buildDrawer() {
//     void go(_MenuItem item) {
//       Navigator.pop(context);
//       _open(item);
//     }
//
//     return Drawer(
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topRight: Radius.circular(28),
//           bottomRight: Radius.circular(28),
//         ),
//       ),
//       child: Column(
//         children: [
//           // drawer header
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.fromLTRB(
//               22,
//               MediaQuery.of(context).padding.top + 28,
//               22,
//               26,
//             ),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment(-0.5, -1),
//                 end: Alignment(0.5, 1),
//                 colors: [
//                   HomeColors.gradA,
//                   HomeColors.gradB,
//                   HomeColors.gradC,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//               borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(28),
//                 bottomRight: Radius.circular(28),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 54,
//                   height: 54,
//                   clipBehavior: Clip.antiAlias,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: const Color.fromRGBO(255, 255, 255, 0.16),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: const Color.fromRGBO(255, 255, 255, 0.24),
//                     ),
//                   ),
//                   child: _photoOrIcon(Icons.monitor_heart_outlined, 28),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   _name.isEmpty ? 'Workplace Wellbeing' : _name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 const Text(
//                   'Team member',
//                   style: TextStyle(
//                     color: HomeColors.leftText,
//                     fontSize: 13.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
//               children: [
//                 _DrawerTile(
//                   icon: Icons.person_rounded,
//                   label: 'Profile',
//                   onTap: () => go(_items[0]),
//                 ),
//                 _DrawerTile(
//                   icon: Icons.lock_rounded,
//                   label: 'Change Password',
//                   onTap: () => go(_items[1]),
//                 ),
//                 _DrawerTile(
//                   icon: Icons.groups_rounded,
//                   label: 'View My Leaders',
//                   onTap: () => go(_items[2]),
//                 ),
//                 _DrawerTile(
//                   icon: Icons.feedback_rounded,
//                   label: 'View Feedback',
//                   onTap: () => go(_items[3]),
//                 ),
//                 _DrawerTile(
//                   icon: Icons.work_rounded,
//                   label: 'View Work',
//                   onTap: () => go(_work),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                   child: Divider(color: HomeColors.border, height: 1),
//                 ),
//                 _DrawerTile(
//                   icon: Icons.logout_rounded,
//                   label: 'Logout',
//                   danger: true,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _confirmLogout();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // =====================================================
// //  EMOTION STATUS CARD (attractive redesign)
// // =====================================================
//
// class _EmotionStyle {
//   final String emoji;
//   final Color a;
//   final Color b;
//   final String message;
//
//   const _EmotionStyle(this.emoji, this.a, this.b, this.message);
// }
//
// class _EmotionStatusCard extends StatefulWidget {
//   final String emotion;
//   final double? score;
//   final bool isMonitoring;
//   final DateTime? lastDetectedAt;
//
//   const _EmotionStatusCard({
//     required this.emotion,
//     required this.score,
//     required this.isMonitoring,
//     required this.lastDetectedAt,
//   });
//
//   @override
//   State<_EmotionStatusCard> createState() => _EmotionStatusCardState();
// }
//
// class _EmotionStatusCardState extends State<_EmotionStatusCard>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _pulse = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 2200),
//   )..repeat(reverse: true);
//
//   @override
//   void dispose() {
//     _pulse.dispose();
//     super.dispose();
//   }
//
//   // ---- emotion -> look ----
//
//   static const _brand = _EmotionStyle(
//     '🙂',
//     HomeColors.gradA,
//     HomeColors.gradC,
//     'Getting a reading on how you feel.',
//   );
//
//   static _EmotionStyle _styleFor(String e) {
//     switch (e.toLowerCase().trim()) {
//       case 'happy':
//         return const _EmotionStyle('😊', Color(0xFF34C48A), Color(0xFF1B7A4E),
//             'You look cheerful. Keep that energy going!');
//       case 'sad':
//         return const _EmotionStyle('😢', Color(0xFF5B8DEF), Color(0xFF2F55A8),
//             'Feeling low? A short break might help.');
//       case 'angry':
//         return const _EmotionStyle('😠', Color(0xFFEF5A8C), Color(0xFFB02A5C),
//             'Take a slow breath. You are doing fine.');
//       case 'fear':
//         return const _EmotionStyle('😨', Color(0xFFF0A040), Color(0xFFB5651A),
//             'Feeling uneasy? Talk to someone you trust.');
//       case 'surprise':
//         return const _EmotionStyle('😮', Color(0xFFA66BEB), Color(0xFF6538BD),
//             'Something unexpected? Take a moment.');
//       case 'disgust':
//         return const _EmotionStyle('🤢', Color(0xFF9DB035), Color(0xFF5F6E1B),
//             'Something bothering you? Step away for a bit.');
//       case 'neutral':
//         return const _EmotionStyle('😐', Color(0xFF8A5CE0), Color(0xFF4B2992),
//             'Calm and steady. Nice and balanced.');
//       default:
//         return _brand;
//     }
//   }
//
//   static String _capitalize(String s) =>
//       s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
//
//   static String _formatTime(DateTime value) {
//     final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
//     final minute = value.minute.toString().padLeft(2, '0');
//     final second = value.second.toString().padLeft(2, '0');
//     final suffix = value.hour >= 12 ? 'PM' : 'AM';
//     return '$hour:$minute:$second $suffix';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final hasReading = widget.score != null;
//     final style = hasReading ? _styleFor(widget.emotion) : _brand;
//
//     final String title;
//     final String message;
//
//     if (!widget.isMonitoring) {
//       title = 'Monitoring off';
//       message = 'Camera is unavailable right now.';
//     } else if (hasReading) {
//       title = _capitalize(widget.emotion);
//       message = style.message;
//     } else if (widget.emotion == 'Detecting...') {
//       title = 'Detecting...';
//       message = 'Getting your first reading.';
//     } else {
//       title = _capitalize(widget.emotion);
//       message = 'Look at the camera so we can check in.';
//     }
//
//     final timeText = widget.lastDetectedAt == null
//         ? 'Waiting...'
//         : _formatTime(widget.lastDetectedAt!);
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeOut,
//       width: double.infinity,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [style.a, style.b],
//         ),
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: style.b.withOpacity(0.45),
//             blurRadius: 30,
//             offset: const Offset(0, 16),
//             spreadRadius: -10,
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // decorative soft circles
//           Positioned(
//             top: -60,
//             right: -50,
//             child: Container(
//               width: 180,
//               height: 180,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color.fromRGBO(255, 255, 255, 0.08),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -70,
//             left: -40,
//             child: Container(
//               width: 160,
//               height: 160,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color.fromRGBO(255, 255, 255, 0.06),
//               ),
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ---- header row ----
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: const Color.fromRGBO(255, 255, 255, 0.16),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Icon(Icons.auto_awesome_rounded,
//                               size: 13, color: Colors.white),
//                           SizedBox(width: 6),
//                           Text(
//                             'MOOD CHECK',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Spacer(),
//                     _LivePill(active: widget.isMonitoring),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // ---- ring avatar + text ----
//                 Row(
//                   children: [
//                     _buildRingAvatar(style, hasReading),
//                     const SizedBox(width: 18),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'You seem',
//                             style: TextStyle(
//                               color: Color.fromRGBO(255, 255, 255, 0.75),
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           AnimatedSwitcher(
//                             duration: const Duration(milliseconds: 350),
//                             transitionBuilder: (child, anim) =>
//                                 FadeTransition(
//                                   opacity: anim,
//                                   child: SlideTransition(
//                                     position: Tween<Offset>(
//                                       begin: const Offset(0, 0.25),
//                                       end: Offset.zero,
//                                     ).animate(anim),
//                                     child: child,
//                                   ),
//                                 ),
//                             child: Text(
//                               title,
//                               key: ValueKey(title),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 30,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'serif',
//                                 height: 1.1,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             message,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               color: Color.fromRGBO(255, 255, 255, 0.85),
//                               fontSize: 13,
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 18),
//
//                 // ---- info chips ----
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 8,
//                   children: [
//                     if (hasReading)
//                       _InfoChip(
//                         icon: Icons.verified_rounded,
//                         text:
//                         '${(widget.score! * 100).toStringAsFixed(1)}% confident',
//                       ),
//                     _InfoChip(
//                       icon: Icons.schedule_rounded,
//                       text: timeText,
//                     ),
//                     const _InfoChip(
//                       icon: Icons.sync_rounded,
//                       text: 'Every 10s',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Emoji in a glowing circle, wrapped by a confidence ring.
//   Widget _buildRingAvatar(_EmotionStyle style, bool hasReading) {
//     const size = 104.0;
//
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // pulsing glow
//           AnimatedBuilder(
//             animation: _pulse,
//             builder: (context, _) {
//               final t = Curves.easeInOut.transform(_pulse.value);
//               return Container(
//                 width: 78 + 22 * t,
//                 height: 78 + 22 * t,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Color.fromRGBO(255, 255, 255, 0.14 - 0.08 * t),
//                 ),
//               );
//             },
//           ),
//
//           // confidence ring
//           TweenAnimationBuilder<double>(
//             tween: Tween(
//               begin: 0,
//               end: hasReading ? widget.score!.clamp(0.0, 1.0) : 0.0,
//             ),
//             duration: const Duration(milliseconds: 700),
//             curve: Curves.easeOutCubic,
//             builder: (context, value, _) => CustomPaint(
//               size: const Size(size, size),
//               painter: _RingPainter(progress: value),
//             ),
//           ),
//
//           // emoji disc
//           Container(
//             width: 74,
//             height: 74,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: style.b.withOpacity(0.35),
//                   blurRadius: 14,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 350),
//               transitionBuilder: (child, anim) => ScaleTransition(
//                 scale: anim,
//                 child: FadeTransition(opacity: anim, child: child),
//               ),
//               child: hasReading
//                   ? Text(
//                 style.emoji,
//                 key: ValueKey(style.emoji),
//                 style: const TextStyle(fontSize: 38),
//               )
//                   : Icon(
//                 widget.isMonitoring
//                     ? Icons.face_retouching_natural_rounded
//                     : Icons.face_retouching_off_rounded,
//                 key: const ValueKey('icon'),
//                 color: style.b,
//                 size: 36,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// Paints a circular progress ring (used for the confidence score).
// class _RingPainter extends CustomPainter {
//   final double progress;
//
//   const _RingPainter({required this.progress});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     const stroke = 6.0;
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = (size.width - stroke) / 2;
//
//     final track = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = stroke
//       ..color = const Color.fromRGBO(255, 255, 255, 0.25);
//
//     final arc = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = stroke
//       ..strokeCap = StrokeCap.round
//       ..color = Colors.white;
//
//     canvas.drawCircle(center, radius, track);
//
//     if (progress > 0) {
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         -math.pi / 2,
//         2 * math.pi * progress,
//         false,
//         arc,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
// }
//
// /// Small translucent info chip used at the bottom of the card.
// class _InfoChip extends StatelessWidget {
//   final IconData icon;
//   final String text;
//
//   const _InfoChip({required this.icon, required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(255, 255, 255, 0.16),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: Colors.white),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// "Live" / "Off" pill with a pulsing dot (built for the dark card).
// class _LivePill extends StatefulWidget {
//   final bool active;
//
//   const _LivePill({required this.active});
//
//   @override
//   State<_LivePill> createState() => _LivePillState();
// }
//
// class _LivePillState extends State<_LivePill>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 1100),
//   )..repeat(reverse: true);
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dot =
//     widget.active ? const Color(0xFF7CF2B0) : const Color(0xFFD5CBE6);
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(255, 255, 255, 0.16),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FadeTransition(
//             opacity: widget.active
//                 ? Tween<double>(begin: 0.35, end: 1).animate(_ctrl)
//                 : const AlwaysStoppedAnimation(1),
//             child: Container(
//               width: 8,
//               height: 8,
//               decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             widget.active ? 'Live' : 'Off',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // =====================================================
// //  WIDGETS
// // =====================================================
//
// /// Round translucent icon button used in the header
// class _HeaderButton extends StatefulWidget {
//   final IconData icon;
//   final String tooltip;
//   final VoidCallback onTap;
//
//   const _HeaderButton({
//     required this.icon,
//     required this.tooltip,
//     required this.onTap,
//   });
//
//   @override
//   State<_HeaderButton> createState() => _HeaderButtonState();
// }
//
// class _HeaderButtonState extends State<_HeaderButton> {
//   bool _hovered = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Tooltip(
//       message: widget.tooltip,
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         onEnter: (_) => setState(() => _hovered = true),
//         onExit: (_) => setState(() => _hovered = false),
//         child: GestureDetector(
//           onTap: widget.onTap,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(13),
//               color: Color.fromRGBO(255, 255, 255, _hovered ? 0.28 : 0.16),
//               border: Border.all(
//                 color: Color.fromRGBO(255, 255, 255, _hovered ? 0.4 : 0.22),
//               ),
//             ),
//             child: Icon(widget.icon, color: Colors.white, size: 22),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Big gradient card for the main action (View Work)
// class _FeaturedCard extends StatefulWidget {
//   final _MenuItem item;
//   final VoidCallback onTap;
//
//   const _FeaturedCard({required this.item, required this.onTap});
//
//   @override
//   State<_FeaturedCard> createState() => _FeaturedCardState();
// }
//
// class _FeaturedCardState extends State<_FeaturedCard> {
//   bool _hovered = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => _hovered = true),
//       onExit: (_) => setState(() => _hovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             begin: Alignment(-1, -0.09),
//             end: Alignment(1, 0.09),
//             colors: [HomeColors.gradA, HomeColors.btnB],
//           ),
//           borderRadius: BorderRadius.circular(22),
//           boxShadow: [
//             BoxShadow(
//               color: HomeColors.btnShadow,
//               blurRadius: _hovered ? 32 : 26,
//               offset: Offset(0, _hovered ? 18 : 14),
//               spreadRadius: -10,
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(22),
//             onTap: widget.onTap,
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 58,
//                     height: 58,
//                     decoration: BoxDecoration(
//                       color: const Color.fromRGBO(255, 255, 255, 0.18),
//                       borderRadius: BorderRadius.circular(17),
//                       border: Border.all(
//                         color: const Color.fromRGBO(255, 255, 255, 0.25),
//                       ),
//                     ),
//                     child: Icon(widget.item.icon,
//                         color: Colors.white, size: 30),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.item.title,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 19,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           widget.item.subtitle,
//                           style: const TextStyle(
//                             color: HomeColors.leftText,
//                             fontSize: 13,
//                             height: 1.45,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   AnimatedSlide(
//                     duration: const Duration(milliseconds: 200),
//                     offset: Offset(_hovered ? 0.2 : 0, 0),
//                     child: const Icon(
//                       Icons.arrow_forward_rounded,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Grid card. HOVER: lifts, border darkens, icon tile fills with purple.
// class _MenuCard extends StatefulWidget {
//   final _MenuItem item;
//   final VoidCallback onTap;
//
//   const _MenuCard({required this.item, required this.onTap});
//
//   @override
//   State<_MenuCard> createState() => _MenuCardState();
// }
//
// class _MenuCardState extends State<_MenuCard> {
//   bool _hovered = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => _hovered = true),
//       onExit: (_) => setState(() => _hovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: _hovered ? HomeColors.borderHover : HomeColors.border,
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: HomeColors.softShadow,
//               blurRadius: _hovered ? 30 : 18,
//               offset: Offset(0, _hovered ? 16 : 8),
//               spreadRadius: -8,
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(20),
//             onTap: widget.onTap,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       color: _hovered ? null : HomeColors.badgeBg,
//                       gradient: _hovered
//                           ? const LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [HomeColors.gradA, HomeColors.gradC],
//                       )
//                           : null,
//                     ),
//                     child: Icon(
//                       widget.item.icon,
//                       size: 24,
//                       color: _hovered ? Colors.white : HomeColors.accent,
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     widget.item.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: HomeColors.ink,
//                       fontSize: 15.5,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     widget.item.subtitle,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: HomeColors.subtitle,
//                       fontSize: 12.5,
//                       height: 1.35,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Drawer row with a tinted icon tile
// class _DrawerTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   final bool danger;
//
//   const _DrawerTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.danger = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = danger ? HomeColors.coral : HomeColors.accent;
//     final textColor = danger ? HomeColors.coral : HomeColors.ink;
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: ListTile(
//         onTap: onTap,
//         hoverColor: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
//         splashColor: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 21),
//         ),
//         title: Text(
//           label,
//           style: TextStyle(
//             color: textColor,
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         trailing: danger
//             ? null
//             : const Icon(
//           Icons.chevron_right_rounded,
//           color: HomeColors.borderHover,
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:untitled/viewwork.dart';
import 'package:untitled/changepassword.dart';
import 'package:untitled/login.dart';
import 'package:untitled/viewfeedback.dart';
import 'package:untitled/viewprofile.dart';
import 'package:untitled/viewteamleader.dart';

// =====================================================
// COLORS
// =====================================================

class HomeColors {
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

  static const cardShadow = Color.fromRGBO(76, 42, 145, 0.28);
  static const softShadow = Color.fromRGBO(76, 42, 145, 0.12);
  static const btnShadow = Color.fromRGBO(91, 48, 170, 0.5);
}

// =====================================================
// MENU ITEM
// =====================================================

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder page;

  const _MenuItem(
      this.icon,
      this.title,
      this.subtitle,
      this.page,
      );
}

// =====================================================
// HOME PAGE
// =====================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// =====================================================
// HOME PAGE STATE
// =====================================================

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ---------------- PROFILE ----------------
  String _name = '';
  String? _photoUrl;

  // ---------------- ENDPOINTS ----------------
  static const String _emotionPredictEndpoint = '/mobileemotion_predict_post/';
  static const String _emotionSaveEndpoint = '/mobileemotion_post/';
  static const String _thermalPredictEndpoint = '/mobilethermalpredict_post/';

  // ---------------- CAMERA / TIMER ----------------
  CameraController? _cameraController;
  Timer? _monitorTimer;

  // ---------------- EMOTION ----------------
  bool _emotionMonitoring = false;
  bool _emotionProcessing = false;
  String _lastEmotion = 'Detecting...';
  double? _lastEmotionScore;
  DateTime? _lastEmotionAt;

  // ---------------- THERMAL ----------------
  bool _thermalMonitoring = false;
  bool _thermalProcessing = false;
  String _thermalStatus = 'Waiting...';
  double? _thermalScore;
  DateTime? _thermalLastChecked;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
    _startMonitoring();
  }

  // =====================================================
  // START BOTH MONITORING
  // =====================================================

  Future<void> _startMonitoring() async {
    if ((_emotionMonitoring || _thermalMonitoring) || !mounted) {
      return;
    }

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty || !mounted) {
        debugPrint('MONITORING: no camera available');
        return;
      }

      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _cameraController = controller;

      _emotionMonitoring = true;
      _thermalMonitoring = true;

      if (mounted) {
        setState(() {});
      }

      debugPrint('MONITORING: emotion + thermal started');

      await _captureAndProcess();

      _monitorTimer?.cancel();
      _monitorTimer = Timer.periodic(
        const Duration(seconds: 10),
            (_) => _captureAndProcess(),
      );
    } catch (e) {
      debugPrint('MONITORING START ERROR: $e');
      await _stopMonitoring();
    }
  }

  // =====================================================
  // CAPTURE ONE IMAGE (USED FOR EMOTION + THERMAL)
  // =====================================================

  Future<void> _captureAndProcess() async {
    if (!mounted ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    if (_emotionProcessing || _thermalProcessing) {
      debugPrint('MONITORING: previous processing still running');
      return;
    }

    XFile? imageFile;

    try {
      imageFile = await _cameraController!.takePicture();
      debugPrint('MONITORING: image captured');

      await _processEmotion(imageFile);
      await _processThermal(imageFile);
    } catch (e) {
      debugPrint('MONITORING CAPTURE ERROR: $e');
    } finally {
      if (imageFile != null) {
        try {
          await File(imageFile.path).delete();
        } catch (_) {}
      }
    }
  }

  // =====================================================
  // EMOTION DETECTION
  // =====================================================

  Future<void> _processEmotion(XFile imageFile) async {
    if (!_emotionMonitoring || _emotionProcessing || !mounted) {
      return;
    }

    _emotionProcessing = true;

    try {
      final sh = await SharedPreferences.getInstance();

      final baseUrl =
      (sh.getString('url') ?? '').replaceFirst(RegExp(r'\/$'), '');

      final lid = sh.get('lid')?.toString() ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) {
        debugPrint('EMOTION: missing baseUrl/lid');
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$_emotionPredictEndpoint'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final responseBody = await response.stream.bytesToString();

      debugPrint('EMOTION PREDICT '
          'status=${response.statusCode} '
          'body=$responseBody');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('EMOTION: prediction failed');
        return;
      }

      final prediction = jsonDecode(responseBody);

      // NO FACE
      if (prediction['status'] != 'ok') {
        final message =
            prediction['message']?.toString() ?? 'No face detected';

        _setDetectedEmotion(emotion: message, score: null);
        return;
      }

      final emotionName = prediction['emotion']?.toString() ?? '';

      final dynamic scoreValue = prediction['score'];

      final double? score =
      scoreValue == null ? null : double.tryParse(scoreValue.toString());

      if (emotionName.isEmpty || score == null) {
        debugPrint('EMOTION: invalid response');
        return;
      }

      _setDetectedEmotion(emotion: emotionName, score: score);

      // SAVE EMOTION
      final saveResponse = await http.post(
        Uri.parse('$baseUrl$_emotionSaveEndpoint'),
        body: {
          'lid': lid,
          'emotion': emotionName,
          'score': score.toString(),
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('EMOTION SAVE '
          'status=${saveResponse.statusCode} '
          'body=${saveResponse.body}');
    } catch (e) {
      debugPrint('EMOTION ERROR: $e');
    } finally {
      _emotionProcessing = false;
    }
  }

  void _setDetectedEmotion({
    required String emotion,
    required double? score,
  }) {
    if (!mounted) return;

    setState(() {
      _lastEmotion = emotion;
      _lastEmotionScore = score;
      _lastEmotionAt = DateTime.now();
    });

    debugPrint('EMOTION DETECTED: '
        '$emotion '
        '${score == null ? '' : 'score=$score'}');
  }

  // =====================================================
  // THERMAL STRESS DETECTION
  // =====================================================

  Future<void> _processThermal(XFile imageFile) async {
    if (!_thermalMonitoring || _thermalProcessing || !mounted) {
      return;
    }

    _thermalProcessing = true;

    try {
      final sh = await SharedPreferences.getInstance();

      final baseUrl =
      (sh.getString('url') ?? '').replaceFirst(RegExp(r'\/$'), '');

      final lid = sh.get('lid')?.toString() ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) {
        debugPrint('THERMAL: missing baseUrl/lid');
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$_thermalPredictEndpoint'),
      );

      request.fields['lid'] = lid;

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final responseBody = await response.stream.bytesToString();

      debugPrint('THERMAL PREDICT '
          'status=${response.statusCode} '
          'body=$responseBody');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _setThermalError('Prediction failed');
        return;
      }

      final prediction = jsonDecode(responseBody);

      if (prediction['status'] != 'ok') {
        final message =
            prediction['message']?.toString() ?? 'Thermal prediction failed';

        _setThermalError(message);
        return;
      }

      final stressStatus = prediction['stress_status']?.toString() ??
          prediction['stress']?.toString() ??
          'Unknown';

      final dynamic scoreValue = prediction['score'];

      double? score;

      if (scoreValue != null) {
        score = double.tryParse(scoreValue.toString());
      }

      if (mounted) {
        setState(() {
          _thermalStatus = stressStatus;
          _thermalScore = score;
          _thermalLastChecked = DateTime.now();
        });
      }

      debugPrint('THERMAL RESULT: '
          '$stressStatus '
          '${score == null ? '' : 'score=$score'}');
    } catch (e) {
      debugPrint('THERMAL ERROR: $e');
      _setThermalError('Connection error');
    } finally {
      _thermalProcessing = false;
    }
  }

  void _setThermalError(String message) {
    if (!mounted) return;

    setState(() {
      _thermalStatus = message;
      _thermalLastChecked = DateTime.now();
    });
  }

  // =====================================================
  // STOP / RESTART MONITORING
  // =====================================================

  Future<void> _stopMonitoring() async {
    _monitorTimer?.cancel();
    _monitorTimer = null;

    _emotionMonitoring = false;
    _thermalMonitoring = false;

    _emotionProcessing = false;
    _thermalProcessing = false;

    final controller = _cameraController;
    _cameraController = null;

    await controller?.dispose();

    debugPrint('MONITORING: emotion + thermal stopped');
  }

  Future<void> _restartMonitoring() async {
    await _stopMonitoring();

    if (mounted) {
      await _startMonitoring();
    }
  }

  // =====================================================
  // APP LIFECYCLE
  // =====================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restartMonitoring();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopMonitoring();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopMonitoring();
    super.dispose();
  }

  // =====================================================
  // LOAD PROFILE
  // =====================================================

  Future<void> _loadProfile() async {
    try {
      final sh = await SharedPreferences.getInstance();

      final baseUrl = sh.getString('url') ?? '';
      final lid = sh.get('lid')?.toString() ?? '';

      debugPrint('PROFILE baseUrl=$baseUrl lid=$lid');

      final cached = sh.getString('name') ?? '';

      if (cached.isNotEmpty && mounted) {
        setState(() {
          _name = cached;
        });
      }

      final res = await http.post(
        Uri.parse('$baseUrl/teammemberviewprofile_post/'),
        body: {'lid': lid},
      ).timeout(const Duration(seconds: 15));

      debugPrint('PROFILE status=${res.statusCode} body=${res.body}');

      final data = jsonDecode(res.body);

      if (data['status'] == 'ok') {
        await sh.setString('name', (data['name'] ?? '').toString());

        if (!mounted) return;

        setState(() {
          _name = (data['name'] ?? '').toString();

          final p = (data['photo'] ?? '').toString();
          _photoUrl = p.isEmpty ? null : p;
        });
      }
    } catch (e) {
      debugPrint('PROFILE ERROR: $e');
    }
  }

  // =====================================================
  // MENU ITEMS
  // =====================================================

  late final _MenuItem _work = _MenuItem(
    Icons.work_rounded,
    'My Work',
    'See the tasks assigned to you and update their status',
        (context) => viewwork(),
  );

  late final List<_MenuItem> _items = [
    _MenuItem(
      Icons.person_rounded,
      'Profile',
      'View your details',
          (context) => viewprofile(),
    ),
    _MenuItem(
      Icons.lock_rounded,
      'Change Password',
      'Keep your account safe',
          (context) => changepassword(),
    ),
    _MenuItem(
      Icons.groups_rounded,
      'My Leaders',
      'Your team leaders',
          (context) => viewteamleader(),
    ),
    _MenuItem(
      Icons.feedback_rounded,
      'Feedback',
      'See feedback for you',
          (context) => viewfeedback(),
    ),
  ];

  // =====================================================
  // GREETING
  // =====================================================

  String get _greeting {
    final h = DateTime.now().hour;

    if (h < 12) {
      return 'Good Morning';
    } else if (h < 17) {
      return 'Good Afternoon';
    }

    return 'Good Evening';
  }

  // =====================================================
  // OPEN PAGE
  // =====================================================

  Future<void> _open(_MenuItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: item.page),
    );

    if (mounted) {
      _loadProfile();
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    SharedPreferences sh = await SharedPreferences.getInstance();

    await sh.remove('lid');
    await sh.remove('name');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => loginpage()),
          (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Log out?',
          style: TextStyle(
            color: HomeColors.title,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'You will need to sign in again to continue.',
          style: TextStyle(color: HomeColors.subtitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeColors.coral,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await logout();
    }
  }

  // =====================================================
  // PROFILE PHOTO
  // =====================================================

  Widget _photoOrIcon(IconData fallback, double iconSize) {
    final icon = Icon(fallback, color: Colors.white, size: iconSize);

    if (_photoUrl == null) {
      return icon;
    }

    return Image.network(
      _photoUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => icon,
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 900 ? 4 : 2;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: HomeColors.bg,
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- WELLBEING (EMOTION + THERMAL) ----------
                      _WellbeingSection(
                        emotion: _lastEmotion,
                        emotionScore: _lastEmotionScore,
                        emotionActive: _emotionMonitoring,
                        emotionAt: _lastEmotionAt,
                        thermalStatus: _thermalStatus,
                        thermalScore: _thermalScore,
                        thermalActive: _thermalMonitoring,
                        thermalAt: _thermalLastChecked,
                      ),

                      const SizedBox(height: 26),

                      const Text(
                        'Quick Access',
                        style: TextStyle(
                          color: HomeColors.title,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'serif',
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ---------- WORK ----------
                      _FeaturedCard(
                        item: _work,
                        onTap: () => _open(_work),
                      ),

                      const SizedBox(height: 16),

                      // ---------- GRID ----------
                      GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.05,
                        children: _items
                            .map(
                              (item) => _MenuCard(
                            item: item,
                            onTap: () => _open(item),
                          ),
                        )
                            .toList(),
                      ),

                      const SizedBox(height: 24),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 13,
                            color: Color(0xFF9A8FB0),
                          ),
                          SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'Your data is encrypted and private',
                              style: TextStyle(
                                color: Color(0xFF9A8FB0),
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [
            HomeColors.gradA,
            HomeColors.gradB,
            HomeColors.gradC,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: HomeColors.cardShadow,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderButton(
                    icon: Icons.menu_rounded,
                    tooltip: 'Menu',
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Calmora',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.logout_rounded,
                    tooltip: 'Log out',
                    onTap: _confirmLogout,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromRGBO(255, 255, 255, 0.16),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.28),
                        width: 1.5,
                      ),
                    ),
                    child: _photoOrIcon(Icons.person_rounded, 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: const TextStyle(
                            color: HomeColors.leftText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Manage your work, feedback and profile in one place.',
                style: TextStyle(
                  color: HomeColors.leftText,
                  fontSize: 14.5,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DRAWER
  // =====================================================

  Widget _buildDrawer() {
    void go(_MenuItem item) {
      Navigator.pop(context);
      _open(item);
    }

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              22,
              MediaQuery.of(context).padding.top + 28,
              22,
              26,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.5, -1),
                end: Alignment(0.5, 1),
                colors: [
                  HomeColors.gradA,
                  HomeColors.gradB,
                  HomeColors.gradC,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 255, 255, 0.24),
                    ),
                  ),
                  child: _photoOrIcon(Icons.monitor_heart_outlined, 28),
                ),
                const SizedBox(height: 16),
                Text(
                  _name.isEmpty ? 'Workplace Wellbeing' : _name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Team member',
                  style: TextStyle(
                    color: HomeColors.leftText,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
              children: [
                _DrawerTile(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: () => go(_items[0]),
                ),
                _DrawerTile(
                  icon: Icons.lock_rounded,
                  label: 'Change Password',
                  onTap: () => go(_items[1]),
                ),
                _DrawerTile(
                  icon: Icons.groups_rounded,
                  label: 'View My Leaders',
                  onTap: () => go(_items[2]),
                ),
                _DrawerTile(
                  icon: Icons.feedback_rounded,
                  label: 'View Feedback',
                  onTap: () => go(_items[3]),
                ),
                _DrawerTile(
                  icon: Icons.work_rounded,
                  label: 'View Work',
                  onTap: () => go(_work),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Divider(color: HomeColors.border, height: 1),
                ),
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  danger: true,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLogout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// WELLBEING SECTION (EMOTION + THERMAL) — V3 "AURORA"
// =====================================================

String _fmtTime(DateTime? v) {
  if (v == null) return 'Waiting…';
  final h = v.hour % 12 == 0 ? 12 : v.hour % 12;
  final m = v.minute.toString().padLeft(2, '0');
  return '$h:$m ${v.hour >= 12 ? 'PM' : 'AM'}';
}

// ---------- mood helpers ----------

List<Color> _moodColors(String emotion, bool active) {
  if (!active) return const [Color(0xFF9A8FB0), Color(0xFF5E5473)];
  final e = emotion.toLowerCase();
  if (e.contains('happy') || e.contains('joy')) {
    return const [Color(0xFFFFB347), Color(0xFFFF5E87)];
  }
  if (e.contains('sad')) return const [Color(0xFF4FACFE), Color(0xFF5B4BDB)];
  if (e.contains('angry') || e.contains('anger')) {
    return const [Color(0xFFFF6B3D), Color(0xFFD1206F)];
  }
  if (e.contains('fear')) return const [Color(0xFF9B6BFF), Color(0xFF3B2A8F)];
  if (e.contains('surprise')) {
    return const [Color(0xFF36D1DC), Color(0xFF5B86E5)];
  }
  if (e.contains('disgust')) {
    return const [Color(0xFF56C596), Color(0xFF1D7A5F)];
  }
  return const [Color(0xFF9B6BFF), Color(0xFF5B3FD0)];
}

String _moodEmoji(String emotion) {
  final e = emotion.toLowerCase();
  if (e.contains('happy') || e.contains('joy')) return '😄';
  if (e.contains('sad')) return '😢';
  if (e.contains('angry') || e.contains('anger')) return '😠';
  if (e.contains('fear')) return '😨';
  if (e.contains('surprise')) return '😮';
  if (e.contains('disgust')) return '🤢';
  if (e.contains('neutral')) return '😌';
  if (e.contains('face')) return '🙈';
  return '🔍';
}

String _moodLine(String emotion) {
  final e = emotion.toLowerCase();
  if (e.contains('happy') || e.contains('joy')) return 'Great vibes today!';
  if (e.contains('sad')) return "Hang in there — it's okay";
  if (e.contains('angry') || e.contains('anger')) {
    return 'Take a moment to breathe';
  }
  if (e.contains('fear')) return "You're safe, take it slow";
  if (e.contains('surprise')) return 'Something caught your eye!';
  if (e.contains('disgust')) return 'Not a fan of something?';
  if (e.contains('neutral')) return 'Calm and steady';
  if (e.contains('face')) return 'Look at the camera 👀';
  return 'Reading your mood…';
}

const Color _stressGreen = Color(0xFF3DDBA7);
const Color _stressAmber = Color(0xFFFFC857);
const Color _stressPink = Color(0xFFFF5C8A);

Color _stressColor(double t) {
  if (t < 0.5) return Color.lerp(_stressGreen, _stressAmber, t * 2)!;
  return Color.lerp(_stressAmber, _stressPink, (t - 0.5) * 2)!;
}

// ---------- section ----------

class _WellbeingSection extends StatelessWidget {
  final String emotion;
  final double? emotionScore;
  final bool emotionActive;
  final DateTime? emotionAt;

  final String thermalStatus;
  final double? thermalScore;
  final bool thermalActive;
  final DateTime? thermalAt;

  const _WellbeingSection({
    required this.emotion,
    required this.emotionScore,
    required this.emotionActive,
    required this.emotionAt,
    required this.thermalStatus,
    required this.thermalScore,
    required this.thermalActive,
    required this.thermalAt,
  });

  @override
  Widget build(BuildContext context) {
    final live = emotionActive || thermalActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How You’re Doing',
                    style: TextStyle(
                      color: HomeColors.title,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'serif',
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Refreshes every 10 seconds',
                    style: TextStyle(
                      color: HomeColors.subtitle,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: live ? const Color(0xFFE5F8F0) : const Color(0xFFEEEAF4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulseDot(
                    color: live ? const Color(0xFF2FB38A) : Colors.grey,
                    active: live,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    live ? 'LIVE' : 'OFF',
                    style: TextStyle(
                      color: live ? const Color(0xFF1E8F6B) : Colors.grey,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AuraCard(
          emotion: emotion,
          emotionScore: emotionScore,
          emotionActive: emotionActive,
          emotionAt: emotionAt,
          thermalStatus: thermalStatus,
          thermalScore: thermalScore,
          thermalActive: thermalActive,
          thermalAt: thermalAt,
        ),
      ],
    );
  }
}

// =====================================================
// AURA CARD — one glowing card, emotion + stress
// =====================================================

class _AuraCard extends StatefulWidget {
  final String emotion;
  final double? emotionScore;
  final bool emotionActive;
  final DateTime? emotionAt;

  final String thermalStatus;
  final double? thermalScore;
  final bool thermalActive;
  final DateTime? thermalAt;

  const _AuraCard({
    required this.emotion,
    required this.emotionScore,
    required this.emotionActive,
    required this.emotionAt,
    required this.thermalStatus,
    required this.thermalScore,
    required this.thermalActive,
    required this.thermalAt,
  });

  @override
  State<_AuraCard> createState() => _AuraCardState();
}

class _AuraCardState extends State<_AuraCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // ---------------- EMOTION PANE ----------------

  Widget _emotionPane(List<Color> colors) {
    final w = widget;
    final pct = w.emotionScore == null ? 0.0 : w.emotionScore!.clamp(0.0, 1.0);
    final emoji = w.emotionActive ? _moodEmoji(w.emotion) : '😴';
    final pill =
    w.emotionScore == null ? '…' : '${(w.emotionScore! * 100).round()}%';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _GlassChip(
                icon: Icons.auto_awesome_rounded,
                text: 'FEELING',
              ),
              const SizedBox(height: 14),
              Text(
                w.emotionActive ? w.emotion : 'Unavailable',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'serif',
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                w.emotionActive ? _moodLine(w.emotion) : 'Camera is off',
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.82),
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 13, color: Color.fromRGBO(255, 255, 255, 0.65)),
                  const SizedBox(width: 5),
                  Text(
                    _fmtTime(w.emotionAt),
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _Orb(
          anim: _c,
          emoji: emoji,
          value: pct,
          label: pill,
          accent: colors.last,
        ),
      ],
    );
  }

  // ---------------- THERMAL PANE ----------------

  Widget _thermalPane() {
    final w = widget;
    final s = w.thermalStatus.toLowerCase();
    final isStress = s.contains('stress') && !s.contains('non');
    final isCalm =
        s.contains('non') || s.contains('normal') || s.contains('calm');
    final active = w.thermalActive;

    // 0 = calm .. 1 = stressed
    double level = 0.5;
    if (!active) {
      level = 0;
    } else if (w.thermalScore != null) {
      final p = w.thermalScore!.clamp(0.0, 1.0);
      if (isStress) {
        level = p;
      } else if (isCalm) {
        level = 1 - p;
      }
    }

    final Color accent = !active
        ? Colors.grey
        : isStress
        ? _stressPink
        : (isCalm ? _stressGreen : const Color(0xFFB69CFF));

    final chipText = isStress ? 'Stressed' : (isCalm ? 'Calm' : 'Checking');
    final tip = !active
        ? 'Monitoring is off right now.'
        : isStress
        ? 'Pause, breathe in slowly and stretch for a minute 🌿'
        : (isCalm
        ? "You're relaxed — keep it up ✨"
        : 'Reading your thermal signals…');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _GlassChip(
              icon: Icons.thermostat_rounded,
              text: 'STRESS LEVEL',
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: accent.withOpacity(0.55)),
              ),
              child: Text(
                w.thermalScore == null
                    ? chipText
                    : '$chipText • ${(w.thermalScore! * 100).round()}%',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          active ? w.thermalStatus : 'Unavailable',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontFamily: 'serif',
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        _SignalBars(anim: _c, level: level),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CALM',
              style: TextStyle(
                color: _stressGreen,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'STRESS',
              style: TextStyle(
                color: _stressPink,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
            ),
          ),
          child: Text(
            tip,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.9),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.schedule_rounded,
                size: 13, color: Color.fromRGBO(255, 255, 255, 0.65)),
            const SizedBox(width: 5),
            Text(
              _fmtTime(w.thermalAt),
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final colors = _moodColors(widget.emotion, widget.emotionActive);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.38),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B1038),
                      Color(0xFF2A1560),
                      Color(0xFF140B2E),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _Aurora(
                anim: _c,
                a: colors.first,
                b: colors.last,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.12),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 640;

                  if (wide) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _emotionPane(colors)),
                          Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 22),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(255, 255, 255, 0),
                                  Color.fromRGBO(255, 255, 255, 0.3),
                                  Color.fromRGBO(255, 255, 255, 0),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: _thermalPane()),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      _emotionPane(colors),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(255, 255, 255, 0),
                              Color.fromRGBO(255, 255, 255, 0.3),
                              Color.fromRGBO(255, 255, 255, 0),
                            ],
                          ),
                        ),
                      ),
                      _thermalPane(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// AURORA BACKGROUND (moving, mood-coloured glow)
// =====================================================

class _Aurora extends StatelessWidget {
  final Animation<double> anim;
  final Color a;
  final Color b;

  const _Aurora({required this.anim, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: a),
      duration: const Duration(milliseconds: 900),
      builder: (_, ca, __) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: b),
        duration: const Duration(milliseconds: 900),
        builder: (_, cb, __) => CustomPaint(
          size: Size.infinite,
          painter: _AuroraPainter(anim, ca ?? a, cb ?? b),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final Animation<double> anim;
  final Color a;
  final Color b;

  _AuroraPainter(this.anim, this.a, this.b) : super(repaint: anim);

  void _blob(Canvas canvas, Offset center, double r, Color color, double o) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(o), color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * 2 * math.pi;
    final r = math.max(size.width, size.height) * 0.62;

    _blob(
      canvas,
      Offset(size.width * (0.15 + 0.12 * math.sin(t)),
          size.height * (0.15 + 0.1 * math.cos(t))),
      r,
      a,
      0.55,
    );
    _blob(
      canvas,
      Offset(size.width * (0.88 + 0.08 * math.cos(t + 1.2)),
          size.height * (0.85 + 0.08 * math.sin(t + 2.0))),
      r,
      b,
      0.5,
    );
    _blob(
      canvas,
      Offset(size.width * (0.55 + 0.2 * math.sin(t + 3.0)),
          size.height * (0.5 + 0.15 * math.cos(t + 0.5))),
      r * 0.45,
      Colors.white,
      0.07,
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.a != a || old.b != b;
}

// =====================================================
// ORB — breathing emoji with confidence ring
// =====================================================

class _Orb extends StatelessWidget {
  final Animation<double> anim;
  final String emoji;
  final double value; // 0..1
  final String label;
  final Color accent;

  const _Orb({
    required this.anim,
    required this.emoji,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 138,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 124,
            height: 124,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // slowly rotating dotted ring
                AnimatedBuilder(
                  animation: anim,
                  builder: (_, __) => Transform.rotate(
                    angle: anim.value * 2 * math.pi,
                    child: const CustomPaint(
                      size: Size(124, 124),
                      painter: _DotRingPainter(),
                    ),
                  ),
                ),
                // confidence arc
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CustomPaint(
                    size: const Size(124, 124),
                    painter: _RingPainter(
                      value: v,
                      color: Colors.white,
                      track: const Color.fromRGBO(255, 255, 255, 0.14),
                    ),
                  ),
                ),
                // breathing glow disc
                AnimatedBuilder(
                  animation: anim,
                  builder: (_, child) {
                    final s = 1 + 0.05 * math.sin(anim.value * 2 * math.pi * 3);
                    return Transform.scale(scale: s, child: child);
                  },
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color.fromRGBO(255, 255, 255, 0.4),
                          Color.fromRGBO(255, 255, 255, 0.08),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.65),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, a) => ScaleTransition(
                    scale: a,
                    child: FadeTransition(opacity: a, child: child),
                  ),
                  child: Text(
                    emoji,
                    key: ValueKey(emoji),
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.18),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SIGNAL BARS — equalizer-style stress meter
// =====================================================

class _SignalBars extends StatelessWidget {
  final Animation<double> anim;
  final double level; // 0 calm .. 1 stress

  const _SignalBars({required this.anim, required this.level});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: level),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => AnimatedBuilder(
        animation: anim,
        builder: (_, __) {
          const n = 28;
          return SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(n, (i) {
                final frac = (i + 1) / n;
                final lit = v > 0.01 && frac <= v + 0.001;
                final base = 16 + 30 * frac;
                final bob = lit
                    ? 5 * math.sin(anim.value * 2 * math.pi * 5 + i * 0.55)
                    : 0.0;
                final col = _stressColor(frac);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.3),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: base + bob,
                        decoration: BoxDecoration(
                          color: lit
                              ? col
                              : const Color.fromRGBO(255, 255, 255, 0.12),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: lit
                              ? [
                            BoxShadow(
                              color: col.withOpacity(0.45),
                              blurRadius: 8,
                            ),
                          ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// PAINTERS
// =====================================================

class _RingPainter extends CustomPainter {
  final double value; // 0..1
  final Color color;
  final Color track;

  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - stroke - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    if (value <= 0.005) return;

    // soft glow
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 4
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

class _DotRingPainter extends CustomPainter {
  const _DotRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const count = 44;

    for (int i = 0; i < count; i++) {
      final a = 2 * math.pi * i / count;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius;
      canvas.drawCircle(
        p,
        i % 4 == 0 ? 2.0 : 1.2,
        Paint()
          ..color = Colors.white.withOpacity(i % 4 == 0 ? 0.7 : 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DotRingPainter old) => false;
}

// =====================================================
// SMALL REUSABLE PIECES
// =====================================================

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PULSING LIVE DOT
// =====================================================

class _PulseDot extends StatefulWidget {
  final Color color;
  final bool active;

  const _PulseDot({required this.color, required this.active});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.active)
                Container(
                  width: 8 + 10 * _ctrl.value,
                  height: 8 + 10 * _ctrl.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.4 * (1 - _ctrl.value)),
                  ),
                ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =====================================================
// HEADER BUTTON
// =====================================================

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

// =====================================================
// FEATURED WORK CARD
// =====================================================

class _FeaturedCard extends StatefulWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
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
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1, -0.09),
            end: Alignment(1, 0.09),
            colors: [HomeColors.gradA, HomeColors.btnB],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: HomeColors.btnShadow,
              blurRadius: _hovered ? 32 : 26,
              offset: Offset(0, _hovered ? 18 : 14),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.18),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.25),
                      ),
                    ),
                    child: Icon(widget.item.icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.subtitle,
                          style: const TextStyle(
                            color: HomeColors.leftText,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
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

// =====================================================
// MENU CARD
// =====================================================

class _MenuCard extends StatefulWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _MenuCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? HomeColors.borderHover : HomeColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: HomeColors.softShadow,
              blurRadius: _hovered ? 30 : 18,
              offset: Offset(0, _hovered ? 16 : 8),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: HomeColors.badgeBg,
                    ),
                    child: Icon(
                      widget.item.icon,
                      size: 24,
                      color: HomeColors.accent,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: HomeColors.ink,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: HomeColors.subtitle,
                      fontSize: 12.5,
                      height: 1.35,
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

// =====================================================
// DRAWER TILE
// =====================================================

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? HomeColors.coral : HomeColors.accent;
    final textColor = danger ? HomeColors.coral : HomeColors.ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        hoverColor:
        danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
        splashColor:
        danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFCE7EF) : HomeColors.badgeBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: danger
            ? null
            : const Icon(
          Icons.chevron_right_rounded,
          color: HomeColors.borderHover,
        ),
      ),
    );
  }
}