import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class CandidateDetailScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const CandidateDetailScreen({super.key, required this.result});

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final result = widget.result;
    final name = result['candidate']?['name'] ?? 'Unknown';
    final party = result['party']?['name'] ?? 'Unknown';
    final votes = result['votes'] ?? 0;
    final votePercent = result['vote_percent'] ?? 0.0;
    final isWinner = result['is_winner'] ?? false;
    final constituency = result['constituency']?['name'] ?? 'Unknown';
    final year = result['election_year'] ?? 2024;

    final borderColor = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDE3ED);
    final cardColor = isDark ? AppColors.bgCard : Colors.white;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0A1628);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.bgSurface : Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isWinner
                        ? [AppColors.accentGreen.withOpacity(0.3), isDark ? AppColors.bgSurface : Colors.white]
                        : [AppColors.primary.withOpacity(0.3), isDark ? AppColors.bgSurface : Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: isWinner
                          ? AppColors.accentGreen.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.2),
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: TextStyle(
                          color: isWinner ? AppColors.accentGreen : AppColors.accent,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name,
                        style: TextStyle(
                            color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(party,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Winner Badge
                if (isWinner)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.trophy, color: AppColors.accentGreen, size: 20),
                        SizedBox(width: 12),
                        Text('Winner — Elected ${result['type'] ?? 'MLA'}',
                            style: TextStyle(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                if (isWinner) const SizedBox(height: 16),

                // Stats Cards
                Row(
                  children: [
                    _statCard('Total Votes', _fmt(votes), FontAwesomeIcons.voteYea,
                        AppColors.accent, cardColor, borderColor),
                    const SizedBox(width: 12),
                    _statCard('Vote Share', '${votePercent.toStringAsFixed(1)}%',
                        FontAwesomeIcons.chartPie, AppColors.primary, cardColor, borderColor),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statCard('Year', '$year', FontAwesomeIcons.calendar,
                        AppColors.accentGreen, cardColor, borderColor),
                    const SizedBox(width: 12),
                    _statCard('Constituency', constituency, FontAwesomeIcons.mapPin,
                        AppColors.accentOrange, cardColor, borderColor),
                  ],
                ),
                const SizedBox(height: 20),

                // Vote Progress
                Text('Vote Share',
                    style: TextStyle(
                        color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(party,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                          Text('${votePercent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: votePercent / 100,
                          backgroundColor:
                          isDark ? AppColors.bgCardLight : const Color(0xFFE8EDF2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isWinner ? AppColors.accentGreen : AppColors.primary,
                          ),
                          minHeight: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info
                Text('Details',
                    style: TextStyle(
                        color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Party', party, textColor, borderColor),
                      _infoRow('Constituency', constituency, textColor, borderColor),
                      _infoRow('Election Year', '$year', textColor, borderColor),
                      _infoRow('Status', isWinner ? '✅ Winner' : '❌ Lost', textColor, borderColor),
                      _infoRow('Total Votes', _fmt(votes), textColor, borderColor),
                      _infoRow('Vote Share', '${votePercent.toStringAsFixed(2)}%', textColor, borderColor, last: true),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color,
      Color cardColor, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, color: color, size: 16),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis),
            Text(title,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color textColor, Color borderColor,
      {bool last = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              Flexible(
                child: Text(value,
                    style: TextStyle(
                        color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        if (!last) Divider(color: borderColor, height: 1),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}