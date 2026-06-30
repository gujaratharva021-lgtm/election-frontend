import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _summary;
  bool _loading = true;

  // Chat
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  bool _chatLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final summary = await ApiService.getPartySummary(year: 2024, state: 'Maharashtra');
      setState(() { _summary = summary; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage(String msg) async {
    if (msg.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': msg});
      _chatLoading = true;
    });
    _chatController.clear();
    _scrollToBottom();

    try {
      final summaryList = (_summary?['summary'] as List? ?? [])
          .where((p) => (p['seats_won'] ?? 0) > 0)
          .take(8)
          .toList();
      final context = summaryList.map((p) =>
      '${p['party_name']}: ${p['seats_won']} seats, ${p['avg_vote_share']}% vote share').join('\n');

      const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [{'text': '''You are POLITICA AI, an expert on Maharashtra elections.
Current 2024 Maharashtra Election Data:
$context
Total seats: 288. Majority needed: 145.
Answer questions about Maharashtra elections concisely. Be factual and data-driven.'''}]
          },
          'contents': _messages.map((m) => {
            'role': m['role'] == 'assistant' ? 'model' : 'user',
            'parts': [{'text': m['content']}]
          }).toList(),
        }),
      );

      final data = jsonDecode(response.body);
      print('GEMINI RESPONSE: ${response.body}');
      final candidates = data['candidates'];
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates in response: ${response.body}');
      }
      final reply = candidates[0]['content']['parts'][0]['text'] ?? 'Sorry, could not get response.';
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _chatLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('GEMINI ERROR: $e');
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Error: $e'});
        _chatLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.bgDark : const Color(0xFFF5F7FA);
    final surface = isDark ? AppColors.bgSurface : Colors.white;
    final card = isDark ? AppColors.bgCard : Colors.white;
    final border = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE0E0E0);
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF90A4AE);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              color: surface,
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AI Intelligence', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('Powered by Gemini AI', style: TextStyle(color: textMuted, fontSize: 11)),
                  ]),
                  const Spacer(),
                  const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
                ],
              ),
            ),

            // ── TABS ────────────────────────────────
            Container(
              color: surface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Win Probability'),
                  Tab(text: 'Seat Prediction'),
                ],
              ),
            ),

            // ── TAB CONTENT ─────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildWinProbability(card, border, textPrimary, textMuted),
                  _buildSeatPrediction(card, border, textPrimary, textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIN PROBABILITY ───────────────────────────────────
  Widget _buildWinProbability(Color card, Color border, Color textPrimary, Color textMuted) {
    final summaryList = (_summary?['summary'] as List? ?? [])
        .where((p) => (p['seats_won'] ?? 0) > 0)
        .toList();
    summaryList.sort((a, b) => ((b['seats_won'] ?? 0) as num).compareTo((a['seats_won'] ?? 0) as num));

    final totalSeats = summaryList.fold<int>(0, (s, p) => s + ((p['seats_won'] ?? 0) as int));
    final colors = [AppColors.bjpColor, AppColors.incColor, AppColors.aapColor, Colors.purple, AppColors.otherColor, Colors.teal, Colors.pink];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Majority indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.accent.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Majority Mark: ${(totalSeats / 2).ceil()} seats', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              Text('Total declared seats: $totalSeats', style: TextStyle(color: textMuted, fontSize: 11)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        ...summaryList.asMap().entries.map((e) {
          final p = e.value;
          final color = colors[e.key % colors.length];
          final seats = (p['seats_won'] ?? 0) as int;
          final voteShare = (p['avg_vote_share'] ?? 0.0) as double;
          final probability = ((seats / totalSeats) * 100).clamp(0, 100);
          final canForm = seats >= (totalSeats / 2).ceil();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: canForm ? color.withOpacity(0.5) : border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(p['party_name'] ?? '', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                if (canForm) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Majority', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${seats} seats', style: TextStyle(color: textMuted, fontSize: 11)),
                Text('${voteShare.toStringAsFixed(1)}% vote share', style: TextStyle(color: textMuted, fontSize: 11)),
                Text('${probability.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: probability / 100,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ]),
          );
        }).toList(),
      ],
    );
  }

  // ── SEAT PREDICTION ───────────────────────────────────
  Widget _buildSeatPrediction(Color card, Color border, Color textPrimary, Color textMuted) {
    final summaryList = (_summary?['summary'] as List? ?? [])
        .where((p) => (p['seats_won'] ?? 0) > 0)
        .toList();
    summaryList.sort((a, b) => ((b['seats_won'] ?? 0) as num).compareTo((a['seats_won'] ?? 0) as num));

    final colors = [AppColors.bjpColor, AppColors.incColor, AppColors.aapColor, Colors.purple, AppColors.otherColor, Colors.teal, Colors.pink];
    final totalSeats = summaryList.fold<int>(0, (s, p) => s + ((p['seats_won'] ?? 0) as int));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('2024 Seat Distribution', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Based on actual election results', style: TextStyle(color: textMuted, fontSize: 12)),
        const SizedBox(height: 16),

        // Bar chart style
        ...summaryList.asMap().entries.map((e) {
          final p = e.value;
          final color = colors[e.key % colors.length];
          final seats = (p['seats_won'] ?? 0) as int;
          final pct = totalSeats > 0 ? seats / totalSeats : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 140, child: Text(p['party_name'] ?? '', style: TextStyle(color: textPrimary, fontSize: 11), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct.toDouble(),
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 20,
                ),
              )),
              const SizedBox(width: 8),
              SizedBox(width: 30, child: Text('$seats', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12))),
            ]),
          );
        }).toList(),
      ],
    );
  }

  // ── CHATBOT ───────────────────────────────────────────
  Widget _buildChatbot(Color card, Color border, Color textPrimary, Color textMuted, Color surface) {
    return Column(
      children: [
        // Messages
        Expanded(
          child: _messages.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.smart_toy_outlined, color: AppColors.accent, size: 48),
            const SizedBox(height: 12),
            Text('Ask me anything about\nMaharashtra Elections!', textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 14)),
            const SizedBox(height: 20),
            // Suggested questions
            _suggestedQuestion('Who won the most seats?', textMuted),
            _suggestedQuestion('Which party can form government?', textMuted),
            _suggestedQuestion('What is BJP\'s vote share?', textMuted),
          ]))
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_chatLoading ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _messages.length) {
                return Row(children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
                    child: const SizedBox(width: 40, height: 16, child: LinearProgressIndicator(color: AppColors.accent)),
                  ),
                ]);
              }
              final msg = _messages[i];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : card,
                    borderRadius: BorderRadius.circular(14),
                    border: isUser ? null : Border.all(color: border),
                  ),
                  child: Text(msg['content'] ?? '', style: TextStyle(color: isUser ? Colors.white : textPrimary, fontSize: 13)),
                ),
              );
            },
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: surface,
            border: Border(top: BorderSide(color: border)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                style: TextStyle(color: textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ask about Maharashtra elections...',
                  hintStyle: TextStyle(color: textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.accent)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_chatController.text),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _suggestedQuestion(String q, Color textMuted) {
    return GestureDetector(
      onTap: () => _sendMessage(q),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(q, style: const TextStyle(color: AppColors.accent, fontSize: 12)),
      ),
    );
  }
}