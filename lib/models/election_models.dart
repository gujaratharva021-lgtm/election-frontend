// lib/models/election_models.dart

class Party {
  final String id;
  final String name;
  final String shortName;
  final String color;
  final Map<int, int> seatsByYear;
  final Map<int, double> voteShareByYear;

  Party({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
    required this.seatsByYear,
    required this.voteShareByYear,
  });
}

class Candidate {
  final String id;
  final String name;
  final String party;
  final String partyColor;
  final String constituency;
  final int votes;
  final double votePercent;
  final bool isWinner;
  final String? imageUrl;

  Candidate({
    required this.id,
    required this.name,
    required this.party,
    required this.partyColor,
    required this.constituency,
    required this.votes,
    required this.votePercent,
    required this.isWinner,
    this.imageUrl,
  });
}

class Constituency {
  final String id;
  final String name;
  final int code;
  final String state;
  final String type; // Urban/Rural/Semi-Urban
  final int totalVoters;
  final double turnout;
  final List<Candidate> candidates;
  final String winnerParty;
  final int margin;
  final String? imageUrl;

  Constituency({
    required this.id,
    required this.name,
    required this.code,
    required this.state,
    required this.type,
    required this.totalVoters,
    required this.turnout,
    required this.candidates,
    required this.winnerParty,
    required this.margin,
    this.imageUrl,
  });

  Candidate get winner => candidates.firstWhere((c) => c.isWinner);
  Candidate get runnerUp => candidates.firstWhere((c) => !c.isWinner);
}

class VoteTrend {
  final int year;
  final Map<String, double> partyShares; // party -> vote%

  VoteTrend({required this.year, required this.partyShares});
}

class AIInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final String? party;

  AIInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.party,
  });
}

enum InsightType { strength, opportunity, risk, insight }

class DashboardStats {
  final int totalConstituencies;
  final int totalSeats;
  final String leadingParty;
  final int leadingSeats;
  final double avgVoteShare;
  final double voteShareChange;

  DashboardStats({
    required this.totalConstituencies,
    required this.totalSeats,
    required this.leadingParty,
    required this.leadingSeats,
    required this.avgVoteShare,
    required this.voteShareChange,
  });
}