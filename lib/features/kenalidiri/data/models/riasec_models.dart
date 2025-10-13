class RiasecQuestion {
  final int id;
  final String text;

  RiasecQuestion({required this.id, required this.text});

  factory RiasecQuestion.fromJson(Map<String, dynamic> j) =>
      RiasecQuestion(id: j['id'], text: j['text']);
}

class RiasecResult {
  // Sesuaikan jika backend menambah field lain
  final String code;           // contoh: "RIA"
  final String summary;        // ringkasan umum
  final Map<String, String> letters; // penjelasan tiap huruf

  RiasecResult({
    required this.code,
    required this.summary,
    required this.letters,
  });

  factory RiasecResult.fromJson(Map<String, dynamic> j) => RiasecResult(
    code: j['code'],
    summary: j['summary'] ?? '',
    letters: Map<String, String>.from(j['letters'] ?? {}),
  );
}
