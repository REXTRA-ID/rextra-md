class IkigaiQuestion {
  final int id;
  final String text;
  final List<String> options;
  final bool enableReason;

  IkigaiQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.enableReason = false,
  });

  factory IkigaiQuestion.fromJson(Map<String, dynamic> j) {
    final intId = int.tryParse('${j['id']}') ?? (j['id'] is int ? j['id'] as int : 0);
    final t = (j['text'] ?? j['question'] ?? j['pertanyaan'] ?? j['instruction'] ?? '').toString();
    return IkigaiQuestion(
      id: intId,
      text: t,
      options: parseOptions(j['options']),
      enableReason: (j['enable_reason'] == true) || (j['enableReason'] == true),
    );
  }

  static List<String> parseOptions(dynamic raw) {
    if (raw is List) {
      return raw.map((e) {
        if (e is String) return e;
        if (e is Map) return (e['text'] ?? e['label'] ?? e['value'] ?? '').toString();
        return e?.toString() ?? '';
      }).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }
}

class IkigaiResult {
  final List<IkigaiRecommendation> recommendations;
  final String riasecCode;
  final String riasecSummary;
  final Map<String, String> letters;

  IkigaiResult({
    required this.recommendations,
    required this.riasecCode,
    required this.riasecSummary,
    required this.letters,
  });

  factory IkigaiResult.fromJson(Map<String, dynamic> j) {
    // ----- ambil node "data" (bisa list/map) -----
    Map<String, dynamic> data;
    if (j['data'] != null) {
      final d = j['data'];
      if (d is List && d.isNotEmpty) {
        data = Map<String, dynamic>.from(d.first);
      } else if (d is Map) {
        data = Map<String, dynamic>.from(d);
      } else {
        data = {};
      }
    } else {
      data = Map<String, dynamic>.from(j);
    }

    // ----- kode RIASEC -----
    final code = (data['riasec_code'] ?? data['profile'] ?? '').toString();

    // ----- ringkasan (opsional) -----
    final summary = (data['riasec_summary'] ?? data['summary'] ?? '').toString();

    // ----- penjelasan huruf -----
    Map<String, String> letters = {};
    if (data['riasec_explanations'] is Map) {
      letters = (data['riasec_explanations'] as Map)
          .map((k, v) => MapEntry(k.toString(), v.toString()));
    } else if (data['letters'] is Map) {
      letters = (data['letters'] as Map)
          .map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    // ----- rekomendasi (ambil dari results.top_2 / analysis) -----
    final recs = <IkigaiRecommendation>[];
    final results = data['results'];

    if (results is Map) {
      final top2 = (results['top_2'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          const [];
      final analysis = (results['analysis'] as List?) ?? const [];

      // peta nama -> match
      final Map<String, num> matchByName = {};
      for (final a in analysis) {
        final m = a as Map;
        final name =
        (m['profession'] ?? m['profesi'] ?? m['title'] ?? '').toString();
        final match = (m['match_percentage'] ?? m['match'] ?? 0) as num;
        if (name.isNotEmpty) matchByName[name] = match;
      }

      if (top2.isNotEmpty) {
        recs.add(IkigaiRecommendation(
          title: top2[0],
          priority: 'pertama',
          match: (matchByName[top2[0]] ?? 0).round(),
        ));
      }
      if (top2.length > 1) {
        recs.add(IkigaiRecommendation(
          title: top2[1],
          priority: 'kedua',
          match: (matchByName[top2[1]] ?? 0).round(),
        ));
      }

      // fallback kalau top_2 kosong → ambil 2 tertinggi dari analysis
      if (recs.isEmpty && analysis.isNotEmpty) {
        final sorted = List<Map>.from(analysis);
        sorted.sort((a, b) => ((b['match_percentage'] ?? 0) as num)
            .compareTo((a['match_percentage'] ?? 0) as num));
        for (var i = 0; i < sorted.length && i < 2; i++) {
          recs.add(IkigaiRecommendation(
            title:
            (sorted[i]['profession'] ?? sorted[i]['profesi'] ?? '').toString(),
            priority: i == 0 ? 'pertama' : 'kedua',
            match: ((sorted[i]['match_percentage'] ?? 0) as num).round(),
          ));
        }
      }
    }

    return IkigaiResult(
      recommendations: recs,
      riasecCode: code,
      riasecSummary: summary,
      letters: letters,
    );
  }
}

class IkigaiRecommendation {
  final String title;
  final String priority;
  final int match;

  IkigaiRecommendation({
    required this.title,
    required this.priority,
    required this.match,
  });
}
