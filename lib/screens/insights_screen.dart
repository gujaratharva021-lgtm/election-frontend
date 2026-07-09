import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<dynamic> _insights = [];
  bool _loading = true;
  int _selectedYear = 2024;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getInsights();
      setState(() {
        _insights = data['insights'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'strength': return AppColors.accentGreen;
      case 'opportunity': return AppColors.accentOrange;
      case 'risk': return AppColors.accentRed;
      default: return AppColors.accent;
    }
  }

  FaIconData _getIcon(String type) {
    switch (type) {
      case 'strength': return FontAwesomeIcons.chartLine;
      case 'opportunity': return FontAwesomeIcons.lightbulb;
      case 'risk': return FontAwesomeIcons.triangleExclamation;
      default: return FontAwesomeIcons.circleInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0A1628);
    final borderColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED);
    final cardColor = isDark ? AppColors.bgCard : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? AppColors.bgSurface : Colors.white,
              floating: true,
              snap: true,
              elevation: 0,
              title: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.robot, color: AppColors.accent, size: 18),
                  const SizedBox(width: 10),
                  Text('AI Insights',
                      style: TextStyle(
                          color: textColor, fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgCardLight : const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      dropdownColor: cardColor,
                      style: TextStyle(color: textColor, fontSize: 12),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textMuted, size: 14),
                      isDense: true,
                      items: [2024, 2019, 2014, 2009, 2004].map((y) {
                        return DropdownMenuItem(value: y, child: Text('$y'));
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedYear = val!);
                        _loadData();
                      },
                    ),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // AI Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.accent.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: FaIcon(FontAwesomeIcons.brain,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AI Analysis — Real Data',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text(
                                  '${_insights.length} insights generated from ECI data — $_selectedYear',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Key Insights',
                      style: TextStyle(
                          color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  _loading
                      ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent))
                      : _insights.isEmpty
                      ? const Center(
                      child: Text('No insights available',
                          style: TextStyle(color: AppColors.textMuted)))
                      : Column(
                    children: _insights.map((insight) {
                      final type = insight['type'] ?? 'insight';
                      final color = _getColor(type);
                      final icon = _getIcon(type);
                      final value = insight['value'] ?? 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: FaIcon(icon, color: color, size: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(insight['title'] ?? '',
                                            style: TextStyle(
                                                color: textColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(insight['tag'] ?? '',
                                            style: TextStyle(
                                                color: color,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(insight['description'] ?? '',
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                          height: 1.5)),
                                  if (value > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.chartBar,
                                              size: 10, color: color),
                                          const SizedBox(width: 4),
                                          Text('${value.toInt()} seats',
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
