import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../kenalidiri/kenalidiri_controller.dart';
import '../../kenalidiri/presentation/kenalidiri_home_page.dart'
    show MembershipStatusCard;
import '../domain/education_models.dart';
import 'providers/jejak_studi_provider.dart';
import 'semester_transition_dialog.dart';
import 'widgets/js_widgets.dart';

const _img = 'assets/images/jejak_studi';

/// Halaman Utama Jejak Studi (Figma TF4): status kosong `6632:50993`,
/// normal `6809:61862`, transisi semester `7243:70732`, semester akhir
/// `7754:84484`.
class JejakStudiHomePage extends ConsumerWidget {
  const JejakStudiHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(jejakStudiProvider);
    final kenali = ref.watch(kenaliDiriProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: jsAppBar(context, fallback: '/persona/result'),
      bottomNavigationBar: JsBottomBar(children: [
        JsButton(
          label: 'Tambah Data',
          onPressed: () => _showAddSheet(context, async.valueOrNull),
        ),
        JsButton.outline(
          label: 'Tambah Riwayat',
          onPressed: () => context.push('/jejak-studi/selesai'),
        ),
      ]),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(jejakStudiProvider),
            child: const Text('Gagal memuat data. Coba lagi'),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Header(
              isPro: kenali.membershipTier == MembershipTier.pro,
              tokenOwned: kenali.tokenOwned,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StatusSection(
                child: data.ongoing == null
                    ? _EmptyStatusCard(
                        onFill: () => context.push('/jejak-studi/ditempuh'))
                    : _OngoingCard(education: data.ongoing!),
              ),
            ),
            if (data.completed.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionTitle(
                'Riwayat Studi',
                action: 'Lihat Semua',
                onAction: () => context.push('/jejak-studi/riwayat'),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 71,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: data.completed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => SizedBox(
                    width: 265,
                    child: HistoryCard(education: data.completed[i]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const _SectionTitle('Beasiswa Studi Lanjut'),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  '$_img/banner_beasiswa.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, EducationData? data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Jenis Data Pendidikan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              _AddOption(
                image: '$_img/ic_studi_ditempuh.png',
                title: 'Tambah Pendidikan Ditempuh',
                subtitle:
                    'Untuk mencatat pendidikan yang saat ini masih berjalan',
                onTap: () {
                  Navigator.pop(sheet);
                  if (data?.ongoing != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Kamu sudah punya pendidikan yang sedang ditempuh. Edit atau selesaikan dulu status tersebut.'),
                      ),
                    );
                    return;
                  }
                  context.push('/jejak-studi/ditempuh');
                },
              ),
              const SizedBox(height: 16),
              _AddOption(
                image: '$_img/ic_studi_selesai.png',
                title: 'Tambah Pendidikan Diselesaikan',
                subtitle:
                    'Untuk menambahkan pendidikan yang sudah lulus sebagai bagian dari riwayat pendidikan',
                onTap: () {
                  Navigator.pop(sheet);
                  context.push('/jejak-studi/selesai');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isPro;
  final int? tokenOwned;
  const _Header({required this.isPro, required this.tokenOwned});

  @override
  Widget build(BuildContext context) {
    // Kartu membership menimpa 13px bagian bawah banner, seperti Figma.
    // Tinggi kartu ikut rasio aslinya (343:94) terhadap lebar layar.
    return LayoutBuilder(builder: (context, c) {
      final cardHeight = (c.maxWidth - 40) * 94 / 343;
      return Stack(
        children: [
          Column(
            children: [
              Image.asset(
                '$_img/banner_jejak_studi.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(height: cardHeight - 13),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: MembershipStatusCard(isPro: isPro, tokenOwned: tokenOwned),
          ),
        ],
      );
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionTitle(this.title, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: JsColors.heading,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: JsColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kartu dengan tab "Status Pendidikan" di pojok kiri atas.
class _StatusSection extends StatelessWidget {
  final Widget child;
  const _StatusSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(padding: const EdgeInsets.only(top: 13), child: child),
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JsColors.cardBorder),
            ),
            child: const Text(
              'Status Pendidikan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: JsColors.heading,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyStatusCard extends StatelessWidget {
  final VoidCallback onFill;
  const _EmptyStatusCard({required this.onFill});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 183),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: JsColors.divider),
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF23DCE1), Color(0xFF004FFF), Color(0xFF00BFC4)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 14,
            top: 20,
            child: Image.asset('$_img/mascot_status_kosong.png', height: 143),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 24, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 218,
                  child: Text(
                    'Belum ada status pendidikan aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const SizedBox(
                  width: 204,
                  child: Text(
                    'Isi pendidikan yang sedang kamu jalani',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 29,
                  child: ElevatedButton(
                    onPressed: onFill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JsColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Isi Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OngoingCard extends ConsumerWidget {
  final OngoingEducation education;
  const _OngoingCard({required this.education});

  Future<void> _updateStatus(BuildContext context, WidgetRef ref) async {
    final updated = await showDialog<OngoingEducation>(
      context: context,
      builder: (_) => SemesterTransitionDialog(education: education),
    );
    if (updated == null) return;
    try {
      await ref.read(jejakStudiProvider.notifier).saveOngoing(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status pendidikan diperbarui.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui status. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = education;
    final now = MonthYear.now();
    final notice = e.needsGraduationUpdate(now)
        ? const _Notice(
            'Hai Sobat REXTRA! Ini semester terakhirmu. Jika studimu sudah selesai perbarui status untuk menandai kelulusan.',
            final_: true,
          )
        : e.needsSemesterUpdate(now)
            ? const _Notice(
                'Hai Sobat REXTRA! Sepertinya sudah berganti semester. Perbarui status untuk menyesuaikan semester terkini',
              )
            : null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/jejak-studi/detail/${e.id}'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(23, 28, 23, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: JsColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${e.level.short} - ${e.program}'.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: JsColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: JsColors.cardBorder),
                    ),
                    child: Text(
                      'IPK ${formatGpa(e.gpa)}',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Image.asset('$_img/ic_kampus.png', width: 22, height: 22),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      e.university.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (notice != null) ...[const SizedBox(height: 12), notice],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SemesterBox(
                      label: e.isFinalSemester
                          ? 'Semester Terakhir'
                          : 'Semester Berjalan',
                      value: 'SEMESTER ${e.currentSemester}',
                      date: e.currentSemesterStart.label,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward,
                        color: JsColors.primary, size: 28),
                  ),
                  Expanded(
                    child: _SemesterBox(
                      label: 'Target Berikutnya',
                      value: e.isFinalSemester
                          ? 'Menuju Lulus!'
                          : 'SEMESTER ${e.nextSemester}',
                      date: e.isFinalSemester
                          ? e.estimatedGraduation.label
                          : e.nextSemesterStart.label,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),
              Row(
                children: [
                  Expanded(
                    child: JsButton(
                      label: 'Perbarui Status',
                      height: 40,
                      fontSize: 14,
                      onPressed: () => _updateStatus(context, ref),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: JsButton.outline(
                      label: 'Selesaikan Status',
                      height: 40,
                      fontSize: 14,
                      onPressed: () =>
                          context.push('/jejak-studi/selesai?dari=${e.id}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  final bool final_;
  const _Notice(this.text, {this.final_ = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: final_ ? const Color(0xFFFAD4D4) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: final_ ? const Color(0xFFF3A3A3) : const Color(0xFFF5D58A),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, height: 1.5, color: JsColors.text),
      ),
    );
  }
}

class _SemesterBox extends StatelessWidget {
  final String label;
  final String value;
  final String date;
  const _SemesterBox(
      {required this.label, required this.value, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
      decoration: BoxDecoration(
        color: JsColors.disabledFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD3D4D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: JsColors.primary,
              ),
            ),
          ),
          Text(date, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

/// Kartu Riwayat Studi, dipakai di halaman utama & daftar riwayat.
class HistoryCard extends StatelessWidget {
  final CompletedEducation education;
  const HistoryCard({super.key, required this.education});

  @override
  Widget build(BuildContext context) {
    final e = education;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push('/jejak-studi/detail/${e.id}'),
        child: Container(
          height: 71,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: JsColors.cardBorder),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/kenali_diri/school-sharp.png',
                  width: 32, height: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(e.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(e.yearRange, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCDDFF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF99BCFF)),
                  ),
                  child: const Text(
                    'SELESAI',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: JsColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOption({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 20, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: JsColors.cardBorder),
        ),
        child: Row(
          children: [
            Image.asset(image, width: 71, height: 55, fit: BoxFit.contain),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 10.5, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Daftar semua Riwayat Studi ("Lihat Semua"). Belum ada frame Figma,
/// jadi memakai kartu riwayat yang sama dalam daftar vertikal.
class EducationHistoryPage extends ConsumerWidget {
  const EducationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(jejakStudiProvider).valueOrNull?.completed;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: jsAppBar(context),
      body: list == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _SectionTitlePlain('Riwayat Studi'),
                const SizedBox(height: 15),
                if (list.isEmpty)
                  const Text('Belum ada riwayat studi.')
                else
                  for (final e in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: HistoryCard(education: e),
                    ),
              ],
            ),
    );
  }
}

class _SectionTitlePlain extends StatelessWidget {
  final String text;
  const _SectionTitlePlain(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: JsColors.heading,
        ),
      );
}
