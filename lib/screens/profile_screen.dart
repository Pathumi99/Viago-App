import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'feedback_list_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_preferences_screen.dart';
import 'language_selection_screen.dart';
import 'security_screen.dart';
import 'theme_screen.dart';
import 'help_support_screen.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';
import 'main_nav_screen.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final bool isFromBottomNav;

  const ProfileScreen({super.key, this.isFromBottomNav = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Enhanced Header Section with animated gradient
                  _buildEnhancedHeader(themeProvider, l10n, isDark),

                  // Content Section with enhanced styling
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Enhanced Personal Section
                          _buildEnhancedSection(
                            title: 'Personal',
                            icon: Icons.person_outline,
                            color: Colors.blue,
                            items: [
                              _MenuItemData(
                                icon: Icons.edit_outlined,
                                title: l10n.editProfile,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                },
                              ),
                              _MenuItemData(
                                icon: Icons.notifications_outlined,
                                title: l10n.notificationSettings,
                                subtitle: 'On/Off state',
                                subtitleColor: themeProvider.accentColor,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationPreferencesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Enhanced Preferences Section
                          _buildEnhancedSection(
                            title: 'Preferences',
                            icon: Icons.settings_outlined,
                            color: Colors.purple,
                            items: [
                              _MenuItemData(
                                icon: Icons.language_outlined,
                                title: l10n.language,
                                subtitle: _getLanguageDisplayName(context
                                    .watch<LocaleProvider>()
                                    .locale
                                    .languageCode),
                                subtitleColor: themeProvider.accentColor,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LanguageSelectionScreen(),
                                    ),
                                  );
                                },
                              ),
                              _MenuItemData(
                                icon: Icons.palette_outlined,
                                title: l10n.theme,
                                subtitle: _getThemeDisplayName(
                                    themeProvider.themeMode),
                                subtitleColor: themeProvider.accentColor,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ThemeScreen(),
                                    ),
                                  );
                                },
                              ),
                              _MenuItemData(
                                icon: Icons.security_outlined,
                                title: l10n.security,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SecurityScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Enhanced Rating Section for Riders
                          FutureBuilder<DocumentSnapshot>(
                            future: user != null
                                ? FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user!.uid)
                                    .get()
                                : Future.value(null),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || user == null) {
                                return const SizedBox();
                              }
                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;

                              if (data['userType'] == 'rider') {
                                return Column(
                                  children: [
                                    _buildEnhancedSection(
                                      title: 'Rating',
                                      icon: Icons.star_outline,
                                      color: Colors.amber,
                                      items: [
                                        _MenuItemData(
                                          icon: Icons.star_outline,
                                          title: 'Average Rating',
                                          subtitle:
                                              '${data['averageRating'] ?? 5.0}',
                                          subtitleColor: Colors.amber,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FeedbackListScreen(
                                                        riderId: user!.uid),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),

                          // Enhanced Support Section
                          _buildEnhancedSection(
                            title: 'Support',
                            icon: Icons.help_outline,
                            color: Colors.green,
                            items: [
                              _MenuItemData(
                                icon: Icons.help_outline,
                                title: l10n.help,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HelpSupportScreen(),
                                    ),
                                  );
                                },
                              ),
                              _MenuItemData(
                                icon: Icons.contact_support_outlined,
                                title: l10n.contact,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ContactScreen(),
                                    ),
                                  );
                                },
                              ),
                              _MenuItemData(
                                icon: Icons.privacy_tip_outlined,
                                title: l10n.privacy,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyPolicyScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Enhanced Logout Button
                          _buildEnhancedLogoutButton(l10n, isDark),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedHeader(
      ThemeProvider themeProvider, AppLocalizations l10n, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.accentColor,
            themeProvider.accentColor.withValues(alpha: 0.8),
            themeProvider.accentColor.withValues(alpha: 0.9),
            const Color(0xFF4A90E2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.accentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Enhanced App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          if (widget.isFromBottomNav) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainNavScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            try {
                              Navigator.pop(context);
                            } catch (e) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainNavScreen(),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      l10n.profile,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Enhanced Profile Header
            FutureBuilder<DocumentSnapshot>(
              future: user != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .get()
                  : Future.value(null),
              builder: (context, snapshot) {
                if (!snapshot.hasData || user == null) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    children: [
                      // Enhanced Profile Avatar with glow effect
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: themeProvider.accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Enhanced Profile Name with animation
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          data['name'] ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Enhanced Profile Email
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          data['email'] ?? user!.email ?? 'user@example.com',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Enhanced Curved bottom with gradient
            Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_MenuItemData> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Enhanced Menu Items
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey)
                    .withValues(alpha: 0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
                  .withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              int index = entry.key;
              _MenuItemData item = entry.value;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Enhanced Icon Container
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Provider.of<ThemeProvider>(context)
                                        .accentColor
                                        .withValues(alpha: 0.15),
                                    Provider.of<ThemeProvider>(context)
                                        .accentColor
                                        .withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Provider.of<ThemeProvider>(context)
                                      .accentColor
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                color: Provider.of<ThemeProvider>(context)
                                    .accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Enhanced Title
                            Expanded(
                              child: Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                    ),
                              ),
                            ),

                            // Enhanced Trailing with subtitle and arrow
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.subtitle != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (item.subtitleColor ?? Colors.grey)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            (item.subtitleColor ?? Colors.grey)
                                                .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      item.subtitle!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: item.subtitleColor ??
                                            Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedLogoutButton(AppLocalizations l10n, bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, size: 22),
        label: Text(
          l10n.logout,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.red.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      case 'en':
      default:
        return 'English';
    }
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'Auto mode';
      default:
        return 'Light mode';
    }
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    required this.onTap,
  });
}
