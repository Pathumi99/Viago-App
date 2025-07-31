import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';
import '../generated/app_localizations.dart';
import 'emergency_contacts_screen.dart';

class SafetyCenterScreen extends StatefulWidget {
  final String userType;

  const SafetyCenterScreen({super.key, this.userType = 'passenger'});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool _sosEnabled = false;
  bool _locationSharing = false;
  bool _safetyCheckins = false;

  @override
  void initState() {
    super.initState();
    _loadSafetySettings();
  }

  Future<void> _loadSafetySettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _sosEnabled = data['sosEnabled'] ?? false;
            _locationSharing = data['locationSharing'] ?? false;
            _safetyCheckins = data['safetyCheckins'] ?? false;
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _updateSafetySetting(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({field: value});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $field'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not make phone call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userType == 'rider' ? 'Driver Safety Center' : 'Safety Center',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
                Color(0xFF1E40AF),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            child: TabBar(
              controller: TabController(length: 4, vsync: this),
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              tabs: const [
                Tab(text: 'Safety Tips'),
                Tab(text: 'Emergency'),
                Tab(text: 'Settings'),
                Tab(text: 'Verification'),
              ],
              indicatorColor: themeProvider.accentColor,
              labelColor: themeProvider.accentColor,
              unselectedLabelColor: Colors.grey.shade600,
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildSafetyTipsTab(),
                _buildEmergencyTab(),
                _buildSettingsTab(),
                _buildVerificationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTipsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: Colors.blue.shade600, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      widget.userType == 'rider'
                          ? 'Drive Safe with ViaGo'
                          : 'Stay Safe with ViaGo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.userType == 'rider'
                      ? 'Your safety and your passengers\' safety are our priority. Follow these guidelines to ensure a secure ride-sharing experience for everyone.'
                      : 'Your safety is our priority. Follow these guidelines to ensure a secure ride-sharing experience.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Safety Categories
          if (widget.userType == 'rider') ...[
            ..._buildSafetyCategory(
              'Before Picking Up Passengers',
              Icons.event,
              Colors.green,
              [
                'Verify passenger identity and contact details',
                'Check passenger ratings and reviews',
                'Ensure your vehicle is clean and safe',
                'Check fuel, tire pressure, and vehicle condition',
                'Have emergency contacts readily accessible',
                'Plan the route and check traffic conditions',
              ],
            ),
            const SizedBox(height: 20),
            ..._buildSafetyCategory(
              'During the Ride',
              Icons.directions_car,
              Colors.orange,
              [
                'Stay alert and focused on driving',
                'Follow traffic rules and speed limits',
                'Use hands-free devices for calls',
                'Trust your instincts about passenger behavior',
                'Keep doors locked while driving',
                'Follow the planned GPS route',
              ],
            ),
            const SizedBox(height: 20),
            ..._buildSafetyCategory(
              'Passenger Management',
              Icons.people,
              Colors.blue,
              [
                'Limit passengers to booked number',
                'No alcohol or illegal substances in vehicle',
                'Address inappropriate behavior immediately',
                'Don\'t accept additional stops not agreed upon',
                'Maintain professional boundaries',
                'Report problematic passengers',
              ],
            ),
            const SizedBox(height: 20),
            ..._buildSafetyCategory(
              'Emergency Situations',
              Icons.emergency,
              Colors.red,
              [
                'Pull over safely in emergencies',
                'Call 119 for immediate assistance',
                'Contact ViaGo support immediately',
                'Document incidents with photos/notes',
                'Don\'t confront aggressive passengers',
                'Report all incidents to authorities',
              ],
            ),
          ] else ...[
            ..._buildSafetyCategory(
              'Before Your Ride',
              Icons.event,
              Colors.green,
              [
                'Verify rider identity and vehicle details',
                'Check rider ratings and reviews',
                'Share ride details with trusted contacts',
                'Ensure your phone is fully charged',
                'Have emergency contacts ready',
                'Choose well-lit pickup locations',
              ],
            ),
            const SizedBox(height: 20),
            ..._buildSafetyCategory(
              'During Your Ride',
              Icons.directions_car,
              Colors.orange,
              [
                'Sit in the back seat when riding alone',
                'Keep your phone accessible',
                'Trust your instincts - if something feels wrong, speak up',
                'Stay alert and avoid distractions',
                'Don\'t share personal information',
                'Follow the GPS route on your phone',
              ],
            ),
            const SizedBox(height: 20),
            ..._buildSafetyCategory(
              'Emergency Situations',
              Icons.emergency,
              Colors.red,
              [
                'Call 119 for immediate emergency assistance',
                'Ask to be let out in a safe, public location',
                'Contact ViaGo support immediately',
                'Report any safety incidents',
                'Trust your instincts - your safety comes first',
                'Keep calm and stay focused',
              ],
            ),
            const SizedBox(height: 20),
            ..._buildSafetyCategory(
              'After Your Ride',
              Icons.rate_review,
              Colors.purple,
              [
                'Rate your experience honestly',
                'Report any safety concerns',
                'Check that you haven\'t left anything behind',
                'Share feedback to help improve safety',
                'Keep ride receipts for records',
                'Thank your rider for a safe journey',
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSafetyCategory(
      String title, IconData icon, Color color, List<String> tips) {
    return [
      Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...tips
          .map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ))
          ,
    ];
  }

  Widget _buildEmergencyTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOS Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSOSDialog(),
                      borderRadius: BorderRadius.circular(60),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Emergency SOS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Press and hold for 3 seconds to send emergency alert',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Emergency Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  'Emergency\n119',
                  Icons.call,
                  Colors.red,
                  () => _makePhoneCall('119'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  'Police\n118',
                  Icons.local_police,
                  Colors.blue,
                  () => _makePhoneCall('118'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  'Support\n24/7',
                  Icons.support_agent,
                  Colors.green,
                  () => _makePhoneCall('+94112345678'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Emergency Contacts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.contact_emergency,
                        color: themeProvider.accentColor),
                    const SizedBox(width: 12),
                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Manage your emergency contacts who will be notified in case of an emergency.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergencyContactsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.manage_accounts),
                    label: const Text('Manage Contacts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Safety Settings
          _buildSettingCard(
            'SOS Emergency Alert',
            'Enable quick emergency alerts during rides',
            Icons.emergency,
            _sosEnabled,
            (value) {
              setState(() {
                _sosEnabled = value;
              });
              _updateSafetySetting('sosEnabled', value);
            },
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            'Location Sharing',
            'Share your live location with emergency contacts',
            Icons.location_on,
            _locationSharing,
            (value) {
              setState(() {
                _locationSharing = value;
              });
              _updateSafetySetting('locationSharing', value);
            },
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            'Safety Check-ins',
            'Receive safety check-ins during long rides',
            Icons.check_circle,
            _safetyCheckins,
            (value) {
              setState(() {
                _safetyCheckins = value;
              });
              _updateSafetySetting('safetyCheckins', value);
            },
          ),

          const SizedBox(height: 24),

          // Additional Safety Options
          Text(
            'Additional Safety Options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          _buildActionCard(
            widget.userType == 'rider'
                ? 'Report Passenger Incident'
                : 'Report Safety Incident',
            widget.userType == 'rider'
                ? 'Report problematic passenger behavior or safety concerns'
                : 'Report any safety concerns or incidents',
            Icons.report_problem,
            Colors.orange,
            () => _showReportDialog(),
          ),

          const SizedBox(height: 12),

          if (widget.userType == 'rider') ...[
            _buildActionCard(
              'Vehicle Safety Check',
              'Log and track your vehicle safety inspections',
              Icons.car_repair,
              Colors.green,
              () => _showVehicleSafetyDialog(),
            ),
            const SizedBox(height: 12),
          ],

          _buildActionCard(
            'Safety Feedback',
            'Share feedback to help improve safety',
            Icons.feedback,
            Colors.blue,
            () => _showFeedbackDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon,
      bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.grey.shade400, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.userType == 'rider'
                ? 'Your Driver Verification'
                : 'Driver Verification',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Verification Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Text(
                      'Verification Process',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.userType == 'rider'
                      ? 'As a ViaGo driver, you\'ve completed our comprehensive verification process. This ensures passenger safety and builds trust in our platform.'
                      : 'All ViaGo drivers go through a comprehensive verification process to ensure your safety.',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Verification Steps
          const Text(
            'Verification Requirements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ..._buildVerificationSteps(),

          const SizedBox(height: 24),

          // What to Check
          const Text(
            'What to Verify Before Your Ride',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ..._buildVerificationChecklist(),
        ],
      ),
    );
  }

  List<Widget> _buildVerificationSteps() {
    final steps = [
      {
        'title': 'Identity Verification',
        'desc': 'Government-issued ID verification'
      },
      {'title': 'Background Check', 'desc': 'Criminal background screening'},
      {
        'title': 'Vehicle Registration',
        'desc': 'Valid vehicle registration and insurance'
      },
      {
        'title': 'License Verification',
        'desc': 'Valid driving license verification'
      },
      {'title': 'Phone Verification', 'desc': 'Phone number verification'},
    ];

    return steps
        .map((step) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['desc']!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildVerificationChecklist() {
    final checklist = [
      'Match driver photo with their profile',
      'Verify vehicle make, model, and color',
      'Check license plate number',
      'Confirm driver name and rating',
      'Ensure vehicle is clean and safe',
    ];

    return checklist
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_box, color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Emergency SOS'),
        content: const Text(
          'Are you in an emergency? This will alert emergency services and your emergency contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerSOS();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send SOS Alert'),
          ),
        ],
      ),
    );
  }

  void _triggerSOS() {
    // Implement SOS logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('SOS Alert sent! Emergency services and contacts notified.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Safety Incident'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the safety incident...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Safety incident reported. Our team will investigate.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showVehicleSafetyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Vehicle Safety Check'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Regular vehicle safety checks ensure passenger safety and comply with ViaGo requirements.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Log your safety check details (brakes, tires, lights, etc.)...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vehicle safety check logged successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Log Check'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Safety Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your safety feedback...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
