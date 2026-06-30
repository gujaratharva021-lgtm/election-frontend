import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ConstituencyScreen extends StatefulWidget {
  const ConstituencyScreen({super.key});

  @override
  State<ConstituencyScreen> createState() => _ConstituencyScreenState();
}

class _ConstituencyScreenState extends State<ConstituencyScreen> {
  List<dynamic> _results = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  int _selectedYear = 2024;
  Map<String, List<dynamic>> _constituencies = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getResults(year: _selectedYear, state: 'Maharashtra');
      final results = data['results'] as List? ?? [];

      Map<String, List<dynamic>> grouped = {};
      for (var r in results) {
        final name = r['constituency']?['name'] ?? 'Unknown';
        grouped[name] = grouped[name] ?? [];
        grouped[name]!.add(r);
      }

      setState(() {
        _results = results;
        _constituencies = grouped;
        _filtered = grouped.keys.toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _constituencies.keys.toList();
      } else {
        _filtered = _constituencies.keys
            .where((k) => k.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? AppColors.bgSurface : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Constituencies',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Container(
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _search,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search constituency...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                      filled: true,
                      fillColor: isDark ? AppColors.bgCardLight : const Color(0xFFF0F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('${_filtered.length} Constituencies',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),

            // List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final name = _filtered[index];
                  final candidates = _constituencies[name] ?? [];
                  final winner = candidates.firstWhere(
                          (c) => c['is_winner'] == true,
                      orElse: () => null);

                  return GestureDetector(
                    onTap: () => _showMyReps(name),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                                if (winner != null)
                                  Text(
                                    '${winner['candidate']?['name'] ?? ''} • ${winner['party']?['name'] ?? ''}',
                                    style: const TextStyle(
                                        color: AppColors.textMuted, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${candidates.length}',
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              const Text('candidates',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const FaIcon(FontAwesomeIcons.chevronRight,
                              size: 12, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMyReps(String constituencyName) {
    final isDark = context.read<ThemeProvider>().isDark;
    final candidates = _constituencies[constituencyName] ?? [];
    final amdar = candidates.firstWhere(
            (c) => c['is_winner'] == true, orElse: () => null);
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0A1628);
    final borderColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED);
    final cardBg = isDark ? AppColors.bgCardLight : const Color(0xFFF0F4F8);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgCard : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Your Representatives',
                style: TextStyle(
                    color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(constituencyName,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),

            if (amdar != null) ...[
              const Text('🏛️ Amdar (MLA)',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.accentGreen.withOpacity(0.15),
                      child: Text(
                        (amdar['candidate']?['name'] ?? '?')[0],
                        style: const TextStyle(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(amdar['candidate']?['name'] ?? 'Unknown',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text(amdar['party']?['name'] ?? '',
                              style: const TextStyle(
                                  color: AppColors.accent, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('MLA ✓',
                          style: TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('👥 See All Candidates',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showDetail(constituencyName, candidates);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: AppColors.accent, size: 18),
                    const SizedBox(width: 10),
                    Text('${candidates.length} candidates in $constituencyName',
                        style: TextStyle(color: textColor, fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        color: AppColors.textMuted, size: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDetail(String name, List<dynamic> candidates) {
    final isDark = context.read<ThemeProvider>().isDark;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0A1628);
    final borderColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgCard : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(name,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$_selectedYear',
                        style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Divider(color: borderColor),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: candidates.length,
                itemBuilder: (context, i) {
                  final r = candidates[i];
                  final cName = r['candidate']?['name'] ?? 'Unknown';
                  final party = r['party']?['name'] ?? 'Unknown';
                  final votes = r['votes'] ?? 0;
                  final votePercent = r['vote_percent'] ?? 0.0;
                  final isWinner = r['is_winner'] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? AppColors.accentGreen.withOpacity(0.08)
                          : isDark
                          ? AppColors.bgCardLight
                          : const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isWinner
                            ? AppColors.accentGreen.withOpacity(0.3)
                            : borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isWinner
                                ? AppColors.accentGreen.withOpacity(0.2)
                                : AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: TextStyle(
                                    color: isWinner
                                        ? AppColors.accentGreen
                                        : AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(cName,
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  if (isWinner)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGreen.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Winner',
                                          style: TextStyle(
                                              color: AppColors.accentGreen,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                ],
                              ),
                              Text(party,
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 10),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: votePercent / 100,
                                  backgroundColor: isDark
                                      ? AppColors.bgCardLight
                                      : const Color(0xFFE8EDF2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isWinner ? AppColors.accentGreen : AppColors.primary,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_fmt(votes),
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            Text('${votePercent.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}