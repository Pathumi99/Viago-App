import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  bool _pushNotifications = true;
  bool _rideUpdates = true;
  bool _rideRequests = true;
  bool _promotions = false;
  bool _systemAlerts = true;
  bool _emailNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_notification_settings')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _pushNotifications = data['pushNotifications'] ?? true;
          _rideUpdates = data['rideUpdates'] ?? true;
          _rideRequests = data['rideRequests'] ?? true;
          _promotions = data['promotions'] ?? false;
          _systemAlerts = data['systemAlerts'] ?? true;
          _emailNotifications = data['emailNotifications'] ?? false;
          _soundEnabled = data['soundEnabled'] ?? true;
          _vibrationEnabled = data['vibrationEnabled'] ?? true;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationSettings() async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('user_notification_settings')
          .doc(user!.uid)
          .set({
        'pushNotifications': _pushNotifications,
        'rideUpdates': _rideUpdates,
        'rideRequests': _rideRequests,
        'promotions': _promotions,
        'systemAlerts': _systemAlerts,
        'emailNotifications': _emailNotifications,
        'soundEnabled': _soundEnabled,
        'vibrationEnabled': _vibrationEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved successfully! ✅'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to delete all your notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final notifications = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user!.uid)
            .get();

        for (var doc in notifications.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared successfully! 🗑️'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear notifications: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saveNotificationSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Notification Preferences',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your notification experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // General Settings
                  _buildSectionHeader('General Settings'),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive notifications on this device',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.email_outlined,
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Ride Notifications
                  _buildSectionHeader('Ride Notifications'),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.directions_car_outlined,
                    title: 'Ride Updates',
                    subtitle: 'Status changes for your rides',
                    value: _rideUpdates,
                    onChanged: (value) {
                      setState(() {
                        _rideUpdates = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.person_add_outlined,
                    title: 'Ride Requests',
                    subtitle: 'New ride requests from passengers',
                    value: _rideRequests,
                    onChanged: (value) {
                      setState(() {
                        _rideRequests = value;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // App Notifications
                  _buildSectionHeader('App Notifications'),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.local_offer_outlined,
                    title: 'Promotions & Offers',
                    subtitle: 'Special deals and discounts',
                    value: _promotions,
                    onChanged: (value) {
                      setState(() {
                        _promotions = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.info_outline,
                    title: 'System Alerts',
                    subtitle: 'Important app updates and announcements',
                    value: _systemAlerts,
                    onChanged: (value) {
                      setState(() {
                        _systemAlerts = value;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Sound & Vibration
                  _buildSectionHeader('Sound & Vibration'),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.volume_up_outlined,
                    title: 'Sound',
                    subtitle: 'Play sound for notifications',
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.vibration_outlined,
                    title: 'Vibration',
                    subtitle: 'Vibrate for notifications',
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildSectionHeader('Actions'),
                  const SizedBox(height: 16),

                  // Clear All Notifications Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Clear All Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      subtitle: const Text(
                        'Delete all your existing notifications',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: _clearAllNotifications,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2563EB),
          activeTrackColor: const Color(0xFF2563EB).withOpacity(0.3),
        ),
      ),
    );
  }
}
