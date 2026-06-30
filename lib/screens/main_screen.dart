  import 'package:flutter/material.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import '../theme/app_theme.dart';
  import 'dashboard_screen.dart';
  import 'constituency_screen.dart';
  import 'parties_screen.dart';
  import 'candidates_screen.dart';
  import 'analytics_screen.dart';
  import 'insights_screen.dart';
  import 'package:provider/provider.dart';
  import '../main.dart';

  class MainScreen extends StatefulWidget {
    const MainScreen({super.key});

    @override
    State<MainScreen> createState() => _MainScreenState();
  }

  class _MainScreenState extends State<MainScreen> {
    int _selectedIndex = 0;

    final List<_NavItem> _navItems = [
      _NavItem(icon: FontAwesomeIcons.chartPie, label: 'Dashboard'),
      _NavItem(icon: FontAwesomeIcons.mapPin, label: 'Areas'),
      _NavItem(icon: FontAwesomeIcons.users, label: 'Candidates'),
      _NavItem(icon: FontAwesomeIcons.robot, label: 'AI'),
      _NavItem(icon: FontAwesomeIcons.chartLine, label: 'Analytics'),
    ];

    final List<Widget> _screens = [
      const DashboardScreen(),
      const ConstituencyScreen(),
      const CandidatesScreen(),
      const InsightsScreen(),
      const AnalyticsScreen(),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: context.watch<ThemeProvider>().isDark ? AppColors.bgDark : const Color(0xFFF5F7FA),
        body: _screens[_selectedIndex],
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    Widget _buildBottomNav() {
      return Container(
        decoration: BoxDecoration(
          color: context.watch<ThemeProvider>().isDark ? AppColors.bgSurface : Colors.white,
          border: Border(top: BorderSide(color: context.watch<ThemeProvider>().isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE0E0E0))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((e) {
                final isSelected = _selectedIndex == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          e.value.icon,
                          size: 18,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.value.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
  }

  class _NavItem {
    final IconData icon;
    final String label;
    _NavItem({required this.icon, required this.label});
  }