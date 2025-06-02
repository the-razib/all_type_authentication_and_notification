import 'package:authentication_and_notification/screens/login_page.dart';
import 'package:authentication_and_notification/services/auth_service.dart';
import 'package:authentication_and_notification/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = AuthService.currentUser;
  bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.signOut();
      if (context.mounted) {
        Utils.showSnackBar(context, 'Signed out successfully');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Utils.showSnackBar(context, 'Sign out failed', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? 'Not provided' : value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                'No user information available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : LoadingOverlay(
              isLoading: _isLoading,
              message: 'Signing out...',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Profile Picture
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user!.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: user!.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.deepPurple.shade300,
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    // Display Name
                    Text(
                      user!.displayName ?? 'Anonymous User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Email verification status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: user!.emailVerified
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user!.emailVerified
                                ? Icons.verified
                                : Icons.warning,
                            size: 16,
                            color: user!.emailVerified
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user!.emailVerified ? 'Verified' : 'Unverified',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: user!.emailVerified
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // User Information Cards
                    _buildInfoCard('Email', user!.email ?? '', Icons.email),
                    _buildInfoCard(
                      'Phone',
                      user!.phoneNumber ?? '',
                      Icons.phone,
                    ),
                    _buildInfoCard('User ID', user!.uid, Icons.fingerprint),
                    _buildInfoCard(
                      'Account Created',
                      user!.metadata.creationTime?.toString().split(' ')[0] ??
                          '',
                      Icons.calendar_today,
                    ),
                    _buildInfoCard(
                      'Last Sign In',
                      user!.metadata.lastSignInTime?.toString().split(' ')[0] ??
                          '',
                      Icons.access_time,
                    ),
                    const SizedBox(height: 30),
                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
