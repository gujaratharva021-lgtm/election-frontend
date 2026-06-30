// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://onebharat-env-2.eba-8m5cvcjn.ap-south-1.elasticbeanstalk.com/api/v1';

  // ── RESULTS ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getResults({
    int year = 2024,
    String state = 'Maharashtra',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/results?year=$year&state=$state'),
    );
    return jsonDecode(response.body);
  }

  // ── PARTIES ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getParties() async {
    final response = await http.get(Uri.parse('$baseUrl/parties'));
    return jsonDecode(response.body);
  }

  // ── PARTY SUMMARY ─────────────────────────────────────
  static Future<Map<String, dynamic>> getPartySummary({
    int year = 2024,
    String state = 'Maharashtra',
    String type = '',
  }) async {
    final typeParam = type.isNotEmpty ? '&type=$type' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/results/summary?year=$year&state=$state$typeParam'),
    );
    return jsonDecode(response.body);
  }

  // ── CONSTITUENCIES ────────────────────────────────────
  static Future<Map<String, dynamic>> getConstituencies({
    String state = 'Maharashtra',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/constituencies?state=$state'),
    );
    return jsonDecode(response.body);
  }

  // ── CONSTITUENCY RESULTS ──────────────────────────────
  static Future<Map<String, dynamic>> getConstituencyResults({
    required int id,
    int year = 2024,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/constituencies/$id/results?year=$year'),
    );
    return jsonDecode(response.body);
  }

  // ── CANDIDATES ────────────────────────────────────────
  static Future<Map<String, dynamic>> getCandidates() async {
    final response = await http.get(Uri.parse('$baseUrl/candidates'));
    return jsonDecode(response.body);
  }

  // ── VOTE TRENDS ───────────────────────────────────────
  static Future<Map<String, dynamic>> getVoteTrends({
    String state = 'Maharashtra',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/results/trends?state=$state'),
    );
    return jsonDecode(response.body);
  }

  // ── INSIGHTS ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getInsights() async {
    final response = await http.get(Uri.parse('$baseUrl/insights'));
    return jsonDecode(response.body);
  }

  // ── SCRAPE ────────────────────────────────────────────
  static Future<Map<String, dynamic>> scrapeResults({
    int year = 2024,
    String state = 'Maharashtra',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/scrape/results?year=$year&state=$state'),
    );
    return jsonDecode(response.body);
  }

  // ── WINNERS (Elected Amdars) ──────────────────────────
  static Future<Map<String, dynamic>> getWinners({
    int year = 2024,
    String state = 'Maharashtra',
    String type = '',
  }) async {
    final typeParam = type.isNotEmpty ? '&type=$type' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/results/winners?year=$year&state=$state$typeParam'),
    );
    return jsonDecode(response.body);
  }

  // ── KHASDARS (Elected MPs) ────────────────────────────
  static Future<Map<String, dynamic>> getKhasdars({int year = 2024}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/results/khasdars?year=$year'),
    );
    return jsonDecode(response.body);
  }

  // ── PARTY COMPARE ─────────────────────────────────────
  static Future<Map<String, dynamic>> compareParties({
    required String party1,
    required String party2,
    int year = 2024,
    String state = 'Maharashtra',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/parties/compare?party1=$party1&party2=$party2&year=$year&state=$state'),
    );
    return jsonDecode(response.body);
  }

  // ── PARTY TREND ───────────────────────────────────────
  static Future<Map<String, dynamic>> getPartyTrend({
    required int partyId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/parties/$partyId/trend'),
    );
    return jsonDecode(response.body);
  }
}