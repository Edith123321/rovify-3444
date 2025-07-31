// import 'package:flutter/material.dart';
// import 'package:rovify/presentation/common/common_appbar.dart';
// import 'package:rovify/presentation/common/custom_bottom_navbar.dart';

// class ResponsiveScaffold extends StatelessWidget {
//   final Widget body;
//   final int selectedIndex;
//   final Function(int) onNavTap;
//   final String location;
//   final String? userProfileUrl;
//   final VoidCallback onNotificationTap;
//   final VoidCallback onProfileTap;

//   const ResponsiveScaffold({
//     super.key,
//     required this.body,
//     required this.selectedIndex,
//     required this.onNavTap,
//     required this.location,
//     required this.userProfileUrl,
//     required this.onNotificationTap,
//     required this.onProfileTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(
//         location: location,
//         userProfileUrl: userProfileUrl,
//         onNotificationTap: onNotificationTap,
//         onProfileTap: onProfileTap,
//       ),
//       body: body,
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: selectedIndex,
//         onTap: onNavTap,
//       ),
//     );
//   }
// }