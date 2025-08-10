import 'package:authentication_and_notification/screens/login_page.dart';
import 'package:authentication_and_notification/screens/profile_page.dart';
import 'package:authentication_and_notification/services/auth_service.dart';
import 'package:authentication_and_notification/services/notification_service.dart';
import 'package:authentication_and_notification/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    try {
      final token = await NotificationService().getToken();
      if (mounted) {
        setState(() {
          _fcmToken = token;
        });
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await NotificationService().sendTestNotification();
      if (mounted) {
        Utils.showSnackBar(context, 'Test notification sent!');
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context,
          'Failed to send notification: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Profile button
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          // Sign Out button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              try {
                await AuthService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Utils.showSnackBar(context, 'Sign out failed', isError: true);
                }
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                'No user information available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.displayName?.split(' ').first ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You are successfully authenticated!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.displayName ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'No Email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Basic Information Section
                  _buildSectionTitle('Basic Information'),
                  _buildInfoCard([
                    _buildInfoRow(
                      Icons.person,
                      'Display Name',
                      user.displayName,
                    ),
                    _buildInfoRow(Icons.email, 'Email', user.email),
                    _buildInfoRow(
                      Icons.phone,
                      'Phone Number',
                      user.phoneNumber,
                    ),
                    _buildInfoRow(
                      Icons.verified_user,
                      'Email Verified',
                      user.emailVerified ? 'Yes' : 'No',
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Account Details Section
                  _buildSectionTitle('Account Details'),
                  _buildInfoCard([
                    _buildInfoRow(Icons.fingerprint, 'User ID', user.uid),
                    _buildInfoRow(
                      Icons.account_circle,
                      'Is Anonymous',
                      user.isAnonymous ? 'Yes' : 'No',
                    ),
                    _buildInfoRow(Icons.business, 'Tenant ID', user.tenantId),
                  ]),

                  const SizedBox(height: 20),

                  // Provider Information Section
                  _buildSectionTitle('Provider Information'),
                  _buildInfoCard([
                    if (user.providerData.isNotEmpty) ...[
                      _buildInfoRow(
                        Icons.login,
                        'Provider ID',
                        user.providerData.first.providerId,
                      ),
                      _buildInfoRow(
                        Icons.business_center,
                        'Provider Name',
                        user.providerData.first.displayName,
                      ),
                    ],
                  ]),

                  const SizedBox(height: 20),

                  // Activity Information Section
                  _buildSectionTitle('Activity Information'),
                  _buildInfoCard([
                    _buildInfoRow(
                      Icons.access_time,
                      'Account Created',
                      _formatDateTime(user.metadata.creationTime),
                    ),
                    _buildInfoRow(
                      Icons.login,
                      'Last Sign In',
                      _formatDateTime(user.metadata.lastSignInTime),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Push Notification Section
                  _buildSectionTitle('Push Notifications'),
                  _buildInfoCard([
                    _buildInfoRow(
                      Icons.notifications,
                      'FCM Token',
                      _fcmToken,
                      isToken: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _sendTestNotification,
                          icon: const Icon(Icons.send),
                          label: const Text('Send Test Notification'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Additional Information Section
                  _buildSectionTitle('Additional Information'),

                  _buildInfoCard([
                    if (user.photoURL != null)
                      _buildInfoRow(
                        Icons.photo,
                        'Photo URL',
                        user.photoURL,
                        isUrl: true,
                      ),

                    _buildInfoRow(
                      Icons.token,
                      'Refresh Token',
                      user.refreshToken,
                      isToken: true,
                    ),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String? value, {
    bool isUrl = false,
    bool isToken = false,
  }) {
    String displayValue = value ?? 'N/A';

    // Truncate long values for better display
    if (isToken && displayValue.length > 20) {
      displayValue = '${displayValue.substring(0, 20)}...';
    } else if (isUrl && displayValue.length > 30) {
      displayValue = '${displayValue.substring(0, 30)}...';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String? _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
