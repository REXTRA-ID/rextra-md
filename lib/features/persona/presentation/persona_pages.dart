import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------- Helper back aman ----------------
void popOrGo(BuildContext context, String fallbackPath) {
  final r = GoRouter.of(context);
  if (r.canPop()) {
    context.pop();
  } else {
    context.go(fallbackPath);
  }
}

/// ---------------- Model ---------------------------
enum PersonaType { pathfinder, builder, achiever }

PersonaType resolvePersona({
  required bool tujuan,
  required bool porto,
  required bool rekrut,
}) {
  if (!tujuan) return PersonaType.pathfinder;
  if (!porto) return PersonaType.builder;
  if (!rekrut) return PersonaType.builder;
  return PersonaType.achiever;
}

/// ---------------- Store persona (Global) ----------
class PersonaStore {
  static const _key = 'last_persona';

  static Future<void> save(PersonaType t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, t.name);
  }

  static Future<PersonaType?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v == null) return null;
    try {
      return PersonaType.values.firstWhere((e) => e.name == v);
    } catch (_) {
      return null;
    }
  }

  /// Helper jika butuh balik ke halaman persona spesifik
  static Future<void> goToPersonaHome(BuildContext context) async {
    // Tergantung flow route kamu. Di sini aku arahkan balik ke RESULT Persona terakhir
    final p = await get();
    if (p == null) {
      context.go('/persona/welcome');
      return;
    }
    context.go('/persona/result', extra: {'type': p});
  }
}

/// ==================================================
/// WELCOME
/// ==================================================
class PersonaWelcomePage extends StatelessWidget {
  const PersonaWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => popOrGo(context, '/login'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, cons) {
          final w = cons.maxWidth;
          final mascotW = (w * 0.78).clamp(260.0, 340.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/backgroundwelcome.png', fit: BoxFit.cover),
              ),

              // 🦋 maskot lebih besar & agak ke kiri atas
              Positioned(
                top: cons.maxHeight * 0.005, // naik ke atas
                left: -w * -0.05,             // geser ke kiri
                child: Image.asset(
                  'assets/images/rex61.png',
                  width: mascotW,
                  fit: BoxFit.contain,
                ),
              ),

              // ✨ teks & tombol tetap
              Align(
                alignment: const Alignment(0, 0.45),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Selamat Datang Sobat REXTRA! 👋',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: Color(0xFF102542),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hai, Aku Rexi ✨ asisten virtualmu!\n'
                            'Yuk, kenalan dulu supaya aku bisa kasih panduan REXTRA yang pas lewat fitur PERSONA REXTRA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.push('/persona/step1'),
                        child: const Text('Lanjutkan'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push('/persona/info'),
                        child: const Text('Simak Penjelasan'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ==================================================
/// DETAIL INFORMASI
/// ==================================================
class PersonaInfoDetailPage extends StatefulWidget {
  const PersonaInfoDetailPage({super.key});
  @override
  State<PersonaInfoDetailPage> createState() => _PersonaInfoDetailPageState();
}

class _PersonaInfoDetailPageState extends State<PersonaInfoDetailPage> {
  bool showHowItWorks = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => popOrGo(context, '/persona/welcome'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 392 / 166,
            child: Image.asset('assets/images/bginformasi.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Tentang Fitur Aplikasi'),
                const SizedBox(height: 8),
                const Text(
                  'Persona REXTRA adalah fitur yang akan memandu kamu dalam menggunakan aplikasi.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => showHowItWorks = !showHowItWorks),
                  child: Text(
                    showHowItWorks ? 'Sembunyikan' : 'Lihat Selengkapnya',
                    style: const TextStyle(
                      color: Color(0xFF2E6BFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (showHowItWorks) ...[
                  const SizedBox(height: 12),
                  _sectionTitle('Cara Kerja Fitur'),
                  const SizedBox(height: 6),
                  const Text(
                    'Persona REXTRA memprofilkan riwayat pendidikan dan kondisi persiapan kariermu, '
                        'lalu menentukan salah satu dari tiga persona utama yang sesuai dengan fase '
                        'yang kamu alami.',
                  ),
                ],
                const SizedBox(height: 18),
                _sectionTitle('Penjelasan Persona'),
                const SizedBox(height: 12),
                _personaTile(
                  asset: 'assets/images/rexpathfinder.png',
                  title: 'The Pathfinder',
                  desc: 'Mahasiswa yang saat ini sedang merencanakan langkah awal karier impian setelah lulus.',
                ),
                const SizedBox(height: 12),
                _personaTile(
                  asset: 'assets/images/rexbuilder.png',
                  title: 'The Builder',
                  desc: 'Mahasiswa yang sudah memiliki rencana karir, dan sedang berproses membangun portofolio.',
                ),
                const SizedBox(height: 12),
                _personaTile(
                  asset: 'assets/images/rexachiever.png',
                  title: 'The Achiever',
                  desc: 'Mahasiswa yang siap mengikuti seleksi rekrutmen kerja dan memulai perjalanan karier pertama.',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => popOrGo(context, '/persona/welcome'),
                  child: const Text('Kembali'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 20,
      color: Color(0xFF102542),
    ),
  );

  Widget _personaTile({
    required String asset,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(asset, width: 64, height: 64, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ==================================================
/// STEP PAGE (dengan early decision)
/// ==================================================
class PersonaStepPage extends StatefulWidget {
  final int step;
  final String title; // "Tujuan Karier" | "Portofolio Karier" | "Rekrutmen Kerja"
  final String bannerAsset; // tujuan.png | porto.png | rekrutmen.png
  final String optYes;
  final String optNo;

  final bool sebelumnyaTujuan;
  final bool sebelumnyaPorto;

  const PersonaStepPage({
    super.key,
    required this.step,
    required this.title,
    required this.bannerAsset,
    required this.optYes,
    required this.optNo,
    this.sebelumnyaTujuan = false,
    this.sebelumnyaPorto = false,
  });

  @override
  State<PersonaStepPage> createState() => _PersonaStepPageState();
}

class _PersonaStepPageState extends State<PersonaStepPage> {
  bool selected = true; // default "Iya"

  @override
  Widget build(BuildContext context) {
    const total = 3;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.step == 1) {
              popOrGo(context, '/persona/welcome');
            } else if (widget.step == 2) {
              popOrGo(context, '/persona/step1');
            } else {
              popOrGo(context, '/persona/step2');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                Text('Langkah ${widget.step} dari $total', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: widget.step / total,
                minHeight: 8,
                color: const Color(0xFF2E6BFF),
                backgroundColor: const Color(0xFFE6EAF3),
              ),
            ),
            const SizedBox(height: 16),

            AspectRatio(
              aspectRatio: 352 / 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(widget.bannerAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 18),

            _selectTile(
              title: widget.optYes,
              selected: selected,
              onTap: () => setState(() => selected = true),
            ),
            const SizedBox(height: 14),
            _selectTile(
              title: widget.optNo,
              selected: !selected,
              onTap: () => setState(() => selected = false),
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                // EARLY DECISION FLOW
                if (widget.step == 1) {
                  // Q1: Tujuan
                  final tujuan = selected;
                  if (!tujuan) {
                    // PATHFINDER
                    await PersonaStore.save(PersonaType.pathfinder);
                    if (context.mounted) {
                      context.push('/persona/result', extra: {
                        'type': PersonaType.pathfinder,
                      });
                    }
                    return;
                  }
                  // ya -> step2
                  context.push('/persona/step2', extra: {'tujuan': true});
                } else if (widget.step == 2) {
                  // Q2: Portofolio
                  final tujuan = widget.sebelumnyaTujuan; // sudah dari router
                  final porto = selected;
                  if (!porto) {
                    // BUILDER
                    await PersonaStore.save(PersonaType.builder);
                    if (context.mounted) {
                      context.push('/persona/result', extra: {
                        'type': PersonaType.builder,
                      });
                    }
                    return;
                  }
                  // ya -> step3
                  context.push('/persona/step3', extra: {'tujuan': tujuan, 'porto': true});
                } else {
                  // Q3: Rekrutmen
                  final tujuan = widget.sebelumnyaTujuan;
                  final porto = widget.sebelumnyaPorto;
                  final rekrut = selected;
                  final type = resolvePersona(tujuan: tujuan, porto: porto, rekrut: rekrut);

                  await PersonaStore.save(type);
                  if (context.mounted) {
                    context.push('/persona/result', extra: {'type': type});
                  }
                }
              },
              child: Text(widget.step == 3 ? 'Lihat Hasil' : 'Lanjutkan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectTile({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF2E6BFF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: selected ? const Color(0xFF2E6BFF) : const Color(0xFFE6EAF3),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- MODEL MISI --------------------
class Mission {
  final String title;
  final String iconAsset;
  final int point;
  final bool done;
  final VoidCallback? onTap;

  const Mission({
    required this.title,
    required this.iconAsset,
    required this.point,
    this.done = false,
    this.onTap,
  });
}

/// Daftar misi per persona (sesuai desain)
List<Mission> _missionsFor(PersonaType type, BuildContext context) {
  // Ikon berada di assets/images/...
  const m1 = Mission(
    title: 'Simpan data pendidikan terkini dan terdahulu',
    iconAsset: 'assets/images/pendidikan.png',
    point: 5,
    done: true, // contoh: yang ini sudah selesai (untuk progres 1/N)
  );
  final m2 = Mission(
    title: 'Coba rekomendasi karier impian lewat fitur Kenali Diri',
    iconAsset: 'assets/images/rekomendasi.png',
    point: 20,
    onTap: () => context.go('/kenali'), // 👈 route Kenali Diri
  );
  const m3 = Mission(
    title: 'Buka Kamus Karier untuk Jelajahi Dunia Kerja Digital',
    iconAsset: 'assets/images/kamus.png',
    point: 20,
  );
  const m4 = Mission(
    title: 'Mulai membuat rencana karier yang jelas dan spesifik',
    iconAsset: 'assets/images/rencana.png',
    point: 50,
  );
  const m5 = Mission(
    title: 'Catat & rencanakan aktivitas portofolio setiap semester.',
    iconAsset: 'assets/images/aktivitas.png',
    point: 30,
  );
  const m6 = Mission(
    title: 'Gunakan rekomendasi pengisian portofolio karier',
    iconAsset: 'assets/images/pengisian.png',
    point: 50,
  );
  const m7 = Mission(
    title: 'Akses modul materi edukasi persiapan karier digital',
    iconAsset: 'assets/images/modul.png',
    point: 50,
  );
  const m8 = Mission(
    title: 'Buat CV Profesional dan relevan dengan mudahnya',
    iconAsset: 'assets/images/cv.png',
    point: 50,
  );
  const m9 = Mission(
    title: 'Penuhi kebutuhan seleksi kerja dengan mentoring',
    iconAsset: 'assets/images/kebutuhan.png',
    point: 50,
  );

  switch (type) {
    case PersonaType.pathfinder:
      return [m1, m2, m3, m4];
    case PersonaType.builder:
      return [m1, m2, m3, m4, m5, m6];
    case PersonaType.achiever:
      return [m1, m2, m3, m4, m5, m6, m7, m8, m9];
  }
}

/// -------------------- RESULT ----------------------------
class PersonaResultPage extends StatelessWidget {
  const PersonaResultPage({super.key, required this.type});

  final PersonaType type;

  @override
  Widget build(BuildContext context) {
    // Header berdasarkan tipe
    final String header = switch (type) {
      PersonaType.pathfinder => 'assets/images/hasil1.png',
      PersonaType.builder => 'assets/images/hasil2.png',
      PersonaType.achiever => 'assets/images/hasil3.png',
    };

    final String nextPersona = switch (type) {
      PersonaType.pathfinder => 'The Builder',
      PersonaType.builder => 'The Achiever',
      PersonaType.achiever => 'The Achiever',
    };

    final missions = _missionsFor(type, context);
    final doneCount = missions.where((m) => m.done).length;
    final total = missions.length;
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => popOrGo(context, '/persona/welcome'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 392 / 200,
            child: Image.asset(header, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======= PROGRESS BOX =======
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // ikon bg_story.png sebagai ikon (bukan background)
                          Image.asset(
                            'assets/images/bg_story.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$doneCount dari $total misi Terselesaikan',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          color: const Color(0xFF2E6BFF),
                          backgroundColor: const Color(0xFFE6EAF3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '⭐️ Persona berikutnya $nextPersona',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ======= TENTANG PERSONA =======
                const Text(
                  'Tentang Persona',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  switch (type) {
                    PersonaType.pathfinder =>
                    'Sebagai Pathfinder, kamu sedang dalam proses mencari dan merencanakan karier.',
                    PersonaType.builder =>
                    'Sebagai Builder, kamu mulai membangun fondasi karier dengan memperkuat portofolio.',
                    PersonaType.achiever =>
                    'Sebagai Achiever, kamu fokus mempersiapkan diri untuk proses seleksi kerja.',
                  },
                ),
                const SizedBox(height: 18),

                // ======= MISI WAJIB =======
                const Text(
                  'Misi Wajib Persona',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 10),
                ...missions.map((m) => _MissionTile(mission: m)).toList(),
                const SizedBox(height: 22),

                // ❌ HAPUS tombol "Lanjutkan" — akses fitur via mission card.
                // ElevatedButton(
                //   onPressed: () => context.go('/kenali'),
                //   child: const Text('Lanjutkan'),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.mission});
  final Mission mission;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: mission.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // ikon kiri
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      mission.iconAsset,
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mission.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF7A8795)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statusChip(mission.done),
                const SizedBox(width: 8),
                _pointChip(mission.point),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFE8F2FF) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        done ? 'Selesai' : 'Belum Selesai',
        style: TextStyle(
          color: done ? const Color(0xFF2E6BFF) : const Color(0xFF6B7280),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _pointChip(int point) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/bg_story.png', width: 18, height: 18, fit: BoxFit.contain),
          const SizedBox(width: 6),
          Text(
            '$point poin',
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF102542)),
          ),
        ],
      ),
    );
  }
}
