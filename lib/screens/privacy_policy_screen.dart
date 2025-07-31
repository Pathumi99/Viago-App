import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../generated/app_localizations.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            'Privacy Policy',
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
                          Icons.privacy_tip,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We are committed to protecting your personal information and your right to privacy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

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
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Updated
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeProvider.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated: December 15, 2024',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: themeProvider.accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This privacy policy explains how ViaGo Technologies (Pvt) Ltd. collects, uses, and protects your personal information when you use our ride-sharing services.',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Table of Contents
                  _buildTableOfContents(),

                  const SizedBox(height: 32),

                  // 1. Information We Collect
                  _buildSection(
                    '1. Information We Collect',
                    [
                      _buildSubSection('Personal Information', [
                        '• Name, email address, and phone number',
                        '• Profile picture and user preferences',
                        '• Government-issued ID for verification (drivers only)',
                        '• Payment information (processed securely by third parties)',
                        '• Vehicle information (for drivers)',
                      ]),
                      _buildSubSection('Location Information', [
                        '• Real-time GPS location during rides',
                        '• Pickup and drop-off locations',
                        '• Route information and trip history',
                        '• Location data is only collected when the app is in use',
                      ]),
                      _buildSubSection('Usage Information', [
                        '• App usage patterns and preferences',
                        '• Device information (model, OS version, device ID)',
                        '• Log files and crash reports',
                        '• Communication records with customer support',
                      ]),
                    ],
                  ),

                  // 2. How We Use Your Information
                  _buildSection(
                    '2. How We Use Your Information',
                    [
                      _buildSubSection('Service Provision', [
                        '• Connect riders and passengers',
                        '• Process ride requests and payments',
                        '• Provide navigation and route optimization',
                        '• Send ride confirmations and updates',
                      ]),
                      _buildSubSection('Safety & Security', [
                        '• Verify user identities',
                        '• Monitor for fraudulent activities',
                        '• Investigate safety incidents',
                        '• Maintain platform security',
                      ]),
                      _buildSubSection('Improvement & Support', [
                        '• Improve app functionality and user experience',
                        '• Provide customer support',
                        '• Analyze usage patterns to enhance services',
                        '• Send important notifications about service changes',
                      ]),
                    ],
                  ),

                  // 3. Information Sharing
                  _buildSection(
                    '3. Information Sharing',
                    [
                      _buildSubSection('With Other Users', [
                        '• Limited profile information (name, photo, rating)',
                        '• Real-time location during active rides',
                        '• Contact information for ride coordination',
                        '• Trip details for ride completion',
                      ]),
                      _buildSubSection('With Service Providers', [
                        '• Payment processors for transaction handling',
                        '• Map and navigation service providers',
                        '• Cloud storage and hosting services',
                        '• Analytics and crash reporting services',
                      ]),
                      _buildSubSection('Legal Requirements', [
                        '• Compliance with legal obligations',
                        '• Response to court orders or legal processes',
                        '• Protection of our rights and safety',
                        '• Investigation of potential violations',
                      ]),
                    ],
                  ),

                  // 4. Data Security
                  _buildSection(
                    '4. Data Security',
                    [
                      _buildSubSection('Security Measures', [
                        '• End-to-end encryption for sensitive data',
                        '• Secure servers with regular security updates',
                        '• Two-factor authentication for account access',
                        '• Regular security audits and penetration testing',
                      ]),
                      _buildSubSection('Payment Security', [
                        '• We do not store payment card details',
                        '• PCI DSS compliant payment processing',
                        '• Tokenization of payment information',
                        '• Secure payment gateway integration',
                      ]),
                      _buildSubSection('Data Breach Response', [
                        '• Immediate incident response procedures',
                        '• Notification within 72 hours of discovery',
                        '• User notification for high-risk breaches',
                        '• Collaboration with relevant authorities',
                      ]),
                    ],
                  ),

                  // 5. Your Rights and Choices
                  _buildSection(
                    '5. Your Rights and Choices',
                    [
                      _buildSubSection('Access and Control', [
                        '• View and edit your personal information',
                        '• Download your data in a portable format',
                        '• Delete your account and associated data',
                        '• Manage notification preferences',
                      ]),
                      _buildSubSection('Location Services', [
                        '• Enable or disable location services',
                        '• Choose precision level for location sharing',
                        '• Review location history in your account',
                        '• Delete location data (may affect service quality)',
                      ]),
                      _buildSubSection('Marketing Communications', [
                        '• Opt out of promotional emails',
                        '• Customize push notification preferences',
                        '• Unsubscribe from SMS communications',
                        '• Control in-app promotional content',
                      ]),
                    ],
                  ),

                  // 6. Data Retention
                  _buildSection(
                    '6. Data Retention',
                    [
                      _buildSubSection('Active Accounts', [
                        '• Profile information: Until account deletion',
                        '• Trip history: 7 years for legal compliance',
                        '• Location data: 1 year after trip completion',
                        '• Communication records: 3 years',
                      ]),
                      _buildSubSection('Deleted Accounts', [
                        '• Personal information: Deleted within 30 days',
                        '• Financial records: Retained for 7 years',
                        '• Safety-related data: Retained for 7 years',
                        '• Anonymous analytics: May be retained indefinitely',
                      ]),
                    ],
                  ),

                  // 7. Children's Privacy
                  _buildSection(
                    '7. Children\'s Privacy',
                    [
                      _buildSubSection('Age Restrictions', [
                        '• ViaGo is not intended for users under 18',
                        '• We do not knowingly collect data from minors',
                        '• Parental consent required for users under 18',
                        '• Immediate deletion of underage user data',
                      ]),
                    ],
                  ),

                  // 8. International Transfers
                  _buildSection(
                    '8. International Transfers',
                    [
                      _buildSubSection('Data Processing', [
                        '• Primary servers located in Sri Lanka',
                        '• Some services may process data internationally',
                        '• Adequate protection measures in place',
                        '• Compliance with local data protection laws',
                      ]),
                    ],
                  ),

                  // 9. Changes to Privacy Policy
                  _buildSection(
                    '9. Changes to This Privacy Policy',
                    [
                      _buildSubSection('Policy Updates', [
                        '• We may update this policy periodically',
                        '• Users will be notified of significant changes',
                        '• Updated policy will be posted in the app',
                        '• Continued use implies acceptance of changes',
                      ]),
                    ],
                  ),

                  // 10. Contact Information
                  _buildSection(
                    '10. Contact Information',
                    [
                      _buildSubSection('Data Protection Officer', [
                        '• Email: privacy@viargo.com',
                        '• Phone: +94 11 234 5678',
                        '• Address: 123 Galle Road, Colombo 03, Sri Lanka',
                        '• Response time: Within 5 business days',
                      ]),
                      _buildSubSection('Rights Requests', [
                        '• Submit requests through the app settings',
                        '• Email us at privacy@viargo.com',
                        '• Include your full name and registered email',
                        '• Verification may be required for security',
                      ]),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 32),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableOfContents() {
    final contents = [
      '1. Information We Collect',
      '2. How We Use Your Information',
      '3. Information Sharing',
      '4. Data Security',
      '5. Your Rights and Choices',
      '6. Data Retention',
      '7. Children\'s Privacy',
      '8. International Transfers',
      '9. Changes to This Privacy Policy',
      '10. Contact Information',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey)
                .withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context)
                      .accentColor
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.list_alt,
                  color: Provider.of<ThemeProvider>(context).accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Table of Contents',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...contents
              .map((content) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              ,
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeProvider>(context).accentColor,
              ),
        ),
        const SizedBox(height: 16),
        ...content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...points
            .map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    point,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ))
            ,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey)
                .withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'If you have any questions about this privacy policy or your data rights, we\'re here to help.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchEmail('privacy@viargo.com'),
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Email Us'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Provider.of<ThemeProvider>(context).accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard('privacy@viargo.com'),
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: const Text('Copy Email'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Provider.of<ThemeProvider>(context).accentColor,
                    side: BorderSide(
                      color: Provider.of<ThemeProvider>(context).accentColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context).accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'ViaGo Technologies (Pvt) Ltd.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Provider.of<ThemeProvider>(context).accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '123 Galle Road, Colombo 03, Sri Lanka',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Email: privacy@viargo.com | Phone: +94 11 234 5678',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _launchURL('https://viargo.com/terms'),
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).accentColor,
                  ),
                ),
              ),
              Text(
                ' | ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              TextButton(
                onPressed: () => _launchURL('https://viargo.com/contact'),
                child: Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri =
        Uri.parse('mailto:$email?subject=Privacy Policy Inquiry');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _copyToClipboard(email);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copied to clipboard'),
        backgroundColor: Provider.of<ThemeProvider>(context).accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
