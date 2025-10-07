import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ===================================================================
/// Helper: back aman. Kalau bisa pop → pop.
/// Kalau tidak, arahkan ke fallbackPath.
/// ===================================================================
void popOrGo(BuildContext context, String fallbackPath) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    context.pop();
  } else {
    context.go(fallbackPath);
  }
}

/// -------------------- MODEL & HELPER --------------------
enum PersonaType { pathfinder, builder, achiever }

PersonaType resolvePersona({
  required bool tujuan,
  required bool porto,
  required bool rekrut,
}) {
  if (rekrut) return PersonaType.achiever;
  if (porto) return PersonaType.builder;
  return PersonaType.pathfinder;
}

/// -------------------- WELCOME ----------------------------
class PersonaWelcomePage extends StatelessWidget {
  const PersonaWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // kalau tak ada halaman sebelumnya, balik ke /home (sementara)
          onPressed: () => popOrGo(context, '/home'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Image.asset('assets/images/rex61.png', height: 180, fit: BoxFit.contain),
            const SizedBox(height: 18),

            const Text(
              'Selamat Datang Sobat REXTRA! 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF102542),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Hai, Aku Rexi ✨ asisten virtualmu!\n'
                  'Yuk, kenalan dulu supaya aku bisa kasih panduan REXTRA yang pas lewat fitur PERSONA REXTRA',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),

            // PAKAI PUSH → agar back berfungsi
            ElevatedButton(
              onPressed: () => context.push('/persona/step1'),
              child: const Text('Lanjutkan'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/persona/info'),
              child: const Text('Simak Penjelasan'),
            )
          ],
        ),
      ),
    );
  }
}

/// -------------------- DETAIL INFORMASI ------------------
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
          // balik ke welcome kalau stack kosong
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
                // Kembali → ke welcome (warna biru, ElevatedButton)
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

/// -------------------- STEP PAGE REUSABLE ----------------
/// Kita TIDAK pakai context.extra. Data antar step dipassing via constructor.
class PersonaStepPage extends StatefulWidget {
  final int step;
  final String title;       // "Tujuan Karier" | "Portofolio Karier" | "Rekrutmen Kerja"
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
  bool selected = true;

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
            const LinearProgressIndicator(
              value: 0, // dummy, kita set di bawah
              minHeight: 8,
              color: Color(0xFF2E6BFF),
              backgroundColor: Color(0xFFE6EAF3),
            ),
            // Update value dengan LayoutBuilder biar gak warning rebuild
            LayoutBuilder(builder: (_, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: widget.step / total,
                  minHeight: 8,
                  color: const Color(0xFF2E6BFF),
                  backgroundColor: const Color(0xFFE6EAF3),
                ),
              );
            }),
            const SizedBox(height: 16),

            // banner pertanyaan
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
              onPressed: () {
                if (widget.step == 1) {
                  // Step 1 → Step 2 (bawa jawaban tujuan lewat constructor)
                  context.push(
                    '/persona/step2',
                    extra: null, // tak dipakai
                  );
                  // Router harus inject konstruktor Step2 dengan sebelumnyaTujuan: selected
                } else if (widget.step == 2) {
                  // Step 2 → Step 3
                  context.push(
                    '/persona/step3',
                    extra: null,
                  );
                  // Router inject Step3 dengan sebelumnyaTujuan: widget.sebelumnyaTujuan, sebelumnyaPorto: selected
                } else {
                  // Step 3 → result
                  final type = resolvePersona(
                    tujuan: widget.sebelumnyaTujuan,
                    porto: widget.sebelumnyaPorto,
                    rekrut: selected,
                  );
                  context.push('/persona/result', extra: {'type': type});
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

/// -------------------- RESULT ----------------------------
class PersonaResultPage extends StatelessWidget {
  const PersonaResultPage({super.key, required this.type});

  final PersonaType type;

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => popOrGo(context, '/persona/step3'),
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
                // progres ringkas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Color(0xFF2E6BFF)),
                          SizedBox(width: 8),
                          Text('1 dari 4 misi Terselesaikan',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                          value: 0.25,
                          minHeight: 8,
                          color: Color(0xFF2E6BFF),
                          backgroundColor: Color(0xFFE6EAF3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('⭐️ Persona berikutnya $nextPersona',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                    'Sebagai Builder, kamu mulai membangun fondasi karier dengan memperkuat portfolio.',
                    PersonaType.achiever =>
                    'Sebagai Achiever, kamu fokus mempersiapkan diri untuk proses seleksi kerja.',
                  },
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () => context.go('/home'), // ganti ke page tujuanmu nanti
                  child: const Text('Lanjutkan'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
