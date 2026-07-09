  import 'package:flutter/material.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import 'package:fl_chart/fl_chart.dart';
  import 'package:provider/provider.dart';
  import '../theme/app_theme.dart';
  import '../services/api_service.dart';
  import '../main.dart';
  import 'settings_screen.dart';
  import 'ai_screen.dart';
import 'analytics_screen.dart';
  import 'package:url_launcher/url_launcher.dart';
  
  class DashboardScreen extends StatefulWidget {
    const DashboardScreen({super.key});
  
    @override
    State<DashboardScreen> createState() => _DashboardScreenState();
  }
  
  class _DashboardScreenState extends State<DashboardScreen> {
    Map<String, dynamic>? _results;
    Map<String, dynamic>? _winners;
    Map<String, dynamic>? _summary;
    Map<String, dynamic>? _trends;
    bool _loading = true;
    int _selectedYear = 2024;
    final String _selectedState = 'Maharashtra';
  
    @override
    void initState() {
      super.initState();
      _loadData();
    }
  
    Future<void> _loadData() async {
      setState(() => _loading = true);
      try {
        final responses = await Future.wait([
          ApiService.getResultsCount(year: _selectedYear, state: _selectedState),
          ApiService.getWinners(year: _selectedYear, state: _selectedState),
          ApiService.getPartySummary(year: _selectedYear, state: _selectedState, type: 'AC'),
          ApiService.getVoteTrends(state: _selectedState),
        ]);
        setState(() {
          _results = responses[0];
          _winners = responses[1];
          _summary = responses[2];
          _trends = responses[3];
          _loading = false;
        });
      } catch (e) {
        print('ERROR: $e');
        setState(() => _loading = false);
      }
    }
  
    @override
    Widget build(BuildContext context) {
      final isDark = context.watch<ThemeProvider>().isDark;
      final bg = isDark ? AppColors.bgDark : const Color(0xFFF5F7FA);
      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : _buildBody(isDark),
        ),
      );
    }
  
    Widget _buildBody(bool isDark) {
      final totalResults = _results?['count'] ?? 0;
      final winners = _winners?['winners'] as List? ?? [];
  
      final summaryList = (_summary?['summary'] as List? ?? []);
      summaryList.sort((a, b) =>
          ((b['seats_won'] ?? 0) as num).compareTo((a['seats_won'] ?? 0) as num));
      final top5Parties = summaryList.where((p) => (p['seats_won'] ?? 0) > 0).take(5).toList();
      final totalSeats = summaryList.fold<int>(0, (sum, p) => sum + ((p['seats_won'] ?? 0) as int));
  
      final rawTrends = _trends ?? {};
      final trendData = (rawTrends['trends'] ?? rawTrends['data'] ?? rawTrends['results'] ?? []) as List;
  
      final surface = isDark ? AppColors.bgSurface : Colors.white;
      final card = isDark ? AppColors.bgCard : Colors.white;
      final cardLight = isDark ? AppColors.bgCardLight : const Color(0xFFF0F2F5);
      final border = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE0E0E0);
      final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E);
      final textMuted = isDark ? AppColors.textMuted : const Color(0xFF90A4AE);
      final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF546E7A);
      final gridLine = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE0E0E0);
  
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: surface,
            floating: true,
            snap: true,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Election Data', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    Text('Maharashtra Election Intelligence', style: TextStyle(color: textMuted, fontSize: 10)),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: cardLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    dropdownColor: card,
                    style: TextStyle(color: textPrimary, fontSize: 12),
                    icon: Icon(Icons.keyboard_arrow_down, color: textMuted, size: 14),
                    isDense: true,
                    items: [2024, 2019, 2014, 2009, 2004].map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (val) { setState(() => _selectedYear = val!); context.read<YearProvider>().setYear(val!); _loadData(); },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: Stack(
                    children: [
                      CircleAvatar(radius: 16, backgroundImage: const AssetImage('assets/images/avatar.png'), backgroundColor: AppColors.primary),
                      Positioned(bottom: 0, right: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))),
                    ],
                  ),
                ),
              ),
            ],
          ),
  
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildLiveBanner(card, border, textPrimary, textMuted),
                const SizedBox(height: 20),
                Text('Dashboard Overview', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                Row(children: [
                  _statCard(title: 'Constituencies', value: '288', subtitle: 'Maharashtra', icon: FontAwesomeIcons.mapLocation, color: AppColors.primary, card: card, border: border, textMuted: textMuted, textPrimary: textPrimary),
                  const SizedBox(width: 12),
                  _statCard(title: 'Total Seats', value: '$totalSeats', subtitle: 'Total in Maharashtra', icon: FontAwesomeIcons.landmark, color: AppColors.accentGreen, card: card, border: border, textMuted: textMuted, textPrimary: textPrimary),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _statCard(title: 'Candidates', value: '$totalResults', subtitle: 'Total registered', icon: FontAwesomeIcons.peopleGroup, color: AppColors.accentOrange, card: card, border: border, textMuted: textMuted, textPrimary: textPrimary),
                  const SizedBox(width: 12),
                  _statCard(title: 'Winners', value: '${winners.length}', subtitle: 'Declared so far', icon: FontAwesomeIcons.award, color: AppColors.accent, card: card, border: border, textMuted: textMuted, textPrimary: textPrimary),
                ]),
                const SizedBox(height: 20),
  
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Seat Distribution', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                      child: Row(children: [
                        Text('View Details', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                        const Icon(Icons.chevron_right, color: AppColors.accent, size: 16),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDonutChart(top5Parties, totalSeats, card, border, textPrimary, textSecondary, textMuted),
                const SizedBox(height: 20),
                Text('Top Winners', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _buildTopCandidates(winners, card, border, textPrimary, textMuted),
                const SizedBox(height: 20),
                _buildAiPrediction(top5Parties, card, border, textPrimary, textMuted),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      );
    }
  
    Widget _buildLiveBanner(Color card, Color border, Color textPrimary, Color textMuted) {
      final now = TimeOfDay.now();
      final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
      final min = now.minute.toString().padLeft(2, '0');
      final period = now.period == DayPeriod.am ? 'AM' : 'PM';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.red.withOpacity(0.4))),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Counting in Progress', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            Text('Last updated: $hour:$min $period', style: TextStyle(color: textMuted, fontSize: 10)),
          ])),
          GestureDetector(
            onTap: () async {
              final url = Uri.parse('https://maps.google.com/?q=Maharashtra,India');
              if (await canLaunchUrl(url)) {
                launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Row(children: [
              const Icon(Icons.location_on, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Text('View Live Map', style: TextStyle(color: AppColors.accent, fontSize: 12)),
              const Icon(Icons.chevron_right, color: AppColors.accent, size: 16),
            ]),
          ),
        ]),
      );
    }
  
    Widget _statCard({required String title, required String value, required String subtitle, required FaIconData icon, required Color color, required Color card, required Color border, required Color textMuted, required Color textPrimary}) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Center(child: FaIcon(icon, color: color, size: 18))),
              Icon(Icons.chevron_right, color: textMuted, size: 16),
            ]),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
            Text(value, style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
    }
  
    Widget _buildTrendChart(List trendData, Color card, Color border, Color textPrimary, Color textMuted, Color gridLine) {
      final sorted = [...trendData]..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
      List<double> bjpData = [], incData = [], ncpData = [];
      List<String> years = [];
      for (var t in sorted) {
        years.add('${(t['year'] as int) % 100}');
        bjpData.add((t['BJP'] ?? t['bjp'] ?? t['Bharatiya Janata Party'] ?? 0.0).toDouble());
        incData.add((t['INC'] ?? t['inc'] ?? t['Indian National Congress'] ?? 0.0).toDouble());
        ncpData.add((t['NCP'] ?? t['ncp'] ?? t['Nationalist Congress Party'] ?? 0.0).toDouble());
      }
      if (bjpData.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: Center(child: Text('No trend data available', style: TextStyle(color: textMuted))),
        );
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Column(children: [
          Align(alignment: Alignment.centerRight, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: textMuted.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('% Share', style: TextStyle(color: textMuted, fontSize: 11)),
              Icon(Icons.keyboard_arrow_down, color: textMuted, size: 14),
            ]),
          )),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: gridLine, strokeWidth: 1)),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, m) {
                final i = v.round();
                if (i >= 0 && i < years.length && v == i.toDouble()) return Text(years[i], style: TextStyle(color: textMuted, fontSize: 10));
                return const Text('');
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: TextStyle(color: textMuted, fontSize: 9)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0, maxX: (years.length - 1).toDouble(), minY: 10, maxY: 35,
            lineBarsData: [
              _line(bjpData, AppColors.bjpColor, card),
              _line(incData, AppColors.incColor, card),
              _line(ncpData, AppColors.aapColor, card),
            ],
          ))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _endLabel('${bjpData.last.toStringAsFixed(1)}%', AppColors.bjpColor),
            const SizedBox(width: 6),
            _endLabel('${incData.last.toStringAsFixed(1)}%', AppColors.incColor),
            const SizedBox(width: 6),
            _endLabel('${ncpData.last.toStringAsFixed(1)}%', AppColors.aapColor),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legend('BJP', AppColors.bjpColor, textMuted),
            const SizedBox(width: 16),
            _legend('INC', AppColors.incColor, textMuted),
            const SizedBox(width: 16),
            _legend('NCP', AppColors.aapColor, textMuted),
          ]),
        ]),
      );
    }
  
    Widget _endLabel(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  
    LineChartBarData _line(List<double> values, Color color, Color card) => LineChartBarData(
      spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true, color: color, barWidth: 2.5,
      dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 3, color: color, strokeWidth: 2, strokeColor: card)),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
    );
  
    Widget _legend(String label, Color color, Color textMuted) => Row(children: [
      Container(width: 16, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: textMuted, fontSize: 11)),
    ]);
  
    Widget _buildDonutChart(List top5Parties, int totalSeats, Color card, Color border, Color textPrimary, Color textSecondary, Color textMuted) {
      final colors = [AppColors.bjpColor, AppColors.incColor, AppColors.aapColor, Colors.purple, AppColors.otherColor];
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: top5Parties.isEmpty
            ? Center(child: Text('No data', style: TextStyle(color: textMuted)))
            : Row(children: [
          SizedBox(width: 140, height: 140, child: Stack(alignment: Alignment.center, children: [
            PieChart(PieChartData(
              sectionsSpace: 2, centerSpaceRadius: 40,
              sections: top5Parties.asMap().entries.map((e) {
                final seats = (e.value['seats_won'] ?? 0) as int;
                return PieChartSectionData(value: seats.toDouble(), color: colors[e.key % colors.length], radius: 35, showTitle: false);
              }).toList(),
            )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$totalSeats', style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              Text('Total Seats', style: TextStyle(color: textMuted, fontSize: 9)),
            ]),
          ])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: top5Parties.asMap().entries.map((e) {
            final color = colors[e.key % colors.length];
            final name = e.value['party_name'] ?? 'Unknown';
            final seats = (e.value['seats_won'] ?? 0) as int;
            final pct = totalSeats > 0 ? (seats / totalSeats * 100).toStringAsFixed(1) : '0';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: TextStyle(color: textPrimary, fontSize: 11), overflow: TextOverflow.ellipsis),
                  Text('$seats Seats', style: TextStyle(color: textMuted, fontSize: 9)),
                ])),
                Text('$pct%', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            );
          }).toList())),
        ]),
      );
    }
  
    Widget _buildTopCandidates(List winners, Color card, Color border, Color textPrimary, Color textMuted) {
      return Column(children: winners.take(5).toList().asMap().entries.map((e) {
        final r = e.value;
        final name = r['candidate']?['name'] ?? 'Unknown';
        final party = r['party']?['name'] ?? 'Unknown';
        final votes = r['votes'] ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
          child: Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 13)))),
            const SizedBox(width: 12),
            CircleAvatar(radius: 18, backgroundColor: AppColors.primary,
                child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
              Text(party, style: TextStyle(color: textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_fmt(votes), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 15)),
              Text('votes', style: TextStyle(color: textMuted, fontSize: 10)),
            ]),
          ]),
        );
      }).toList());
    }
  
    Widget _buildAiPrediction(List top5Parties, Color card, Color border, Color textPrimary, Color textMuted) {
      final leading = top5Parties.isNotEmpty ? top5Parties.first : null;
      final leadingName = leading?['party_name'] ?? 'BJP';
      final leadingSeats = (leading?['seats_won'] ?? 0) as int;
      final prediction = leadingSeats >= 145
          ? '$leadingName is leading in $leadingSeats seats. Likely to form government.'
          : '$leadingName is leading in $leadingSeats seats. Hung assembly likely.';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.accent.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Row(children: [
          Container(width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.smart_toy_outlined, color: AppColors.accent, size: 22))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('AI Prediction', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(width: 4),
              const Icon(Icons.auto_awesome, color: AppColors.accent, size: 14),
            ]),
            Text(prediction, style: TextStyle(color: textMuted, fontSize: 11)),
          ])),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiScreen())),
            child: Row(children: [
              Text('View Prediction', style: TextStyle(color: AppColors.accent, fontSize: 12)),
              const Icon(Icons.chevron_right, color: AppColors.accent, size: 16),
            ]),
          ),
        ]),
      );
    }
  
    String _fmt(int n) {
      if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
      return '$n';
    }
  }

