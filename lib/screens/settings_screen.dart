import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoSync = false;
  String _selectedState = 'Maharashtra';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final bg = isDark ? AppColors.bgDark : const Color(0xFFF5F7FA);
    final surface = isDark ? AppColors.bgSurface : Colors.white;
    final card = isDark ? AppColors.bgCard : Colors.white;
    final border = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE0E0E0);
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF90A4AE);
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF546E7A);
    final dropdownBg = isDark ? AppColors.bgCard : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: surface,
              floating: true,
              snap: true,
              elevation: 0,
              title: Text('Settings',
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                          backgroundColor: AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Politica AI User',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                            Text('Election Intelligence',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data Settings
                  _sectionHeader('Data & Sync', textMuted),
                  const SizedBox(height: 12),

                  _settingCard(
                    card: card,
                    border: border,
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.locationDot,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 12),
                        Text('Default State',
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 14)),
                        const Spacer(),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedState,
                            dropdownColor: dropdownBg,
                            style: const TextStyle(
                                color: AppColors.accent, fontSize: 13),
                            items: ['Maharashtra', 'Delhi', 'Gujarat', 'Uttar Pradesh', 'Bihar', 'Rajasthan', 'Madhya Pradesh', 'Karnataka']
                                .map((s) => DropdownMenuItem(
                                value: s, child: Text(s)))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedState = val!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  _switchCard(
                    icon: FontAwesomeIcons.rotate,
                    title: 'Auto Sync',
                    subtitle: 'Sync data automatically',
                    value: _autoSync,
                    onChanged: (v) => setState(() => _autoSync = v),
                    card: card,
                    border: border,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 24),

                  // App Settings
                  _sectionHeader('App Settings', textMuted),
                  const SizedBox(height: 12),

                  _switchCard(
                    icon: FontAwesomeIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Get election alerts',
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                    card: card,
                    border: border,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 10),

                  _switchCard(
                    icon: FontAwesomeIcons.moon,
                    title: 'Dark Mode',
                    subtitle: 'Toggle theme',
                    value: isDark,
                    onChanged: (v) {
                      context.read<ThemeProvider>().toggle();
                    },
                    card: card,
                    border: border,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 24),

                  // About
                  _sectionHeader('About', textMuted),
                  const SizedBox(height: 12),
                  _settingCard(
                    card: card,
                    border: border,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Version',
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: 13)),
                        Text('1.0.0',
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Text(title,
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2));
  }

  Widget _settingCard({required Widget child, required Color card, required Color border}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _switchCard({
    required FaIconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color card,
    required Color border,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return _settingCard(
      card: card,
      border: border,
      child: Row(
        children: [
          FaIcon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: textPrimary, fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(
                        color: textMuted, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
