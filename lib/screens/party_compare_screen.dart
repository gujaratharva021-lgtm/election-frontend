import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class PartyCompareScreen extends StatefulWidget {
  final Map<String, dynamic> initialParty;
  final List<dynamic> allParties;

  const PartyCompareScreen({
    super.key,
    required this.initialParty,
    required this.allParties,
  });

  @override
  State<PartyCompareScreen> createState() => _PartyCompareScreenState();
}

class _PartyCompareScreenState extends State<PartyCompareScreen> {
  Map<String, dynamic>? _party1;
  Map<String, dynamic>? _party2;
  Map<String, dynamic>? _compareData;
  bool _loading = false;
  int _selectedYear = 2024;

  final List<int> _years = [2024, 2019, 2014, 2009];

  @override
  void initState() {
    super.initState();
    _party1 = widget.initialParty;
  }

  Future<void> _compare() async {
    if (_party1 == null || _party2 == null) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.compareParties(
        party1: _party1!['short_name'] ?? _party1!['name'],
        party2: _party2!['short_name'] ?? _party2!['name'],
        year: _selectedYear,
        state: 'Maharashtra',
      );
      setState(() {
        _compareData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().isDark ? AppColors.bgDark : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: context.watch<ThemeProvider>().isDark ? AppColors.bgSurface : Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const FaIcon(FontAwesomeIcons.arrowLeft,
                        color: AppColors.textPrimary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text('Party Compare',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  // Year selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E2A3A)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        dropdownColor: AppColors.bgCard,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13),
                        items: _years
                            .map((y) => DropdownMenuItem(
                            value: y, child: Text('$y')))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedYear = v!);
                          if (_compareData != null) _compare();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Party selectors
                    Row(
                      children: [
                        Expanded(child: _partySelector(1)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('VS',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                        ),
                        Expanded(child: _partySelector(2)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Compare button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_party1 != null && _party2 != null)
                            ? _compare
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                          AppColors.bgCard,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2))
                            : const Text('Compare Now',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                    ),

                    if (_compareData != null) ...[
                      const SizedBox(height: 24),
                      _buildCompareResults(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partySelector(int slot) {
    final selected = slot == 1 ? _party1 : _party2;
    final color = slot == 1 ? AppColors.bjpColor : AppColors.incColor;

    return GestureDetector(
      onTap: () => _showPartyPicker(slot),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected != null ? color : const Color(0xFF1E2A3A),
              width: selected != null ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  selected != null
                      ? (selected['name'] as String)[0]
                      : '+',
                  style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selected != null
                  ? (selected['short_name'] ?? selected['name'])
                  : 'Select Party',
              style: TextStyle(
                  color: selected != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showPartyPicker(int slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.watch<ThemeProvider>().isDark ? AppColors.bgSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Select Party',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: widget.allParties.length,
              itemBuilder: (_, i) {
                final p = widget.allParties[i];
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        (p['name'] as String)[0],
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  title: Text(p['name'],
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13)),
                  subtitle: Text(p['alliance'] ?? '',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                  onTap: () {
                    setState(() {
                      if (slot == 1) {
                        _party1 = p;
                      } else {
                        _party2 = p;
                      }
                      _compareData = null;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareResults() {
    final p1data = _compareData!['party1'];
    final p2data = _compareData!['party2'];
    final p1summary = p1data['summary'] ?? {};
    final p2summary = p2data['summary'] ?? {};
    final p1trend = (p1data['trend'] as List?) ?? [];
    final p2trend = (p2data['trend'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Head to head stats
        const Text('Head to Head',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _buildStatComparison(
          label: 'Seats Won',
          v1: (p1summary['seats_won'] ?? 0).toDouble(),
          v2: (p2summary['seats_won'] ?? 0).toDouble(),
          suffix: '',
          p1name: p1data['short_name'] ?? '',
          p2name: p2data['short_name'] ?? '',
        ),
        const SizedBox(height: 8),
        _buildStatComparison(
          label: 'Vote Share',
          v1: (p1summary['vote_share'] ?? 0.0).toDouble(),
          v2: (p2summary['vote_share'] ?? 0.0).toDouble(),
          suffix: '%',
          p1name: p1data['short_name'] ?? '',
          p2name: p2data['short_name'] ?? '',
        ),
        const SizedBox(height: 8),
        _buildStatComparison(
          label: 'Seats Contested',
          v1: (p1summary['seats_contested'] ?? 0).toDouble(),
          v2: (p2summary['seats_contested'] ?? 0).toDouble(),
          suffix: '',
          p1name: p1data['short_name'] ?? '',
          p2name: p2data['short_name'] ?? '',
        ),

        if (p1trend.isNotEmpty && p2trend.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Vote Share Over Time',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildTrendChart(p1trend, p2trend, p1data, p2data),
        ],
      ],
    );
  }

  Widget _buildStatComparison({
    required String label,
    required double v1,
    required double v2,
    required String suffix,
    required String p1name,
    required String p2name,
  }) {
    final total = v1 + v2;
    final p1pct = total == 0 ? 0.5 : v1 / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${v1 % 1 == 0 ? v1.toInt() : v1.toStringAsFixed(1)}$suffix',
                style: const TextStyle(
                    color: AppColors.bjpColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18),
              ),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
              Text(
                '${v2 % 1 == 0 ? v2.toInt() : v2.toStringAsFixed(1)}$suffix',
                style: const TextStyle(
                    color: AppColors.incColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Split bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: (p1pct * 100).round(),
                  child: Container(height: 8, color: AppColors.bjpColor),
                ),
                Expanded(
                  flex: ((1 - p1pct) * 100).round(),
                  child: Container(height: 8, color: AppColors.incColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p1name,
                  style: const TextStyle(
                      color: AppColors.bjpColor, fontSize: 10)),
              Text(p2name,
                  style: const TextStyle(
                      color: AppColors.incColor, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List p1trend, List p2trend,
      Map p1data, Map p2data) {
    // years collect karo
    final allYears = <int>{};
    for (var t in p1trend) allYears.add(t['year'] as int);
    for (var t in p2trend) allYears.add(t['year'] as int);
    final years = allYears.toList()..sort();

    if (years.isEmpty) return const SizedBox();

    List<FlSpot> spots1 = [];
    List<FlSpot> spots2 = [];

    for (int i = 0; i < years.length; i++) {
      final y = years[i];
      final t1 = p1trend.firstWhere((t) => t['year'] == y,
          orElse: () => null);
      final t2 = p2trend.firstWhere((t) => t['year'] == y,
          orElse: () => null);
      if (t1 != null)
        spots1.add(FlSpot(i.toDouble(),
            (t1['vote_share'] as num).toDouble()));
      if (t2 != null)
        spots2.add(FlSpot(i.toDouble(),
            (t2['vote_share'] as num).toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => const FlLine(
                      color: Color(0xFF1E2A3A), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < years.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('${years[idx]}',
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 9)),
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
                      getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}%',
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9)),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots1,
                    isCurved: true,
                    color: AppColors.bjpColor,
                    barWidth: 2.5,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.bjpColor.withOpacity(0.08),
                    ),
                  ),
                  LineChartBarData(
                    spots: spots2,
                    isCurved: true,
                    color: AppColors.incColor,
                    barWidth: 2.5,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.incColor.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.bjpColor,
                  p1data['short_name'] ?? ''),
              const SizedBox(width: 20),
              _legendDot(AppColors.incColor,
                  p2data['short_name'] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}