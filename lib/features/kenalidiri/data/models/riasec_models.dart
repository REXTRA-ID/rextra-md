class RiasecQuestion {
  final String id;
  final String question;   // pakai nama field yang jelas
  final String? scale;     // opsional

  RiasecQuestion({
    required this.id,
    required this.question,
    this.scale,
  });

  factory RiasecQuestion.fromJson(Map<String, dynamic> j) {
    // id bisa string/integer; amankan jadi string
    final rawId = j['id'];
    final idStr = rawId == null ? '' : rawId.toString();

    return RiasecQuestion(
      id: idStr,
      // backend sebagian kirim "pertanyaan" (bukan "text")
      question: (j['pertanyaan'] ?? j['text'] ?? '').toString(),
      scale: j['skala']?.toString(),
    );
  }
}

class RiasecResult {
  final String code;           // contoh: "RIA"
  final String summary;        // ringkasan umum
  final Map<String, String> letters; // penjelasan tiap huruf

  RiasecResult({
    required this.code,
    required this.summary,
    required this.letters,
  });

  factory RiasecResult.fromJson(Map<String, dynamic> j) => RiasecResult(
    code: j['code']?.toString() ?? '',
    summary: j['summary']?.toString() ?? '',
    letters: Map<String, String>.from(j['letters'] ?? {}),
  );
}
