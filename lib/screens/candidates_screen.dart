import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'candidate_detail_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Amdar
  List<dynamic> _amdars = [];
  List<dynamic> _filteredAmdars = [];

  // All Candidates
  List<dynamic> _candidates = [];
  List<dynamic> _khasdars = [];
  List<dynamic> _filteredKhasdars = [];
  List<dynamic> _filteredCandidates = [];

  bool _loading = true;
  String _selectedParty = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<String> _parties = ['All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
      _search(_searchController.text);
    });
    _loadData();
  }

  int _lastYear = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final year = context.watch<YearProvider>().year;
    if (year != _lastYear) {
      _lastYear = year;
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final year = context.read<YearProvider>().year;
      final winnersData = await ApiService.getWinners(year: year, type: 'MLA');
      final allData = await ApiService.getResults(year: year, state: 'Maharashtra', type: 'AC');
      final khasdarData = await ApiService.getKhasdars(year: year);

      final winners = winnersData['winners'] as List? ?? [];
      final all = allData['results'] as List? ?? [];

      setState(() {
        _amdars = winners;
        _filteredAmdars = winners;
        _candidates = all;
        _khasdars = khasdarData['khasdars'] as List? ?? [];
        _filteredKhasdars = _khasdars;
        _filteredCandidates = all;
        final partyNames = all
            .map((r) => r['party']?['name'] as String? ?? '')
            .where((p) => p.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        _parties = ['All', ...partyNames];
        _loading = false;
      });
    } catch (e) {
      print('CANDIDATES SCREEN ERROR: $e');
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    _search(_searchController.text);
  }

  void _search(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredAmdars = _amdars.where((r) {
        final name = r['candidate']?['name']?.toLowerCase() ?? '';
        final party = r['party']?['name']?.toLowerCase() ?? '';
        final constituency = r['constituency']?['name']?.toLowerCase() ?? '';
        return name.contains(q) || party.contains(q) || constituency.contains(q);
      }).toList();

      _filteredKhasdars = _khasdars.where((r) {
        final name = r['candidate']?.toLowerCase() ?? '';
        final party = r['party']?.toLowerCase() ?? '';
        final pc = r['pc_name']?.toLowerCase() ?? '';
        return name.contains(q) || party.contains(q) || pc.contains(q);
      }).toList();

      _filteredCandidates = _candidates.where((r) {
        final name = r['candidate']?['name']?.toLowerCase() ?? '';
        final party = r['party']?['name']?.toLowerCase() ?? '';
        return name.contains(q) || party.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final year = context.watch<YearProvider>().year;
    if (year != _lastYear) {
      _lastYear = year;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              color: isDark ? AppColors.bgSurface : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Representatives',
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          )),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _tabController.index == 0
                              ? '${_filteredAmdars.length} Amdars'
                              : _tabController.index == 1
                              ? '${_filteredKhasdars.length} MPs'
                              : '${_filteredCandidates.length} Results',
                          style: const TextStyle(color: AppColors.accent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search
                  TextField(
                    controller: _searchController,
                    onChanged: _search,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search name, party, constituency...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                      filled: true,
                      fillColor: isDark ? AppColors.bgCardLight : const Color(0xFFF0F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Party Filter
                  if (_tabController.index == 0) SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _parties.length,
                      itemBuilder: (context, index) {
                        final party = _parties[index];
                        final selected = _selectedParty == party;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedParty = party);
                            _applyFilters();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent
                                  : isDark
                                  ? AppColors.bgCardLight
                                  : const Color(0xFFE8EDF2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accent
                                    : isDark
                                    ? const Color(0xFF1E2A3A)
                                    : const Color(0xFFDDE3ED),
                              ),
                            ),
                            child: Text(
                              party,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.bgDark
                                    : isDark
                                    ? AppColors.textMuted
                                    : const Color(0xFF556677),
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_tabController.index == 1) const SizedBox(height: 0),
                  const SizedBox(height: 8),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.accent,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [
                      Tab(text: 'MLA'),
                      Tab(text: 'MP'),
                      Tab(text: 'All'),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildAmdarList(),
                  _buildKhasdarList(),
                  _buildCandidateList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmdarList() {
    final isDark = context.watch<ThemeProvider>().isDark;
    if (_filteredAmdars.isEmpty) {
      return const Center(
          child: Text('No Amdars found', style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAmdars.length,
      itemBuilder: (context, index) {
        final r = _filteredAmdars[index];
        final name = r['candidate']?['name'] ?? 'Unknown';
        final party = r['party']?['name'] ?? 'Unknown';
        final constituency = r['constituency']?['name'] ?? '';
        final votes = r['votes'] ?? 0;
        final votePercent = r['vote_percent'] ?? 0.0;

        return GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => CandidateDetailScreen(result: r))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.accentGreen.withOpacity(0.15),
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(
                        color: AppColors.accentGreen, fontWeight: FontWeight.w700, fontSize: 16),
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
                            child: Text(
                              name,
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('MLA ✓',
                                style: TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(party,
                          style: const TextStyle(color: AppColors.accent, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                      Text(constituency,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_fmt(votes),
                        style: const TextStyle(
                            color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('${votePercent.toStringAsFixed(1)}%',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCandidateList() {
    final isDark = context.watch<ThemeProvider>().isDark;
    if (_filteredCandidates.isEmpty) {
      return const Center(
          child: Text('No candidates found', style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCandidates.length,
      itemBuilder: (context, index) {
        final r = _filteredCandidates[index];
        final name = r['candidate']?['name'] ?? 'Unknown';
        final party = r['party']?['name'] ?? 'Unknown';
        final votes = r['votes'] ?? 0;
        final isWinner = r['is_winner'] ?? false;
        final votePercent = r['vote_percent'] ?? 0.0;

        return GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => CandidateDetailScreen(result: r))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWinner
                    ? AppColors.accentGreen.withOpacity(0.3)
                    : isDark
                    ? const Color(0xFF1E2A3A)
                    : const Color(0xFFDDE3ED),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isWinner
                      ? AppColors.accentGreen.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(
                        color: isWinner ? AppColors.accentGreen : AppColors.accent,
                        fontWeight: FontWeight.w700),
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
                            child: Text(
                              name,
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isWinner)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Winner',
                                  style: TextStyle(
                                      color: AppColors.accentGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      Text(party,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_fmt(votes),
                        style: const TextStyle(
                            color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('${votePercent.toStringAsFixed(1)}%',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKhasdarList() {
    final isDark = context.watch<ThemeProvider>().isDark;
    if (_filteredKhasdars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_vote_outlined,
                size: 64,
                color: Colors.orange.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'MP Data Coming Soon',
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lok Sabha 2024 results\nwill be available shortly',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredKhasdars.length,
      itemBuilder: (context, index) {
        final r = _filteredKhasdars[index];
        final name = r['candidate'] ?? 'Unknown';
        final party = r['party'] ?? 'Unknown';
        final pcName = r['pc_name'] ?? '';
        final votes = r['total_votes'] ?? 0;
        final voteShare = r['vote_share'] ?? 0.0;

        return GestureDetector(
          onTap: () {
            final resultMap = {
              'candidate': {'name': r['candidate'] ?? 'Unknown'},
              'party': {'name': r['party'] ?? 'Unknown'},
              'constituency': {'name': r['pc_name'] ?? ''},
              'votes': r['total_votes'] ?? 0,
              'vote_percent': r['vote_share'] ?? 0.0,
              'is_winner': true,
              'election_year': r['year'] ?? 2024,
              'type': 'MP',
            };
            Navigator.push(context, MaterialPageRoute(builder: (_) => CandidateDetailScreen(result: resultMap)));
          },
          child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.orange.withOpacity(0.15),
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.w700, fontSize: 16),
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
                          child: Text(
                            name,
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimary : const Color(0xFF0A1628),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('MP ✓',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(party,
                        style: const TextStyle(color: AppColors.accent, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                    Text(pcName,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmt(votes),
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('${voteShare.toStringAsFixed(1)}%',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  String _fmt(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}