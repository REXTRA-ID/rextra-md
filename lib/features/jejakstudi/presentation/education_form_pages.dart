import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/nav_utils.dart';
import '../domain/education_models.dart';
import 'providers/jejak_studi_provider.dart';
import 'widgets/js_widgets.dart';

String? _required(String v, String msg) => v.trim().isEmpty ? msg : null;

void _afterSave(BuildContext context, {required bool isEdit}) {
  if (isEdit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan data pendidikan disimpan.')),
    );
    popOrGo(context, '/jejak-studi');
  } else {
    context.go('/jejak-studi/berhasil?aksi=tambah');
  }
}

void _showSaveError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Gagal menyimpan data. Coba lagi.')),
  );
}

// ---------------------------------------------------------------------------
// Tambah / Edit Studi Ditempuh (Figma 7490:75694, 7739:87056, 7683:70448)
// ---------------------------------------------------------------------------

class OngoingEducationFormPage extends ConsumerStatefulWidget {
  /// Null = tambah baru.
  final String? editId;
  const OngoingEducationFormPage({super.key, this.editId});

  @override
  ConsumerState<OngoingEducationFormPage> createState() =>
      _OngoingEducationFormPageState();
}

class _OngoingEducationFormPageState
    extends ConsumerState<OngoingEducationFormPage> {
  final _university = TextEditingController();
  final _faculty = TextEditingController();
  final _program = TextEditingController();
  final _semester = TextEditingController();
  final _nextSemester = TextEditingController();
  final _gpa = TextEditingController();
  EducationLevel? _level;
  MonthYear? _start;
  MonthYear? _graduation;
  MonthYear? _semesterStart;
  MonthYear? _nextSemesterStart;
  OngoingEducation? _editing;

  bool _initialized = false;
  bool _saving = false;
  Map<String, String> _errors = const {};

  bool get _isEdit => widget.editId != null;

  @override
  void dispose() {
    for (final c in [
      _university,
      _faculty,
      _program,
      _semester,
      _nextSemester,
      _gpa,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _init(EducationData data) {
    _initialized = true;
    final e = data.ongoing;
    if (!_isEdit || e == null || e.id != widget.editId) return;
    _editing = e;
    _level = e.level;
    _university.text = e.university;
    _faculty.text = e.faculty;
    _program.text = e.program;
    _start = e.startDate;
    _graduation = e.estimatedGraduation;
    _semester.text = '${e.currentSemester}';
    _semesterStart = e.currentSemesterStart;
    _nextSemester.text = '${e.nextSemester}';
    _nextSemesterStart = e.nextSemesterStart;
    _gpa.text = formatGpa(e.gpa);
  }

  Map<String, String> _validate() {
    final e = <String, String?>{
      'level': _level == null ? 'Jenjang pendidikan wajib dipilih' : null,
      'university':
          _required(_university.text, 'Nama perguruan tinggi wajib diisi'),
      'faculty': _required(_faculty.text, 'Nama fakultas wajib diisi'),
      'program': _required(_program.text, 'Program studi wajib diisi'),
      'start': _start == null ? 'Tanggal mulai perkuliahan wajib diisi' : null,
      'graduation': _graduation == null
          ? 'Estimasi kelulusan wajib diisi'
          : (_start != null && !_graduation!.isAfter(_start!))
              ? 'Estimasi kelulusan harus setelah tanggal mulai'
              : null,
      'semester': _required(_semester.text, 'Semester saat ini wajib diisi') ??
          ((int.tryParse(_semester.text) ?? 0) < 1
              ? 'Semester tidak valid'
              : null),
      'semesterStart': _semesterStart == null
          ? 'Periode mulai semester saat ini wajib diisi'
          : null,
      'nextSemester': _required(
              _nextSemester.text, 'Semester berikutnya wajib diisi') ??
          ((int.tryParse(_nextSemester.text) ?? 0) <=
                  (int.tryParse(_semester.text) ?? 0)
              ? 'Semester berikutnya harus lebih besar dari semester saat ini'
              : null),
      'nextSemesterStart': _nextSemesterStart == null
          ? 'Perkiraan semester berikutnya wajib diisi'
          : (_semesterStart != null &&
                  !_nextSemesterStart!.isAfter(_semesterStart!))
              ? 'Harus setelah semester saat ini dimulai'
              : null,
      'gpa': _gpa.text.trim().isEmpty
          ? 'IPK saat ini wajib diisi'
          : parseGpa(_gpa.text) == null
              ? 'Format IPK tidak valid'
              : null,
    };
    e.removeWhere((_, v) => v == null);
    return e.cast<String, String>();
  }

  Future<void> _save() async {
    final errors = _validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    final e = OngoingEducation(
      id: _editing?.id ?? JejakStudiNotifier.newId(),
      level: _level!,
      university: _university.text.trim(),
      faculty: _faculty.text.trim(),
      program: _program.text.trim(),
      startDate: _start!,
      estimatedGraduation: _graduation!,
      currentSemester: int.parse(_semester.text),
      currentSemesterStart: _semesterStart!,
      nextSemester: int.parse(_nextSemester.text),
      nextSemesterStart: _nextSemesterStart!,
      gpa: parseGpa(_gpa.text)!,
      isFinalSemester: _editing?.isFinalSemester ?? false,
    );
    setState(() => _saving = true);
    try {
      await ref.read(jejakStudiProvider.notifier).saveOngoing(e);
      if (!mounted) return;
      _afterSave(context, isEdit: _isEdit);
    } catch (_) {
      if (mounted) _showSaveError(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(jejakStudiProvider);
    final data = async.valueOrNull;
    if (data == null) {
      return Scaffold(
        appBar: jsAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_initialized) _init(data);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: jsAppBar(context),
      bottomNavigationBar: JsBottomBar(children: [
        JsButton(label: 'Simpan Data', onPressed: _save, loading: _saving),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        children: [
          JsFormHeader(
            title: _isEdit ? 'Edit Studi Ditempuh' : 'Tambah Studi Ditempuh',
            description:
                'Lengkapi data pendidikan untuk mendukung perencanaan karier berbasis semester.',
          ),
          JsField(
            label: 'Jenjang Pendidikan',
            error: _errors['level'],
            child: JsSelectField<EducationLevel>(
              value: _level,
              options: EducationLevel.regular,
              labelOf: (l) => l.label,
              hint: 'Pilih jenjang pendidikan',
              hasError: _errors.containsKey('level'),
              onChanged: (v) => setState(() => _level = v),
            ),
          ),
          JsField(
            label: 'Nama Perguruan Tinggi',
            error: _errors['university'],
            child: JsSuggestField(
              controller: _university,
              hint: 'Masukkan nama perguruan tinggi',
              suggestions: kUniversitySuggestions,
              hasError: _errors.containsKey('university'),
            ),
          ),
          JsField(
            label: 'Nama Fakultas',
            error: _errors['faculty'],
            child: JsTextField(
              controller: _faculty,
              hint: 'Masukkan nama fakultas',
              hasError: _errors.containsKey('faculty'),
            ),
          ),
          JsField(
            label: 'Program Studi',
            error: _errors['program'],
            child: JsTextField(
              controller: _program,
              hint: 'Masukkan nama program studi',
              hasError: _errors.containsKey('program'),
            ),
          ),
          JsField(
            label: 'Tanggal Mulai Perkuliahan',
            error: _errors['start'],
            child: JsMonthField(
              value: _start,
              hint: 'Pilih bulan dan tahun mulai',
              hasError: _errors.containsKey('start'),
              onChanged: (v) => setState(() => _start = v),
            ),
          ),
          JsField(
            label: 'Estimasi Kelulusan',
            error: _errors['graduation'],
            child: JsMonthField(
              value: _graduation,
              hint: 'Pilih bulan dan tahun estimasi lulus',
              hasError: _errors.containsKey('graduation'),
              onChanged: (v) => setState(() => _graduation = v),
            ),
          ),
          JsField(
            label: 'Semester Saat Ini',
            error: _errors['semester'],
            child: JsTextField(
              controller: _semester,
              hint: 'Masukkan semester saat ini',
              keyboardType: TextInputType.number,
              inputFormatters: digitsOnly,
              hasError: _errors.containsKey('semester'),
              onChanged: (v) {
                // Isi otomatis semester berikutnya (masih bisa diubah).
                final n = int.tryParse(v);
                if (n != null) _nextSemester.text = '${n + 1}';
              },
            ),
          ),
          JsField(
            label: 'Semester Saat Ini Dimulai',
            error: _errors['semesterStart'],
            child: JsMonthField(
              value: _semesterStart,
              hint: 'Pilih bulan dan tahun dimulai',
              hasError: _errors.containsKey('semesterStart'),
              onChanged: (v) => setState(() => _semesterStart = v),
            ),
          ),
          JsField(
            label: 'Semester Berikutnya',
            error: _errors['nextSemester'],
            child: JsTextField(
              controller: _nextSemester,
              hint: 'Masukkan semester berikutnya',
              keyboardType: TextInputType.number,
              inputFormatters: digitsOnly,
              hasError: _errors.containsKey('nextSemester'),
            ),
          ),
          JsField(
            label: 'Perkiraan Semester Berikutnya Dimulai',
            error: _errors['nextSemesterStart'],
            child: JsMonthField(
              value: _nextSemesterStart,
              hint: 'Pilih bulan dan tahun dimulai',
              hasError: _errors.containsKey('nextSemesterStart'),
              onChanged: (v) => setState(() => _nextSemesterStart = v),
            ),
          ),
          JsField(
            label: 'IPK Saat Ini',
            error: _errors['gpa'],
            child: JsTextField(
              controller: _gpa,
              hint: 'Masukkan IPK Saat ini',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: gpaInputFormatters,
              hasError: _errors.containsKey('gpa'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tambah / Edit Studi Diselesaikan (Figma 7582:74881, 7754:79692,
// 7754:79953, 7582:75355)
// ---------------------------------------------------------------------------

class CompletedEducationFormPage extends ConsumerStatefulWidget {
  /// Null = tambah baru.
  final String? editId;

  /// Diisi dari tombol "Selesaikan Status": form diisi awal dari studi
  /// yang sedang ditempuh, lalu studi itu dihapus setelah disimpan.
  final String? fromOngoingId;

  const CompletedEducationFormPage(
      {super.key, this.editId, this.fromOngoingId});

  @override
  ConsumerState<CompletedEducationFormPage> createState() =>
      _CompletedEducationFormPageState();
}

class _CompletedEducationFormPageState
    extends ConsumerState<CompletedEducationFormPage> {
  final _university = TextEditingController();
  final _faculty = TextEditingController();
  final _program = TextEditingController();
  final _gpa = TextEditingController();
  final _exchangeProgram = TextEditingController();
  final _hostUniversity = TextEditingController();
  final _hostCountry = TextEditingController();
  final _finalScore = TextEditingController();
  CompletedStudyType _type = CompletedStudyType.reguler;
  EducationLevel? _level;
  MonthYear? _start;
  MonthYear? _end;
  int? _totalSemesters;
  CompletedEducation? _editing;
  OngoingEducation? _fromOngoing;

  bool _initialized = false;
  bool _saving = false;
  Map<String, String> _errors = const {};

  bool get _isEdit => widget.editId != null;
  bool get _isExchange => _type == CompletedStudyType.studentExchange;

  @override
  void dispose() {
    for (final c in [
      _university,
      _faculty,
      _program,
      _gpa,
      _exchangeProgram,
      _hostUniversity,
      _hostCountry,
      _finalScore,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _init(EducationData data) {
    _initialized = true;
    if (_isEdit) {
      final e = data.completed.where((c) => c.id == widget.editId).firstOrNull;
      if (e == null) return;
      _editing = e;
      _type = e.type;
      _level = e.level;
      _university.text = e.university;
      _faculty.text = e.faculty ?? '';
      _program.text = e.program;
      _start = e.startDate;
      _end = e.endDate;
      _totalSemesters = e.totalSemesters;
      _gpa.text = e.finalGpa == null ? '' : formatGpa(e.finalGpa!);
      _exchangeProgram.text = e.exchangeProgram ?? '';
      _hostUniversity.text = e.hostUniversity ?? '';
      _hostCountry.text = e.hostCountry ?? '';
      _finalScore.text = e.finalScore ?? '';
      return;
    }
    final o = data.ongoing;
    if (widget.fromOngoingId != null &&
        o != null &&
        o.id == widget.fromOngoingId) {
      _fromOngoing = o;
      _level = o.level;
      _university.text = o.university;
      _faculty.text = o.faculty;
      _program.text = o.program;
      _start = o.startDate;
      _end = o.estimatedGraduation;
      _totalSemesters = o.currentSemester;
      _gpa.text = formatGpa(o.gpa);
    }
  }

  Map<String, String> _validate() {
    final dateOrder =
        (_start != null && _end != null && !_end!.isAfter(_start!))
            ? 'Harus setelah bulan mulai'
            : null;
    final e = <String, String?>{
      'level': _level == null ? 'Jenjang pendidikan wajib dipilih' : null,
      'university':
          _required(_university.text, 'Nama perguruan tinggi wajib diisi'),
      'program': _required(_program.text, 'Program studi wajib diisi'),
      'start': _start == null ? 'Bulan mulai wajib diisi' : null,
      'end': _end == null
          ? (_isExchange
              ? 'Bulan selesai program wajib diisi'
              : 'Bulan kelulusan wajib diisi')
          : dateOrder,
    };
    if (_isExchange) {
      e['exchangeProgram'] =
          _required(_exchangeProgram.text, 'Nama program exchange wajib diisi');
      e['hostUniversity'] = _required(
          _hostUniversity.text, 'Perguruan tinggi tujuan wajib diisi');
      e['hostCountry'] =
          _required(_hostCountry.text, 'Negara tujuan wajib diisi');
    } else {
      e['faculty'] = _required(_faculty.text, 'Nama fakultas wajib diisi');
      e['totalSemesters'] =
          _totalSemesters == null ? 'Total semester wajib dipilih' : null;
      e['gpa'] = _gpa.text.trim().isEmpty
          ? 'IPK final wajib diisi'
          : parseGpa(_gpa.text) == null
              ? 'Format IPK tidak valid'
              : null;
    }
    e.removeWhere((_, v) => v == null);
    return e.cast<String, String>();
  }

  Future<void> _save() async {
    final errors = _validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    String? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final e = CompletedEducation(
      id: _editing?.id ?? JejakStudiNotifier.newId(),
      type: _type,
      level: _level!,
      university: _university.text.trim(),
      program: _program.text.trim(),
      startDate: _start!,
      endDate: _end!,
      faculty: _isExchange ? null : opt(_faculty),
      totalSemesters: _isExchange ? null : _totalSemesters,
      finalGpa: _isExchange ? null : parseGpa(_gpa.text),
      exchangeProgram: _isExchange ? opt(_exchangeProgram) : null,
      hostUniversity: _isExchange ? opt(_hostUniversity) : null,
      hostCountry: _isExchange ? opt(_hostCountry) : null,
      finalScore: _isExchange ? opt(_finalScore) : null,
    );
    setState(() => _saving = true);
    try {
      await ref
          .read(jejakStudiProvider.notifier)
          .saveCompleted(e, finishedOngoingId: _fromOngoing?.id);
      if (!mounted) return;
      _afterSave(context, isEdit: _isEdit);
    } catch (_) {
      if (mounted) _showSaveError(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(jejakStudiProvider);
    final data = async.valueOrNull;
    if (data == null) {
      return Scaffold(
        appBar: jsAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_initialized) _init(data);

    final levels = _isExchange ? EducationLevel.values : EducationLevel.regular;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: jsAppBar(context),
      bottomNavigationBar: JsBottomBar(children: [
        JsButton(label: 'Simpan Data', onPressed: _save, loading: _saving),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        children: [
          JsFormHeader(
            title: _isEdit
                ? 'Edit Pendidikan Yang Telah Diselesaikan'
                : 'Tambah Studi Diselesaikan',
            description:
                'Lengkapi data pendidikan yang sudah lulus sebagai bagian dari riwayat pendidikan.',
          ),
          JsField(
            label: 'Jenis Studi Diselesaikan',
            child: JsSelectField<CompletedStudyType>(
              value: _type,
              options: CompletedStudyType.values,
              labelOf: (t) => t.label,
              hint: 'Pilih jenis studi',
              onChanged: (v) => setState(() {
                _type = v;
                _errors = const {};
                if (!levels.contains(_level)) _level = null;
              }),
            ),
          ),
          JsField(
            label:
                _isExchange ? 'Jenjang Pendidikan Asal' : 'Jenjang Pendidikan',
            error: _errors['level'],
            child: JsSelectField<EducationLevel>(
              value: _level,
              options: levels,
              labelOf: (l) => l.label,
              hint: 'Pilih jenjang pendidikan',
              hasError: _errors.containsKey('level'),
              onChanged: (v) => setState(() => _level = v),
            ),
          ),
          JsField(
            label: _isExchange
                ? 'Nama Perguruan Tinggi Asal'
                : 'Nama Perguruan Tinggi',
            error: _errors['university'],
            child: JsSuggestField(
              controller: _university,
              hint: _isExchange
                  ? 'Cari dan pilih perguruan tinggi asal'
                  : 'Cari dan pilih perguruan tinggi',
              suggestions: kUniversitySuggestions,
              hasError: _errors.containsKey('university'),
            ),
          ),
          if (!_isExchange)
            JsField(
              label: 'Nama Fakultas',
              error: _errors['faculty'],
              child: JsTextField(
                controller: _faculty,
                hint: 'Masukkan nama fakultas',
                hasError: _errors.containsKey('faculty'),
              ),
            ),
          JsField(
            label: _isExchange ? 'Program Studi Asal' : 'Program Studi',
            error: _errors['program'],
            child: JsTextField(
              controller: _program,
              hint: _isExchange
                  ? 'Masukkan program studi asal'
                  : 'Masukkan nama program studi',
              hasError: _errors.containsKey('program'),
            ),
          ),
          if (_isExchange) ...[
            JsField(
              label: 'Nama Program Exchange',
              error: _errors['exchangeProgram'],
              child: JsTextField(
                controller: _exchangeProgram,
                hint: 'Masukkan nama program exchange',
                hasError: _errors.containsKey('exchangeProgram'),
              ),
            ),
            JsField(
              label: 'Perguruan Tinggi Tujuan',
              error: _errors['hostUniversity'],
              child: JsTextField(
                controller: _hostUniversity,
                hint: 'Masukkan perguruan tinggi tujuan',
                hasError: _errors.containsKey('hostUniversity'),
              ),
            ),
            JsField(
              label: 'Negara Tujuan',
              error: _errors['hostCountry'],
              child: JsSuggestField(
                controller: _hostCountry,
                hint: 'Pilih negara tujuan',
                suggestions: kCountrySuggestions,
                hasError: _errors.containsKey('hostCountry'),
              ),
            ),
          ],
          JsField(
            label:
                _isExchange ? 'Bulan Mulai Program' : 'Bulan Mulai Perkuliahan',
            error: _errors['start'],
            child: JsMonthField(
              value: _start,
              hint: 'Pilih bulan dan tahun mulai',
              hasError: _errors.containsKey('start'),
              onChanged: (v) => setState(() => _start = v),
            ),
          ),
          JsField(
            label: _isExchange
                ? 'Bulan Selesai Program'
                : 'Bulan Kelulusan Perkuliahan',
            error: _errors['end'],
            child: JsMonthField(
              value: _end,
              hint: _isExchange
                  ? 'Pilih bulan dan tahun selesai'
                  : 'Pilih bulan dan tahun kelulusan',
              hasError: _errors.containsKey('end'),
              onChanged: (v) => setState(() => _end = v),
            ),
          ),
          if (_isExchange)
            JsField(
              label: 'Nilai Akhir Program',
              helper: 'Opsional jika tersedia',
              child: JsTextField(
                controller: _finalScore,
                hint: 'Masukkan nilai akhir program',
              ),
            )
          else ...[
            JsField(
              label: 'Total Semester Ditempuh',
              error: _errors['totalSemesters'],
              child: JsSelectField<int>(
                value: _totalSemesters,
                options: List.generate(14, (i) => i + 1),
                labelOf: (n) => '$n',
                hint: 'Pilih total semester',
                hasError: _errors.containsKey('totalSemesters'),
                onChanged: (v) => setState(() => _totalSemesters = v),
              ),
            ),
            JsField(
              label: 'IPK Final',
              error: _errors['gpa'],
              child: JsTextField(
                controller: _gpa,
                hint: 'Masukkan IPK Final',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: gpaInputFormatters,
                hasError: _errors.containsKey('gpa'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
