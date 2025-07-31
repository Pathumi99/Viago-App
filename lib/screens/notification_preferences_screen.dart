import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // Notification Settings
  bool _pushNotifications = true;
  bool _rideUpdates = true;
  bool _rideRequests = true;
  bool _promotions = false;
  bool _systemAlerts = true;
  bool _emailNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Do Not Disturb Settings
  bool _doNotDisturbEnabled = false;
  TimeOfDay _doNotDisturbStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _doNotDisturbEnd = const TimeOfDay(hour: 7, minute: 0);

  // Advanced Settings
  bool _showPreview = true;
  bool _groupSimilar = true;
  String _notificationPriority = 'high';

  bool _isLoading = true;
  bool _isSaving = false;

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
          _doNotDisturbEnabled = data['doNotDisturbEnabled'] ?? false;
          _showPreview = data['showPreview'] ?? true;
          _groupSimilar = data['groupSimilar'] ?? true;
          _notificationPriority = data['notificationPriority'] ?? 'high';

          // Handle DND time settings
          if (data['doNotDisturbStart'] != null) {
            final startMap = data['doNotDisturbStart'] as Map<String, dynamic>;
            _doNotDisturbStart = TimeOfDay(
              hour: startMap['hour'] ?? 22,
              minute: startMap['minute'] ?? 0,
            );
          }
          if (data['doNotDisturbEnd'] != null) {
            final endMap = data['doNotDisturbEnd'] as Map<String, dynamic>;
            _doNotDisturbEnd = TimeOfDay(
              hour: endMap['hour'] ?? 7,
              minute: endMap['minute'] ?? 0,
            );
          }
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

    setState(() {
      _isSaving = true;
    });

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
        'doNotDisturbEnabled': _doNotDisturbEnabled,
        'doNotDisturbStart': {
          'hour': _doNotDisturbStart.hour,
          'minute': _doNotDisturbStart.minute,
        },
        'doNotDisturbEnd': {
          'hour': _doNotDisturbEnd.hour,
          'minute': _doNotDisturbEnd.minute,
        },
        'showPreview': _showPreview,
        'groupSimilar': _groupSimilar,
        'notificationPriority': _notificationPriority,
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
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text('Clear All Notifications'),
          ],
        ),
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

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _doNotDisturbStart : _doNotDisturbEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _doNotDisturbStart = picked;
        } else {
          _doNotDisturbEnd = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
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
                    'Customize how you receive notifications',
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

                  // Do Not Disturb
                  _buildSectionHeader('Do Not Disturb'),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.do_not_disturb_outlined,
                    title: 'Do Not Disturb',
                    subtitle: 'Silence notifications during specific hours',
                    value: _doNotDisturbEnabled,
                    onChanged: (value) {
                      setState(() {
                        _doNotDisturbEnabled = value;
                      });
                    },
                  ),

                  if (_doNotDisturbEnabled) ...[
                    const SizedBox(height: 16),
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(_doNotDisturbStart),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectTime(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Change'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'End Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(_doNotDisturbEnd),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectTime(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Change'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Advanced Settings
                  _buildSectionHeader('Advanced Settings'),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.preview_outlined,
                    title: 'Show Preview',
                    subtitle: 'Show notification content in previews',
                    value: _showPreview,
                    onChanged: (value) {
                      setState(() {
                        _showPreview = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.group_work_outlined,
                    title: 'Group Similar',
                    subtitle: 'Group notifications by type',
                    value: _groupSimilar,
                    onChanged: (value) {
                      setState(() {
                        _groupSimilar = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Priority Dropdown
                  Container(
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
                        child: const Icon(
                          Icons.priority_high_outlined,
                          color: Color(0xFF2563EB),
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Notification Priority',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      subtitle: const Text(
                        'Set notification importance level',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: _notificationPriority,
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                          DropdownMenuItem(
                              value: 'normal', child: Text('Normal')),
                          DropdownMenuItem(value: 'high', child: Text('High')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _notificationPriority = value;
                            });
                          }
                        },
                      ),
                    ),
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
