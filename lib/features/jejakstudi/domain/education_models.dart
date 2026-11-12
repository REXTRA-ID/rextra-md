/// Model data Jejak Studi (Figma Task Flow 4).
///
/// Backend belum punya endpoint data pendidikan, jadi struktur ini dibuat
/// mengikuti field di form Figma dan untuk sementara disimpan lokal
/// (lihat `EducationRepository`).
library;

enum EducationLevel {
  d1('Diploma 1', 'D1'),
  d2('Diploma 2', 'D2'),
  d3('Diploma 3', 'D3'),
  d4('Diploma 4', 'D4'),
  s1('Sarjana S1', 'S1'),
  s2('Magister S2', 'S2'),
  s3('Doktor S3', 'S3'),
  profesi('Profesi', 'Profesi'),
  spesialis('Spesialis', 'Spesialis');

  final String label;
  final String short;
  const EducationLevel(this.label, this.short);

  /// Pilihan jenjang di form "Studi Ditempuh" & "Studi Diselesaikan Reguler".
  static const regular = [d1, d2, d3, d4, s1, s2, s3];

  static EducationLevel? fromName(String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}

enum CompletedStudyType {
  reguler('Reguler'),
  studentExchange('Student Exchange'),
  jointDegree('Joint Degree'),
  doubleDegree('Double Degree');

  final String label;
  const CompletedStudyType(this.label);

  static CompletedStudyType fromName(String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return reguler;
  }
}

/// Bulan + tahun (tanpa tanggal), sesuai picker bulan di Figma.
class MonthYear implements Comparable<MonthYear> {
  final int year;
  final int month; // 1-12

  const MonthYear(this.year, this.month);

  factory MonthYear.now() {
    final n = DateTime.now();
    return MonthYear(n.year, n.month);
  }

  static const monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get label => '${monthNames[month - 1]} $year';

  static MonthYear? tryParse(Object? raw) {
    if (raw is! String) return null;
    final parts = raw.split('-');
    if (parts.length != 2) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (y == null || m == null || m < 1 || m > 12) return null;
    return MonthYear(y, m);
  }

  String toJson() => '$year-${month.toString().padLeft(2, '0')}';

  bool isAfter(MonthYear other) => compareTo(other) > 0;

  @override
  int compareTo(MonthYear other) =>
      year != other.year ? year - other.year : month - other.month;

  @override
  bool operator ==(Object other) =>
      other is MonthYear && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

/// Pendidikan yang sedang ditempuh (maksimal satu, tampil di kartu
/// "Status Pendidikan").
class OngoingEducation {
  final String id;
  final EducationLevel level;
  final String university;
  final String faculty;
  final String program;
  final MonthYear startDate;
  final MonthYear estimatedGraduation;
  final int currentSemester;
  final MonthYear currentSemesterStart;
  final int nextSemester;
  final MonthYear nextSemesterStart;
  final double gpa;

  /// Diisi lewat modal Konfirmasi Perubahan Semester ("Ya, ini semester
  /// terakhir").
  final bool isFinalSemester;

  const OngoingEducation({
    required this.id,
    required this.level,
    required this.university,
    required this.faculty,
    required this.program,
    required this.startDate,
    required this.estimatedGraduation,
    required this.currentSemester,
    required this.currentSemesterStart,
    required this.nextSemester,
    required this.nextSemesterStart,
    required this.gpa,
    this.isFinalSemester = false,
  });

  /// Semester berikutnya seharusnya sudah mulai -> tampilkan pengingat
  /// "Sepertinya sudah berganti semester".
  bool needsSemesterUpdate(MonthYear now) =>
      !isFinalSemester && !nextSemesterStart.isAfter(now);

  /// Semester terakhir dan estimasi lulus sudah lewat -> pengingat
  /// "Ini semester terakhirmu".
  bool needsGraduationUpdate(MonthYear now) =>
      isFinalSemester && !estimatedGraduation.isAfter(now);

  OngoingEducation copyWith({
    int? currentSemester,
    MonthYear? currentSemesterStart,
    int? nextSemester,
    MonthYear? nextSemesterStart,
    MonthYear? estimatedGraduation,
    double? gpa,
    bool? isFinalSemester,
  }) {
    return OngoingEducation(
      id: id,
      level: level,
      university: university,
      faculty: faculty,
      program: program,
      startDate: startDate,
      estimatedGraduation: estimatedGraduation ?? this.estimatedGraduation,
      currentSemester: currentSemester ?? this.currentSemester,
      currentSemesterStart: currentSemesterStart ?? this.currentSemesterStart,
      nextSemester: nextSemester ?? this.nextSemester,
      nextSemesterStart: nextSemesterStart ?? this.nextSemesterStart,
      gpa: gpa ?? this.gpa,
      isFinalSemester: isFinalSemester ?? this.isFinalSemester,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level.name,
        'university': university,
        'faculty': faculty,
        'program': program,
        'start_date': startDate.toJson(),
        'estimated_graduation': estimatedGraduation.toJson(),
        'current_semester': currentSemester,
        'current_semester_start': currentSemesterStart.toJson(),
        'next_semester': nextSemester,
        'next_semester_start': nextSemesterStart.toJson(),
        'gpa': gpa,
        'is_final_semester': isFinalSemester,
      };

  static OngoingEducation? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final level = EducationLevel.fromName(raw['level'] as String?);
    final start = MonthYear.tryParse(raw['start_date']);
    final grad = MonthYear.tryParse(raw['estimated_graduation']);
    final curStart = MonthYear.tryParse(raw['current_semester_start']);
    final nextStart = MonthYear.tryParse(raw['next_semester_start']);
    if (level == null ||
        start == null ||
        grad == null ||
        curStart == null ||
        nextStart == null) {
      return null;
    }
    return OngoingEducation(
      id: raw['id'] as String? ?? '',
      level: level,
      university: raw['university'] as String? ?? '',
      faculty: raw['faculty'] as String? ?? '',
      program: raw['program'] as String? ?? '',
      startDate: start,
      estimatedGraduation: grad,
      currentSemester: (raw['current_semester'] as num?)?.toInt() ?? 1,
      currentSemesterStart: curStart,
      nextSemester: (raw['next_semester'] as num?)?.toInt() ?? 2,
      nextSemesterStart: nextStart,
      gpa: (raw['gpa'] as num?)?.toDouble() ?? 0,
      isFinalSemester: raw['is_final_semester'] == true,
    );
  }
}

/// Pendidikan yang sudah diselesaikan (Riwayat Studi).
///
/// Reguler / Joint / Double Degree memakai field fakultas, total semester
/// & IPK final. Student Exchange memakai field program exchange,
/// perguruan tinggi & negara tujuan, dan nilai akhir opsional.
class CompletedEducation {
  final String id;
  final CompletedStudyType type;
  final EducationLevel level;
  final String university;
  final String program;
  final MonthYear startDate;
  final MonthYear endDate;

  // Reguler / Joint / Double Degree
  final String? faculty;
  final int? totalSemesters;
  final double? finalGpa;

  // Student Exchange
  final String? exchangeProgram;
  final String? hostUniversity;
  final String? hostCountry;
  final String? finalScore;

  const CompletedEducation({
    required this.id,
    required this.type,
    required this.level,
    required this.university,
    required this.program,
    required this.startDate,
    required this.endDate,
    this.faculty,
    this.totalSemesters,
    this.finalGpa,
    this.exchangeProgram,
    this.hostUniversity,
    this.hostCountry,
    this.finalScore,
  });

  bool get isExchange => type == CompletedStudyType.studentExchange;

  /// Judul kartu Riwayat Studi, mis. "D3 - Ilmu Komputer".
  String get title => isExchange
      ? 'Exchange - ${exchangeProgram ?? program}'
      : '${level.short} - $program';

  String get subtitle =>
      isExchange ? (hostUniversity ?? university) : university;

  String get yearRange => startDate.year == endDate.year
      ? '${startDate.year}'
      : '${startDate.year}-${endDate.year}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'level': level.name,
        'university': university,
        'program': program,
        'start_date': startDate.toJson(),
        'end_date': endDate.toJson(),
        'faculty': faculty,
        'total_semesters': totalSemesters,
        'final_gpa': finalGpa,
        'exchange_program': exchangeProgram,
        'host_university': hostUniversity,
        'host_country': hostCountry,
        'final_score': finalScore,
      };

  static CompletedEducation? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final level = EducationLevel.fromName(raw['level'] as String?);
    final start = MonthYear.tryParse(raw['start_date']);
    final end = MonthYear.tryParse(raw['end_date']);
    if (level == null || start == null || end == null) return null;
    return CompletedEducation(
      id: raw['id'] as String? ?? '',
      type: CompletedStudyType.fromName(raw['type'] as String?),
      level: level,
      university: raw['university'] as String? ?? '',
      program: raw['program'] as String? ?? '',
      startDate: start,
      endDate: end,
      faculty: raw['faculty'] as String?,
      totalSemesters: (raw['total_semesters'] as num?)?.toInt(),
      finalGpa: (raw['final_gpa'] as num?)?.toDouble(),
      exchangeProgram: raw['exchange_program'] as String?,
      hostUniversity: raw['host_university'] as String?,
      hostCountry: raw['host_country'] as String?,
      finalScore: raw['final_score'] as String?,
    );
  }
}

class EducationData {
  final OngoingEducation? ongoing;
  final List<CompletedEducation> completed;

  const EducationData({this.ongoing, this.completed = const []});

  bool get isEmpty => ongoing == null && completed.isEmpty;

  Map<String, dynamic> toJson() => {
        'ongoing': ongoing?.toJson(),
        'completed': completed.map((e) => e.toJson()).toList(),
      };

  factory EducationData.fromJson(Object? raw) {
    if (raw is! Map) return const EducationData();
    final list = raw['completed'];
    return EducationData(
      ongoing: OngoingEducation.fromJson(raw['ongoing']),
      completed: list is List
          ? list
              .map(CompletedEducation.fromJson)
              .whereType<CompletedEducation>()
              .toList()
          : const [],
    );
  }
}

/// Parse IPK "3,75" / "3.75" -> 3.75. Null kalau bukan angka 0-4.
double? parseGpa(String raw) {
  final v = double.tryParse(raw.trim().replaceAll(',', '.'));
  if (v == null || v < 0 || v > 4) return null;
  return v;
}

String formatGpa(double v) => v.toStringAsFixed(2);
