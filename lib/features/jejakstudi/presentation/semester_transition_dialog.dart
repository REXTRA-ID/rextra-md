import 'package:flutter/material.dart';

import '../domain/education_models.dart';
import 'widgets/js_widgets.dart';

/// Modal "Konfirmasi Perubahan Semester" (Figma 7490:75141 Sudah,
/// 7490:72122 Belum, + varian validasi 7754:82459 / 7754:83134).
///
/// Pop dengan [OngoingEducation] yang sudah diperbarui, atau null kalau
/// dibatalkan.
class SemesterTransitionDialog extends StatefulWidget {
  final OngoingEducation education;
  const SemesterTransitionDialog({super.key, required this.education});

  @override
  State<SemesterTransitionDialog> createState() =>
      _SemesterTransitionDialogState();
}

class _SemesterTransitionDialogState extends State<SemesterTransitionDialog> {
  bool _entered = true; // Sudah / Belum
  bool _isFinal = false;
  MonthYear? _semesterEnd;
  MonthYear? _graduation;
  MonthYear? _nextStart;
  final _gpa = TextEditingController();
  Map<String, String> _errors = const {};

  OngoingEducation get _e => widget.education;

  @override
  void initState() {
    super.initState();
    _graduation = _e.estimatedGraduation;
  }

  @override
  void dispose() {
    _gpa.dispose();
    super.dispose();
  }

  void _submit() {
    final errors = <String, String>{};
    if (_entered) {
      if (_semesterEnd == null) {
        errors['semesterEnd'] = 'Bulan akhir semester wajib diisi';
      }
      if (_gpa.text.trim().isEmpty) {
        errors['gpa'] = 'IPK wajib diisi';
      } else if (parseGpa(_gpa.text) == null) {
        errors['gpa'] = 'Format IPK tidak valid';
      }
      if (_isFinal && _graduation == null) {
        errors['graduation'] = 'Estimasi bulan kelulusan wajib diisi';
      }
    } else if (_nextStart == null) {
      errors['nextStart'] = 'Perkiraan bulan pergantian semester wajib diisi';
    }
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    final OngoingEducation updated;
    if (_entered) {
      // Semester berikutnya sekarang jadi semester berjalan.
      final current = _e.nextSemester;
      updated = _e.copyWith(
        currentSemester: current,
        currentSemesterStart: _e.nextSemesterStart,
        nextSemester: current + 1,
        nextSemesterStart: _semesterEnd,
        gpa: parseGpa(_gpa.text),
        isFinalSemester: _isFinal,
        estimatedGraduation: _isFinal ? _graduation : null,
      );
    } else {
      updated = _e.copyWith(nextSemesterStart: _nextStart);
    }
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Konfirmasi Perubahan Semester',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: JsColors.heading,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Apakah saat ini sudah memasuki semester berikutnya?',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _radio(
                    'Sudah',
                    _entered,
                    () => setState(() {
                          _entered = true;
                          _errors = const {};
                        })),
                const SizedBox(width: 24),
                _radio(
                    'Belum',
                    !_entered,
                    () => setState(() {
                          _entered = false;
                          _errors = const {};
                        })),
              ],
            ),
            const SizedBox(height: 20),
            if (_entered) ..._enteredFields() else ..._notYetFields(),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: JsButton(
                    label: _entered ? 'Perbarui Status' : 'Simpan Perkiraan',
                    height: 40,
                    fontSize: 14,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: JsButton.outline(
                    label: 'Batal',
                    height: 40,
                    fontSize: 14,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _enteredFields() => [
        JsField(
          label: 'Semester ini diperkirakan berakhir pada bulan apa?',
          error: _errors['semesterEnd'],
          child: JsMonthField(
            value: _semesterEnd,
            hint: 'Pilih bulan dan tahun',
            hasError: _errors.containsKey('semesterEnd'),
            onChanged: (v) => setState(() => _semesterEnd = v),
          ),
        ),
        JsField(
          label: 'IPK hingga Semester ${_e.currentSemester}',
          error: _errors['gpa'],
          child: JsTextField(
            controller: _gpa,
            hint: 'Masukkan IPK sampai semester ini',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: gpaInputFormatters,
            hasError: _errors.containsKey('gpa'),
          ),
        ),
        const Text(
          'Apakah semester yang sekarang aktif merupakan semester terakhir?',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _radio('Ya,\nini semester terakhir', _isFinal,
                  () => setState(() => _isFinal = true)),
              const SizedBox(height: 10),
              _radio('Tidak,\nmasih lanjut ke semester berikutnya', !_isFinal,
                  () => setState(() => _isFinal = false)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_isFinal)
          JsField(
            label: 'Estimasi bulan kelulusan',
            error: _errors['graduation'],
            child: JsMonthField(
              value: _graduation,
              hint: 'Pilih bulan dan tahun kelulusan',
              hasError: _errors.containsKey('graduation'),
              onChanged: (v) => setState(() => _graduation = v),
            ),
          ),
      ];

  List<Widget> _notYetFields() => [
        JsField(
          label: 'Perkiraan bulan pergantian semester',
          error: _errors['nextStart'],
          child: JsMonthField(
            value: _nextStart,
            hint: 'Pilih bulan dan tahun',
            hasError: _errors.containsKey('nextStart'),
            onChanged: (v) => setState(() => _nextStart = v),
          ),
        ),
      ];

  Widget _radio(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? JsColors.primary : JsColors.hint,
              size: 24,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(label,
                    style: const TextStyle(fontSize: 14, height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
