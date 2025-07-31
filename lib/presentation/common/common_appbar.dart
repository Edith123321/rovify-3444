import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? location;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final double height;
  final EdgeInsetsGeometry contentPadding;

  const CommonAppBar({
    super.key,
    this.location,
    this.onNotificationTap,
    this.onProfileTap,
    this.height = 76,
    this.contentPadding = const EdgeInsets.fromLTRB(26, 12, 26, 12),
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      developer.log('Error fetching user data: $e', name: 'CommonAppBar');
      return null;
    }
  }

  Future<String> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return 'Location unavailable';
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final city = placemark.locality ?? placemark.administrativeArea ?? 'Unknown City';
        final country = placemark.country ?? 'Unknown Country';
        return '$city, $country';
      }

      return 'Location unavailable';
    } catch (e) {
      developer.log('Error getting location: $e', name: 'CommonAppBar');
      return 'Location unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final dynamicHeight = isLandscape ? 64.0 : height;
    final dynamicPadding = isLandscape
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : contentPadding;

    return AppBar(
      toolbarHeight: dynamicHeight,
      backgroundColor: const Color(0xFFF5F5F5),
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: dynamicPadding,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            final avatarUrl = snapshot.data?['avatarUrl'] as String?;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onProfileTap ?? () => Scaffold.of(context).openDrawer(),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _getAvatarProvider(avatarUrl),
                    child: _buildProfileFallback(avatarUrl, snapshot),
                  ),
                ),
                _buildLocationSection(),
                IconButton(
                  onPressed: onNotificationTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications coming soon!')),
                        );
                      },
                  icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return FutureBuilder<String>(
      future: location != null ? Future.value(location!) : _getUserLocation(),
      builder: (context, snapshot) {
        final displayLocation = snapshot.data ?? 'Loading location...';
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Location',
              style: TextStyle(fontSize: 14, color: Color(0xFF8D8D8D), fontFamily: 'Onest'),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                else
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  displayLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'Onest',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  ImageProvider? _getAvatarProvider(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }
    return null;
  }

  Widget? _buildProfileFallback(String? avatarUrl, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const Icon(Icons.person, color: Colors.grey, size: 18);
    }

    return null;
  }
}