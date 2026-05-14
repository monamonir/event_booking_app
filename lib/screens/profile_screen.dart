import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  String? _imagePath;
  int _bookingCount = 0;
  final _authService = AuthService();

  // Keep the tab alive so the user doesn't lose scroll position,
  // but we still refresh the booking count every time the tab is focused.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Called when the widget is updated; tab switches recreate this screen
  // (see MainScreen body), so booking count refreshes when returning to Profile.
  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _loadData() async {
    final uid = _uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    // Use a per-user key so different users don't share the same photo
    final path = prefs.getString('profile_image_path_$uid');
    // Pass uid so we only count this user's bookings
    final bookings = await BookingService.getBookings(uid);

    if (mounted) {
      setState(() {
        _imagePath = path;
        _bookingCount = bookings.length;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final uid = _uid;
    if (uid == null) return;
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        final prefs = await SharedPreferences.getInstance();
        // Store image path under a per-user key
        await prefs.setString('profile_image_path_$uid', picked.path);
        if (mounted) setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      if (!mounted) return;
      if (source == ImageSource.camera) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Camera unavailable ($e). You can pick from the gallery instead.',
            ),
            action: SnackBarAction(
              label: 'Gallery',
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _showImagePicker() {
    final uid = _uid;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Change Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFF6C63FF)),
              ),
              title: const Text('Take a Photo'),
              subtitle: const Text('Use your camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: Colors.orange),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Pick an existing photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.grey),
                ),
                title: const Text('Remove Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  if (uid != null) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('profile_image_path_$uid');
                    if (mounted) setState(() => _imagePath = null);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final user = _authService.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        // Refresh button so the user can manually reload if needed
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6C63FF)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF6C63FF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          const Color(0xFF6C63FF).withOpacity(0.15),
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : null,
                      child: _imagePath == null
                          ? Text(initial,
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C63FF)))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePicker,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),

              // Stats card — booking count now reflects current user only
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        count: _bookingCount.toString(), label: 'Bookings'),
                    Container(
                        height: 40, width: 1, color: Colors.grey.shade200),
                    const _StatItem(count: '0', label: 'Upcoming'),
                    Container(
                        height: 40, width: 1, color: Colors.grey.shade200),
                    const _StatItem(count: '0', label: 'Attended'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Info card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(height: 20),
                    _InfoRow(
                        icon: Icons.person_outline, label: 'Name', value: name),
                    const Divider(height: 16),
                    _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.camera_alt_outlined,
                      label: 'Change Profile Photo',
                      iconColor: const Color(0xFF6C63FF),
                      onTap: _showImagePicker,
                    ),
                    const Divider(height: 1, indent: 54),
                    _ActionTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      iconColor: Colors.orange,
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 54),
                    _ActionTile(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      iconColor: Colors.green,
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 54),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: _signOut,
                      showArrow: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('CBSD Project 2026 · v1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback onTap;
  final bool showArrow;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.textColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor ?? const Color(0xFF1A1A2E))),
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Colors.grey)
          : null,
    );
  }
}
