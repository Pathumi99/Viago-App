import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  final List<ThemeOption> _themes = [
    ThemeOption(
      name: 'Light',
      description: 'Clean and bright interface',
      icon: Icons.light_mode,
      themeMode: ThemeMode.light,
    ),
    ThemeOption(
      name: 'Dark',
      description: 'Easy on the eyes in low light',
      icon: Icons.dark_mode,
      themeMode: ThemeMode.dark,
    ),
    ThemeOption(
      name: 'Auto',
      description: 'Follows system settings',
      icon: Icons.brightness_auto,
      themeMode: ThemeMode.system,
    ),
  ];

  final List<AccentColorOption> _accentColors = [
    AccentColorOption(name: 'Blue', color: const Color(0xFF2563EB)),
    AccentColorOption(name: 'Purple', color: const Color(0xFF7C3AED)),
    AccentColorOption(name: 'Green', color: const Color(0xFF059669)),
    AccentColorOption(name: 'Orange', color: const Color(0xFFEA580C)),
    AccentColorOption(name: 'Pink', color: const Color(0xFFE11D48)),
    AccentColorOption(name: 'Teal', color: const Color(0xFF0D9488)),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentTheme = _themes.firstWhere(
          (theme) => theme.themeMode == themeProvider.themeMode,
          orElse: () => _themes[0],
        );
        final currentAccentColor = _accentColors.firstWhere(
          (color) => color.color == themeProvider.accentColor,
          orElse: () => _accentColors[0],
        );

        return Scaffold(
          body: Column(
            children: [
              // Header Section with gradient
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Text(
                                'Theme',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(
                                width: 48), // Balance the back button
                          ],
                        ),
                      ),

                      // Header content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.palette,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Customize your app appearance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
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

              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Theme Preview
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              themeProvider.accentColor.withOpacity(0.1),
                              themeProvider.accentColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeProvider.accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    themeProvider.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                currentTheme.icon,
                                color: themeProvider.accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Theme',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: themeProvider.accentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${currentTheme.name} mode • ${currentAccentColor.name} accent',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeProvider.accentColor
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: themeProvider.accentColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Theme Mode Section
                      Text(
                        'Appearance Mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      ...List.generate(_themes.length, (index) {
                        final theme = _themes[index];
                        final isSelected =
                            themeProvider.themeMode == theme.themeMode;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await themeProvider
                                    .setThemeMode(theme.themeMode);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.white),
                                          const SizedBox(width: 12),
                                          Text(
                                              'Theme changed to ${theme.name} mode'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? themeProvider.accentColor
                                          .withOpacity(0.05)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? themeProvider.accentColor
                                        : (isDark
                                            ? Colors.grey.withOpacity(0.3)
                                            : Colors.grey.withOpacity(0.2)),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isDark ? Colors.black : Colors.grey)
                                              .withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Theme Preview
                                    Container(
                                      width: 60,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            _getThemePreviewBg(theme.themeMode),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (isDark
                                              ? Colors.grey.withOpacity(0.4)
                                              : Colors.grey.withOpacity(0.3)),
                                          width: 1,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Mini card
                                          Positioned(
                                            top: 6,
                                            left: 6,
                                            right: 6,
                                            child: Container(
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: _getThemePreviewCard(
                                                    theme.themeMode),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          // Mini button
                                          Positioned(
                                            bottom: 6,
                                            right: 6,
                                            child: Container(
                                              width: 16,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color:
                                                    themeProvider.accentColor,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Theme Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                theme.icon,
                                                size: 20,
                                                color: isSelected
                                                    ? themeProvider.accentColor
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                theme.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? themeProvider
                                                          .accentColor
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            theme.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? themeProvider.accentColor
                                                      .withOpacity(0.8)
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Selection Indicator
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? themeProvider.accentColor
                                              : Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.4) ??
                                                  Colors.grey.withOpacity(0.4),
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? themeProvider.accentColor
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Accent Color Section
                      Text(
                        'Accent Color',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : Colors.grey)
                                  .withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: _accentColors.length,
                          itemBuilder: (context, index) {
                            final colorOption = _accentColors[index];
                            final isSelected =
                                themeProvider.accentColor == colorOption.color;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await themeProvider
                                      .setAccentColor(colorOption.color);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                color: Colors.white),
                                            const SizedBox(width: 12),
                                            Text(
                                                'Accent color changed to ${colorOption.name}'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorOption.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? colorOption.color
                                          : colorOption.color.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: colorOption.color,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        colorOption.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: colorOption.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Advanced Settings
                      Text(
                        'Advanced Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : Colors.grey)
                                  .withOpacity(0.1),
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
                              color: themeProvider.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: themeProvider.accentColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Adaptive Theme',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            'Automatically adjust theme based on time of day',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Switch(
                            value: themeProvider.adaptiveTheme,
                            onChanged: (value) async {
                              await themeProvider.setAdaptiveTheme(value);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.white),
                                        const SizedBox(width: 12),
                                        Text(
                                            'Adaptive theme ${value ? 'enabled' : 'disabled'}'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            activeColor: themeProvider.accentColor,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Theme Preview Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : Colors.grey)
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: themeProvider.accentColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.preview,
                                    color: themeProvider.accentColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Preview',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (isDark
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2)),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Mock app bar
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: themeProvider.accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.menu,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 12),
                                        Text(
                                          'ViaGo',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.notifications,
                                            color: Colors.white, size: 16),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Mock content
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.directions_car,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Recent Ride',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.color,
                                                ),
                                              ),
                                              Text(
                                                'Colombo to Kandy',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Mock button
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: themeProvider.accentColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Book a Ride',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getThemePreviewBg(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Colors.white;
      case ThemeMode.dark:
        return const Color(0xFF1F2937);
      case ThemeMode.system:
        return Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1F2937)
            : Colors.white;
    }
  }

  Color _getThemePreviewCard(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return const Color(0xFFF8FAFC);
      case ThemeMode.dark:
        return const Color(0xFF374151);
      case ThemeMode.system:
        return Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF374151)
            : const Color(0xFFF8FAFC);
    }
  }
}

class ThemeOption {
  final String name;
  final String description;
  final IconData icon;
  final ThemeMode themeMode;

  ThemeOption({
    required this.name,
    required this.description,
    required this.icon,
    required this.themeMode,
  });
}

class AccentColorOption {
  final String name;
  final Color color;

  AccentColorOption({
    required this.name,
    required this.color,
  });
}
