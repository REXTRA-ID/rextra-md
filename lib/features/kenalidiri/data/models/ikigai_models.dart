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

  factory IkigaiQuestion.fromJson(Map<String, dynamic> j) => IkigaiQuestion(
    id: j['id'],
    text: j['text'],
    options: List<String>.from(j['options'] ?? const []),
    enableReason: j['enable_reason'] == true,
  );
}

class IkigaiResult {
  final List<IkigaiRecommendation> recommendations;
  final String riasecCode;
  final String riasecSummary;
  final Map<String, String> letters; // penjelasan tiap huruf

  IkigaiResult({
    required this.recommendations,
    required this.riasecCode,
    required this.riasecSummary,
    required this.letters,
  });

  factory IkigaiResult.fromJson(Map<String, dynamic> j) => IkigaiResult(
    recommendations: (j['recommendations'] as List)
        .map((e) => IkigaiRecommendation.fromJson(e))
        .toList(),
    riasecCode: j['riasec_code'] ?? '',
    riasecSummary: j['riasec_summary'] ?? '',
    letters: Map<String, String>.from(j['letters'] ?? {}),
  );
}

class IkigaiRecommendation {
  final String title;
  final String priority; // "pertama"/"kedua"
  final int match;       // 80, 50 (persen)

  IkigaiRecommendation({
    required this.title,
    required this.priority,
    required this.match,
  });

  factory IkigaiRecommendation.fromJson(Map<String, dynamic> j) =>
      IkigaiRecommendation(
        title: j['title'],
        priority: j['priority'],
        match: j['match'] ?? 0,
      );
}
