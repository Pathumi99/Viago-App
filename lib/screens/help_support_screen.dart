import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../generated/app_localizations.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _selectedTabIndex = 0;

  final List<_FAQItem> _faqItems = [
    _FAQItem(
      category: 'Getting Started',
      question: 'How do I create an account?',
      answer:
          'To create an account, tap "Create Account" on the login screen, fill in your details, and choose whether you want to be a rider or passenger. You\'ll receive a verification email to complete the registration.',
    ),
    _FAQItem(
      category: 'Getting Started',
      question: 'What\'s the difference between a rider and passenger?',
      answer:
          'A rider is someone who offers rides to others using their own vehicle. A passenger is someone who books rides with riders. You can switch between modes, but you need to register as the appropriate type initially.',
    ),
    _FAQItem(
      category: 'Booking Rides',
      question: 'How do I book a ride?',
      answer:
          'As a passenger, go to "Find a Ride", enter your pickup and destination locations, select your preferred time, and browse available riders. Send a request to your preferred rider and wait for confirmation.',
    ),
    _FAQItem(
      category: 'Booking Rides',
      question: 'How do I cancel a ride?',
      answer:
          'You can cancel a ride request from the "My Ride Requests" section. If the ride is already confirmed, please contact the rider directly and cancel with mutual agreement.',
    ),
    _FAQItem(
      category: 'Booking Rides',
      question: 'What if my ride is cancelled?',
      answer:
          'If a rider cancels your confirmed ride, you\'ll receive a notification. You can then search for alternative rides or contact our support team for assistance.',
    ),
    _FAQItem(
      category: 'Offering Rides',
      question: 'How do I offer a ride?',
      answer:
          'As a rider, go to "Post a Ride", enter your route details, departure time, available seats, and price. Your ride will be visible to passengers searching for similar routes.',
    ),
    _FAQItem(
      category: 'Offering Rides',
      question: 'How do I manage ride requests?',
      answer:
          'Go to "Incoming Ride Requests" to view, accept, or reject passenger requests. You\'ll receive notifications for new requests and can communicate with passengers through the app.',
    ),
    _FAQItem(
      category: 'Payments',
      question: 'How do payments work?',
      answer:
          'Currently, payments are handled directly between riders and passengers. We recommend discussing payment methods (cash, bank transfer, mobile payment) before the ride begins.',
    ),
    _FAQItem(
      category: 'Payments',
      question: 'Are there any fees?',
      answer:
          'ViaGo is currently free to use. We don\'t charge any booking fees or commissions. You only pay the ride fare agreed with the rider.',
    ),
    _FAQItem(
      category: 'Safety',
      question: 'How do I stay safe during rides?',
      answer:
          'Always verify the rider\'s identity and vehicle details before getting in. Share your ride details with friends or family. Rate your experience after each ride to help build a safe community.',
    ),
    _FAQItem(
      category: 'Safety',
      question: 'What should I do if I feel unsafe?',
      answer:
          'If you feel unsafe during a ride, trust your instincts. Ask the rider to stop in a safe, public location. Contact local emergency services if needed. Report the incident to our support team immediately.',
    ),
    _FAQItem(
      category: 'Technical',
      question: 'Why can\'t I see my location on the map?',
      answer:
          'Make sure you\'ve granted location permissions to the ViaGo app. Check your device\'s location settings and ensure GPS is enabled. Restart the app if the problem persists.',
    ),
    _FAQItem(
      category: 'Technical',
      question: 'The app is not working properly. What should I do?',
      answer:
          'Try closing and reopening the app. If issues persist, restart your device. Make sure you have the latest version of the app installed. Contact our support team if problems continue.',
    ),
    _FAQItem(
      category: 'Account',
      question: 'How do I change my profile information?',
      answer:
          'Go to Profile > Edit Profile to update your name, phone number, and other details. Some changes may require verification for security purposes.',
    ),
    _FAQItem(
      category: 'Account',
      question: 'I forgot my password. How do I reset it?',
      answer:
          'On the login screen, tap "Forgot Password?" and enter your email address. You\'ll receive a password reset link. Follow the instructions to create a new password.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeProvider.accentColor,
                  themeProvider.accentColor.withOpacity(0.8),
                  themeProvider.accentColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Help & Support',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Header content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.support_agent,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We\'re here to help',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find answers to common questions or get in touch with our support team',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTabButton('FAQ', 0),
                        ),
                        Expanded(
                          child: _buildTabButton('Contact', 1),
                        ),
                        Expanded(
                          child: _buildTabButton('About', 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Curved bottom
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Provider.of<ThemeProvider>(context).accentColor
                : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildFAQTab();
      case 1:
        return _buildContactTab();
      case 2:
        return _buildAboutTab();
      default:
        return _buildFAQTab();
    }
  }

  Widget _buildFAQTab() {
    final categories = _faqItems.map((item) => item.category).toSet().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          ...categories.map((category) => _buildFAQCategory(category)),
        ],
      ),
    );
  }

  Widget _buildFAQCategory(String category) {
    final categoryItems =
        _faqItems.where((item) => item.category == category).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Provider.of<ThemeProvider>(context).accentColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: categoryItems.asMap().entries.map((entry) {
              int index = entry.key;
              _FAQItem item = entry.value;

              return Column(
                children: [
                  ExpansionTile(
                    title: Text(
                      item.question,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          item.answer,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (index < categoryItems.length - 1)
                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContactTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get In Touch',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re here to help you with any questions or issues you may have.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 24),

          // Contact Options
          _buildContactOption(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@viargo.com',
            description:
                'Get help via email. We typically respond within 24 hours.',
            onTap: () => _launchEmail('support@viargo.com'),
          ),

          const SizedBox(height: 16),

          _buildContactOption(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            subtitle: '+94 11 234 5678',
            description:
                'Call us for immediate assistance. Available Mon-Fri, 9 AM - 6 PM.',
            onTap: () => _launchPhone('+94112345678'),
          ),

          const SizedBox(height: 16),

          _buildContactOption(
            icon: Icons.chat_outlined,
            title: 'WhatsApp',
            subtitle: '+94 77 123 4567',
            description: 'Chat with us on WhatsApp for quick support.',
            onTap: () => _launchWhatsApp('+94771234567'),
          ),

          const SizedBox(height: 32),

          // Emergency Contact
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red.shade600, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Emergency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'If you\'re in immediate danger or need emergency assistance during a ride, please contact local emergency services immediately.',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchPhone('119'),
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text('Call Emergency Services (119)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
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

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context)
                .accentColor
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Provider.of<ThemeProvider>(context).accentColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Provider.of<ThemeProvider>(context).accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildAboutTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ViaGo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          _buildInfoCard(
            icon: Icons.info_outline,
            title: 'App Version',
            content: '1.0.0',
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            icon: Icons.description_outlined,
            title: 'About',
            content:
                'ViaGo is a ride-sharing platform that connects riders and passengers in Sri Lanka. Our mission is to make transportation more accessible, affordable, and sustainable for everyone.',
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            icon: Icons.policy_outlined,
            title: 'Terms of Service',
            content:
                'By using ViaGo, you agree to our terms of service and privacy policy.',
            isClickable: true,
            onTap: () => _showTermsDialog(),
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            content: 'Learn how we protect your personal information and data.',
            isClickable: true,
            onTap: () => _showPrivacyDialog(),
          ),

          const SizedBox(height: 32),

          // Social Media
          Text(
            'Follow Us',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                onTap: () => _launchURL('https://facebook.com/viargo'),
              ),
              _buildSocialButton(
                icon: Icons.alternate_email,
                label: 'Twitter',
                onTap: () => _launchURL('https://twitter.com/viargo'),
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                onTap: () => _launchURL('https://instagram.com/viargo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context)
                .accentColor
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Provider.of<ThemeProvider>(context).accentColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            content,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
        ),
        trailing: isClickable
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context)
                .accentColor
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              color: Provider.of<ThemeProvider>(context).accentColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _copyToClipboard(email, 'Email address copied to clipboard');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _copyToClipboard(phone, 'Phone number copied to clipboard');
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _copyToClipboard(phone, 'WhatsApp number copied to clipboard');
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Provider.of<ThemeProvider>(context).accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using ViaGo, you agree to:\n\n'
            '1. Use the app responsibly and legally\n'
            '2. Provide accurate information\n'
            '3. Respect other users\n'
            '4. Follow traffic rules and safety guidelines\n'
            '5. Report any issues or inappropriate behavior\n\n'
            'We reserve the right to suspend accounts that violate these terms.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'We protect your privacy by:\n\n'
            '1. Collecting only necessary information\n'
            '2. Using secure encryption for data transmission\n'
            '3. Not sharing personal data with third parties\n'
            '4. Allowing you to control your privacy settings\n'
            '5. Providing options to delete your account\n\n'
            'For more details, please visit our website or contact support.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FAQItem {
  final String category;
  final String question;
  final String answer;

  _FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}
