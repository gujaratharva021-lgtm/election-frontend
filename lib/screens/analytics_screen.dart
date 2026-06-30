import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<dynamic> _results = [];
  List<dynamic> _allResults = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final year = context.read<YearProvider>().year;
      final winnersData = await ApiService.getWinners(year: year, state: 'Maharashtra', type: 'AC');
      final allData = await ApiService.getResults(year: year, state: 'Maharashtra');
      setState(() {
        _results = (winnersData['winners'] as List? ?? []);
        _allResults = (allData['results'] as List? ?? []).where((r) => r['constituency']?['type'] == 'AC').toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Map<String, int> _getPartySeats() {
    Map<String, int> seats = {};
    for (var r in _results) {
      if (r['is_winner'] == true) {
        final party = r['party']?['name'] ?? 'Others';
        seats[party] = (seats[party] ?? 0) + 1;
      }
    }
    final sorted = Map.fromEntries(
        seats.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return Map.fromEntries(sorted.entries.take(8));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? AppColors.bgSurface : Colors.white,
              floating: true,
              snap: true,
              elevation: 0,
              title: Text('Analytics',
                  style: TextStyle(
                      color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Seats Won by Party',
                      style: TextStyle(
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildBarChart(isDark),
                  const SizedBox(height: 20),

                  Text('Key Statistics',
                      style: TextStyle(
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildStats(isDark),
                  const SizedBox(height: 20),

                  Text('Alliance Summary',
                      style: TextStyle(
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildAllianceSummary(isDark),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    final partySeats = _getPartySeats();
    final entries = partySeats.entries.toList();
    final colors = [
      AppColors.bjpColor,
      AppColors.incColor,
      AppColors.aapColor,
      AppColors.accent,
      AppColors.accentOrange,
      AppColors.accentRed,
      AppColors.primaryLight,
      AppColors.otherColor,
    ];

    final borderColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED);
    final gridColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE8EDF2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: entries.isEmpty ? 100 : (entries.first.value.toDouble() * 1.2),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < entries.length) {
                          final name = entries[value.toInt()].key;
                          final short = name.length > 6 ? name.substring(0, 6) : name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(short,
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 8)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 9)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: gridColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((e) {
                  final color = colors[e.key % colors.length];
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        color: color,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    final winners = _results.where((r) => r['is_winner'] == true).toList();
    final totalVotes = _results.fold<int>(0, (sum, r) => sum + (r['votes'] as int? ?? 0));
    final avgVotes = winners.isEmpty ? 0 : (totalVotes / _results.length).round();

    return Row(
      children: [
        _statBox('Total Votes', _fmtLarge(totalVotes), AppColors.primary, isDark),
        const SizedBox(width: 12),
        _statBox('Avg Votes', _fmtLarge(avgVotes), AppColors.accentGreen, isDark),
      ],
    );
  }

  Widget _statBox(String title, String value, Color color, bool isDark) {
    final borderColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildAllianceSummary(bool isDark) {
    int mahayutiSeats = 0;
    int mvaSeats = 0;
    int othersSeats = 0;

    final mahayutiParties = ['Bharatiya Janata Party', 'Shiv Sena', 'Nationalist Congress Party'];
    final mvaParties = ['Indian National Congress', 'Shiv Sena (Uddhav Balasaheb Thackeray)', 'Nationalist Congress Party- Sharadchandra Pawar'];
    for (var r in _results) {
      final party = (r['party']?['name'] ?? '').toString();
      if (mahayutiParties.contains(party)) {
        mahayutiSeats++;
      } else if (mvaParties.contains(party)) {
        mvaSeats++;
      } else {
        othersSeats++;
      }
    }


    final totalSeats = mahayutiSeats + mvaSeats + othersSeats;
    return Column(
      children: [
        _allianceCard('Maha Yuti', mahayutiSeats, totalSeats, AppColors.bjpColor, isDark),
        const SizedBox(height: 10),
        _allianceCard('Maha Vikas Aghadi', mvaSeats, totalSeats, AppColors.incColor, isDark),
        const SizedBox(height: 10),
        _allianceCard('Others', othersSeats, totalSeats, AppColors.otherColor, isDark),
      ],
    );
  }

  Widget _allianceCard(String name, int seats, int total, Color color, bool isDark) {
    final pct = seats / total;
    final borderColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: TextStyle(
                      color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              Text('$seats seats',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: isDark ? AppColors.bgCardLight : const Color(0xFFE8EDF2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(pct * 100).toStringAsFixed(1)}% of $total seats',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  String _fmtLarge(int n) {
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}



