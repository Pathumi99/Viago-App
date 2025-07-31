import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'rider_home_screen.dart';
import 'passenger_home_screen.dart';
import 'activity_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import '../providers/theme_provider.dart';
import '../generated/app_localizations.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  String? _userType;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserType();
  }

  Future<void> _fetchUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userType = doc['userType'];
        _loading = false;
      });
    }
  }

  List<Widget> get _screens {
    if (_userType == 'rider') {
      return [
        const RiderHomeScreen(),
        const ActivityScreen(),
        const NotificationScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const PassengerHomeScreen(),
        const ActivityScreen(),
        const NotificationScreen(),
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(themeProvider.accentColor),
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: themeProvider.accentColor,
          unselectedItemColor:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 0
                    ? BoxDecoration(
                        color: themeProvider.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  size: 24,
                ),
              ),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 1
                    ? BoxDecoration(
                        color: themeProvider.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _selectedIndex == 1
                      ? Icons.show_chart
                      : Icons.show_chart_outlined,
                  size: 24,
                ),
              ),
              label: l10n.activity,
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 2
                    ? BoxDecoration(
                        color: themeProvider.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _selectedIndex == 2
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                  size: 24,
                ),
              ),
              label: l10n.notifications,
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 3
                    ? BoxDecoration(
                        color: themeProvider.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _selectedIndex == 3
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                  size: 24,
                ),
              ),
              label: l10n.account,
            ),
          ],
        ),
      ),
    );
  }
}
