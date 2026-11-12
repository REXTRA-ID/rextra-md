import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/persona_models.dart';
import 'providers/persona_provider.dart';

// Shared text style helper with Poppins
TextStyle _pp(double size, FontWeight weight, Color color,
        {double height = 1.55}) =>
    TextStyle(
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height);

const _cardBorder = Color(0xFFCACACA);
const _cardShadow = [
  BoxShadow(color: Color(0x050D0D12), blurRadius: 8, offset: Offset(0, 4)),
  BoxShadow(color: Color(0x0A0D0D12), blurRadius: 10, offset: Offset(0, 5)),
];

class PersonaResultPage extends ConsumerStatefulWidget {
  const PersonaResultPage({super.key});

  @override
  ConsumerState<PersonaResultPage> createState() => _PersonaResultPageState();
}

class _PersonaResultPageState extends ConsumerState<PersonaResultPage> {
  @override
  void initState() {
    super.initState();
    // Refresh progres misi dari backend tiap kali halaman ini dibuka,
    // supaya statusnya selalu sesuai data yang benar-benar tersimpan.
    Future.microtask(
        () => ref.read(personaProvider.notifier).fetchExistingPersona());
  }

  void _openMission(MissionSpec m) {
    final route = m.route;
    if (route != null) {
      context.go(route);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini segera hadir.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personaState = ref.watch(personaProvider);
    final type = personaState.finalPersona ?? PersonaType.pathfinder;
    final header = switch (type) {
      PersonaType.pathfinder => 'assets/images/hasil1.png',
      PersonaType.builder => 'assets/images/hasil2.png',
      PersonaType.achiever => 'assets/images/hasil3.png',
    };
    final nextPersona = switch (type) {
      PersonaType.pathfinder => 'The Builder',
      PersonaType.builder => 'The Achiever',
      PersonaType.achiever => 'The Achiever',
    };

    final missions = missionsFor(type);
    final status = personaState.missionStatus;
    final total = missions.length;
    final doneCount = completedMissionCount(type, status);
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        // Sengaja tanpa tombol profil: user baru harus lewat perkenalan
        // misi dulu, tidak bisa kabur ke profil.
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          AspectRatio(
              aspectRatio: 392 / 200,
              child: Image.asset(header, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressCard(
                  doneCount: doneCount,
                  total: total,
                  progress: progress,
                  nextPersona: nextPersona,
                ),
                const SizedBox(height: 24),
                _AboutPersonaCard(type: type),
                const SizedBox(height: 27),

                // --- MISI WAJIB ---
                Text('Misi Wajib Persona',
                    style: _pp(18, FontWeight.w700, AppColors.black900,
                        height: 1.4)),
                const SizedBox(height: 3),
                Text(
                    'Mulai persiapan karir impian kamu dengan menyelesaikan misi wajib berikut',
                    style: _pp(12, FontWeight.w400, AppColors.black500)),
              ],
            ),
          ),
          // Tile misi digeser ke kiri 13px supaya ribbon "Wajib!" bisa
          // menonjol keluar dari kartu (sesuai Figma).
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 5, 20, 0),
            child: Column(
              children: [
                for (final m in missions)
                  _MissionTile(
                    mission: m,
                    done: status[m.key] == true,
                    onStart: () => _openMission(m),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
                'Lewati Misi',
                style: _pp(14, FontWeight.w700, const Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A56FF), Color(0xFF38BDF8)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => context.go('/kenali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Kenali Diri',
                  style: _pp(16, FontWeight.w700, Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu "x dari n misi wajib Terselesaikan" (Figma node 8497:92045).
class _ProgressCard extends StatelessWidget {
  final int doneCount;
  final int total;
  final double progress;
  final String nextPersona;

  const _ProgressCard({
    required this.doneCount,
    required this.total,
    required this.progress,
    required this.nextPersona,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary100,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/images/mission_progress_icon.png',
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: _pp(14, FontWeight.w500, AppColors.primary600),
                        children: [
                          TextSpan(
                              text: '$doneCount ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: 'dari $total misi wajib Terselesaikan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(progress: progress),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: _pp(12, FontWeight.w500, AppColors.black900),
              children: [
                const TextSpan(text: '⭐ Persona berikutnya '),
                TextSpan(
                    text: nextPersona,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cx) {
      final w = cx.maxWidth;
      // Selalu tampilkan minimal sebesar knob supaya bar 0% tetap terbaca.
      final fw = math.max(20.0, (w * progress).clamp(0.0, w));
      return Container(
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.secondary100,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: fw,
          height: 20,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
                colors: [AppColors.blueTop, AppColors.blueBottom]),
          ),
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
          ),
        ),
      );
    });
  }
}

/// Kartu "Tentang Persona" (Figma node 8497:92060).
///
/// Figma belum punya isi versi lengkap, jadi "Lihat Selengkapnya" sementara
/// menampilkan copy yang sudah ada di app (definisi dari halaman info
/// persona + deskripsi dari kartu reveal). Ganti kalau desainer kasih copy.
class _AboutPersonaCard extends StatefulWidget {
  final PersonaType type;
  const _AboutPersonaCard({required this.type});

  @override
  State<_AboutPersonaCard> createState() => _AboutPersonaCardState();
}

class _AboutPersonaCardState extends State<_AboutPersonaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final more = switch (type) {
      PersonaType.pathfinder =>
        'Pathfinder adalah mahasiswa yang saat ini sedang merencanakan langkah '
            'awal karier impian setelah lulus. Kamu sedang dalam proses mencari '
            'dan merencanakan karier digital impian.',
      PersonaType.builder =>
        'Builder adalah mahasiswa yang sudah memiliki rencana karier dan sedang '
            'berproses membangun portofolio. Kamu akan mulai membangun fondasi '
            'karier dengan membuat portofolio profesional.',
      PersonaType.achiever =>
        'Achiever adalah mahasiswa yang siap mengikuti seleksi rekrutmen kerja '
            'dan memulai perjalanan karier pertama. Kamu semakin dekat dengan '
            'karier impian! Di tahap ini, kamu sudah siap menghadapi proses '
            'seleksi kerja atau magang.',
    };
    final (name, middle, focus) = switch (type) {
      PersonaType.pathfinder => (
          'Pathfinder',
          ', kamu sedang dalam ',
          'proses mencari dan merencanakan karier'
        ),
      PersonaType.builder => (
          'Builder',
          ', kamu mulai membangun ',
          'fondasi karier dengan membuat portofolio'
        ),
      PersonaType.achiever => (
          'Achiever',
          ', kamu fokus mempersiapkan ',
          'diri untuk proses seleksi kerja'
        ),
    };
    const bold = TextStyle(fontWeight: FontWeight.w700);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tentang Persona',
              style: _pp(18, FontWeight.w700, AppColors.black900, height: 1.4)
                  .copyWith(letterSpacing: -0.54)),
          const SizedBox(height: 6),
          Text.rich(
            textAlign: TextAlign.justify,
            TextSpan(
              style: _pp(14, FontWeight.w400, AppColors.black500),
              children: [
                const TextSpan(text: 'Sebagai '),
                TextSpan(text: name, style: bold),
                TextSpan(text: middle),
                TextSpan(text: focus, style: bold),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 6),
            Text(more,
                textAlign: TextAlign.justify,
                style: _pp(14, FontWeight.w400, AppColors.black500)),
          ],
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Sembunyikan' : 'Lihat Selengkapnya',
                style: _pp(14, FontWeight.w600, AppColors.primary600)),
          ),
        ],
      ),
    );
  }
}

/// Kartu misi + panel detail yang bisa dibuka (Figma node 8497:89103 &
/// 8497:89114). Kartu diberi inset 13px dari kiri/atas supaya ribbon
/// "Wajib!/Dianjurkan" menonjol keluar dari pojok kiri atas.
class _MissionTile extends StatefulWidget {
  final MissionSpec mission;
  final bool done;
  final VoidCallback onStart;

  const _MissionTile({
    required this.mission,
    required this.done,
    required this.onStart,
  });

  @override
  State<_MissionTile> createState() => _MissionTileState();
}

class _MissionTileState extends State<_MissionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    const radius = 15.0;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0xCCCACACA)),
            gradient: const LinearGradient(
              begin: Alignment(-1, -0.14),
              end: Alignment(1, 0.14),
              stops: [0.076, 0.54, 0.95],
              colors: [Colors.white, Color(0xFFE7F9FF), Color(0xFFC7F4FF)],
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 66,
                height: 67,
                child: Image.asset(m.imageAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(m.title,
                              style: _pp(
                                  12, FontWeight.w600, AppColors.black600)),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              if (widget.done)
                                const _StatusChip(
                                  label: 'Selesai',
                                  bg: Color(0x403DB268),
                                  fg: AppColors.green600,
                                )
                              else ...[
                                const _StatusChip(
                                  label: 'Belum Selesai',
                                  bg: AppColors.black100,
                                  fg: AppColors.black300,
                                ),
                                if (m.access == MissionAccess.token)
                                  const _StatusChip(
                                    label: 'Akses Token',
                                    bg: Color(0x403379FF),
                                    fg: Color(0xFF0057FF),
                                  ),
                                if (m.access == MissionAccess.limited)
                                  const _StatusChip(
                                    label: 'Akses Terbatas',
                                    bg: Color(0x40E24A4A),
                                    fg: AppColors.red500,
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        _CoinChip(point: m.point),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 13, top: 13),
            child: Column(
              children: [
                if (_isExpanded)
                  Stack(
                    children: [
                      // Warna panel di belakang sudut bawah kartu, supaya
                      // panel terlihat "terselip" di bawah kartu (Figma).
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: radius,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _DetailPanel.bg,
                            border: Border.symmetric(
                              vertical: BorderSide(color: _DetailPanel.border),
                            ),
                          ),
                        ),
                      ),
                      card,
                    ],
                  )
                else
                  card,
                if (_isExpanded)
                  _DetailPanel(
                    description: m.description,
                    onStart: widget.onStart,
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: _Ribbon(isMandatory: m.isMandatory),
          ),
        ],
      ),
    );
  }
}

/// Panel detail misi (Figma node 8497:88328).
class _DetailPanel extends StatelessWidget {
  static const bg = Color(0xFFF7F7F7);
  static const border = Color(0xC9CACACA);

  final String description;
  final VoidCallback onStart;

  const _DetailPanel({required this.description, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 14, 10, 15),
      decoration: const BoxDecoration(
        color: bg,
        border: Border(
          left: BorderSide(color: border),
          right: BorderSide(color: border),
          bottom: BorderSide(color: border),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: _pp(12, FontWeight.w400, Colors.black)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(32),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: Text('Kerjakan Misi',
                  style: _pp(12, FontWeight.w600, Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
      child: Text(label, style: _pp(10, FontWeight.w500, fg)),
    );
  }
}

class _CoinChip extends StatelessWidget {
  final int point;
  const _CoinChip({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFDCD3A)),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFFFFFEF1), Color(0xFFFFF8B5)],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/rextra_koin.png', width: 15, height: 15),
          const SizedBox(width: 8),
          Text('+ $point',
              style: _pp(10, FontWeight.w600, const Color(0xFFD98800))),
        ],
      ),
    );
  }
}

/// Pita diagonal "Wajib!" (biru) / "Dianjurkan" (emas) di pojok kiri atas
/// kartu misi (Figma node 8283:85175 / 8283:87640).
class _Ribbon extends StatelessWidget {
  final bool isMandatory;
  const _Ribbon({required this.isMandatory});

  @override
  Widget build(BuildContext context) {
    final colors = isMandatory
        ? const [
            Colors.white,
            Color(0xFF0075FF),
            Color(0xFF0A5CBB),
            Color(0xFF0776F8),
            Colors.white,
          ]
        : const [
            Colors.white,
            Color(0xFFF7B21A),
            Color(0xFFC78E10),
            Color(0xFFF7B21A),
            Colors.white,
          ];
    final stops = isMandatory
        ? const [0.0, 0.35, 0.54, 0.70, 1.0]
        : const [0.03, 0.24, 0.54, 0.79, 0.96];

    return SizedBox(
      width: 60,
      height: 60,
      child: Center(
        child: Transform.rotate(
          angle: -math.pi / 4,
          child: ClipPath(
            clipper: _RibbonClipper(),
            child: Container(
              width: 67,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors, stops: stops),
              ),
              child: Text(
                isMandatory ? 'Wajib!' : 'Dianjurkan',
                style: _pp(isMandatory ? 9 : 8, FontWeight.w500, Colors.white,
                        height: 1.2)
                    .copyWith(shadows: const [
                  Shadow(
                      color: Color(0x40000000),
                      blurRadius: 1,
                      offset: Offset(0, 1)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Trapesium: sisi atas (yang menghadap pojok kartu) lebih pendek.
class _RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.height, 0)
    ..lineTo(size.width - size.height, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
