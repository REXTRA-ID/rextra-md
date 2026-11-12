import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/education_models.dart';
import 'providers/jejak_studi_provider.dart';
import 'widgets/js_widgets.dart';

/// Detail Pendidikan (Figma 7582:73306 ditempuh, 7582:72914 selesai)
/// + modal hapus (7582:77837).
class EducationDetailPage extends ConsumerWidget {
  final String id;
  const EducationDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(jejakStudiProvider).valueOrNull;
    if (data == null) {
      return Scaffold(
        appBar: jsAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ongoing = data.ongoing?.id == id ? data.ongoing : null;
    final completed = data.completed.where((c) => c.id == id).firstOrNull;
    if (ongoing == null && completed == null) {
      return Scaffold(
        appBar: jsAppBar(context),
        body: const Center(child: Text('Data pendidikan tidak ditemukan.')),
      );
    }

    final isOngoing = ongoing != null;
    final rows = isOngoing ? _ongoingRows(ongoing) : _completedRows(completed!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: jsAppBar(context),
      bottomNavigationBar: JsBottomBar(children: [
        JsButton(
          label: 'Edit Data',
          onPressed: () => context.push(isOngoing
              ? '/jejak-studi/ditempuh?id=$id'
              : '/jejak-studi/selesai?id=$id'),
        ),
        JsButton.outline(
          label: 'Hapus Data',
          onPressed: () => _confirmDelete(context, ref, isOngoing),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        children: [
          JsFormHeader(
            title: 'Detail Pendidikan',
            description: isOngoing
                ? 'Detail pendidikan untuk mendukung perencanaan karier berbasis semester.'
                : 'Detail pendidikan yang sudah lulus sebagai bagian dari riwayat pendidikan.',
            badge: _StatusBadge(ongoing: isOngoing),
          ),
          for (final r in rows)
            JsField(label: r.$1, child: _ReadOnlyBox(text: r.$2, icon: r.$3)),
        ],
      ),
    );
  }

  List<(String, String, IconData?)> _ongoingRows(OngoingEducation e) {
    const cal = Icons.calendar_today_outlined;
    return [
      ('Jenjang Pendidikan', e.level.label, Icons.keyboard_arrow_down),
      ('Nama Perguruan Tinggi', e.university, null),
      ('Nama Fakultas', e.faculty, null),
      ('Program Studi', e.program, null),
      ('Tanggal Mulai Perkuliahan', e.startDate.label, cal),
      ('Estimasi Kelulusan', e.estimatedGraduation.label, cal),
      ('Semester Saat Ini', 'Semester ${e.currentSemester}', null),
      ('Semester Saat Ini Dimulai', e.currentSemesterStart.label, cal),
      ('Semester Berikutnya', '${e.nextSemester}', null),
      ('Perkiraan Semester Berikutnya Dimulai', e.nextSemesterStart.label, cal),
      ('IPK Saat Ini', formatGpa(e.gpa), null),
    ];
  }

  List<(String, String, IconData?)> _completedRows(CompletedEducation e) {
    const cal = Icons.calendar_today_outlined;
    if (e.isExchange) {
      return [
        ('Jenis Studi', e.type.label, Icons.keyboard_arrow_down),
        ('Jenjang Pendidikan Asal', e.level.label, Icons.keyboard_arrow_down),
        ('Nama Perguruan Tinggi Asal', e.university, null),
        ('Program Studi Asal', e.program, null),
        ('Nama Program Exchange', e.exchangeProgram ?? '-', null),
        ('Perguruan Tinggi Tujuan', e.hostUniversity ?? '-', null),
        ('Negara Tujuan', e.hostCountry ?? '-', null),
        ('Bulan Mulai Program', e.startDate.label, cal),
        ('Bulan Selesai Program', e.endDate.label, cal),
        ('Nilai Akhir Program', e.finalScore ?? '-', null),
      ];
    }
    return [
      if (e.type != CompletedStudyType.reguler)
        ('Jenis Studi', e.type.label, Icons.keyboard_arrow_down),
      ('Jenjang Pendidikan', e.level.label, Icons.keyboard_arrow_down),
      ('Nama Perguruan Tinggi', e.university, null),
      ('Nama Fakultas', e.faculty ?? '-', null),
      ('Program Studi', e.program, null),
      ('Bulan Mulai Perkuliahan', e.startDate.label, cal),
      ('Bulan Kelulusan Perkuliahan', e.endDate.label, cal),
      ('Total Semester Ditempuh', '${e.totalSemesters ?? '-'}', null),
      ('IPK Final', e.finalGpa == null ? '-' : formatGpa(e.finalGpa!), null),
    ];
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, bool isOngoing) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteEducationDialog(),
    );
    if (ok != true) return;
    final notifier = ref.read(jejakStudiProvider.notifier);
    try {
      if (isOngoing) {
        await notifier.deleteOngoing();
      } else {
        await notifier.deleteCompleted(id);
      }
      if (context.mounted) context.go('/jejak-studi/berhasil?aksi=hapus');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus data. Coba lagi.')),
        );
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool ongoing;
  const _StatusBadge({required this.ongoing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: ongoing ? JsColors.accent : const Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ongoing ? 'Ditempuh' : 'Selesai',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ReadOnlyBox extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _ReadOnlyBox({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: JsColors.disabledFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JsColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 15, color: JsColors.disabledText),
            ),
          ),
          if (icon != null) Icon(icon, size: 22, color: JsColors.disabledText),
        ],
      ),
    );
  }
}

/// Modal "Hapus Data Pendidikan": tombol hapus aktif setelah checkbox
/// konfirmasi dicentang. Pop `true` kalau user setuju menghapus.
class DeleteEducationDialog extends StatefulWidget {
  const DeleteEducationDialog({super.key});

  @override
  State<DeleteEducationDialog> createState() => _DeleteEducationDialogState();
}

class _DeleteEducationDialogState extends State<DeleteEducationDialog> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hapus Data Pendidikan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: JsColors.heading,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Data pendidikan ini akan dihapus secara permanen dan tidak dapat dikembalikan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5, color: JsColors.text),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _agree = !_agree),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAD4D4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JsColors.error),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agree,
                        activeColor: JsColors.error,
                        side:
                            const BorderSide(color: JsColors.error, width: 1.5),
                        onChanged: (v) => setState(() => _agree = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Saya mengerti bahwa data ini akan dihapus permanen',
                        style: TextStyle(fontSize: 12, color: JsColors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: JsButton(
                    label: 'Hapus Data',
                    height: 40,
                    fontSize: 14,
                    onPressed:
                        _agree ? () => Navigator.of(context).pop(true) : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: JsButton.outline(
                    label: 'Batal',
                    height: 40,
                    fontSize: 14,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
