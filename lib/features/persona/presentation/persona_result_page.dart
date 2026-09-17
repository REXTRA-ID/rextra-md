import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/persona_models.dart';
import 'providers/persona_provider.dart';

// Shared text style helper with Poppins
TextStyle _pp(double size, FontWeight weight, Color color) =>
    TextStyle(fontFamily: 'Poppins', fontSize: size, fontWeight: weight, color: color);

class PersonaResultPage extends ConsumerWidget {
  const PersonaResultPage({super.key});

  void _popOrGo(BuildContext context, String fallbackPath) {
    if (GoRouter.of(context).canPop()) context.pop();
    else context.go(fallbackPath);
  }

  List<Mission> _missionsFor(PersonaType type, BuildContext context) {
    final imgs = [
      'assets/images/mission_simpan_pendidikan.png',
      'assets/images/mission_tujuan_karir.png',
      'assets/images/mission_jelajahi_profesi.png',
    ];
    final m1 = Mission(title: 'Simpan Data Pendidikan Terkini & Terdahulu Dengan Jejak Studi', iconAsset: 'assets/images/pendidikan.png', imageAsset: imgs[0], point: 100, done: true, isMandatory: true, description: 'Misi wajib karena Jejak Studi menyimpan riwayat pendidikanmu, agar sistem bisa membantu persiapan karier selama kuliah dengan lebih tepat');
    final m2 = Mission(title: 'Menetapkan Tujuan Karier Dengan Tes Profil Karier di Fitur Kenali Diri', iconAsset: 'assets/images/rekomendasi.png', imageAsset: imgs[1], point: 100, isMandatory: true, description: 'Misi wajib karena tes profil karier memberi rekomendasi profesi awal agar tujuan karier lebih jelas dan langkah selanjutnya lebih terarah', onTap: () => context.go('/kenali'));
    final m3 = Mission(title: 'Jelajahi Profesi Digital Berprospek Tinggi di Jelajah Profesi', iconAsset: 'assets/images/kamus.png', imageAsset: imgs[2], point: 100, isMandatory: false, description: 'Misi dianjurkan karena Jelajah Profesi di Kamus Karier membantu kamu mengeksplor profesi digital dan prospeknya');
    final m4 = Mission(title: 'Susun Rencana Karier Awal Agar Langkahmu Lebih Terarah di Rencana Karier', iconAsset: 'assets/images/rencana.png', imageAsset: imgs[0], point: 100, isMandatory: true, description: 'Misi wajib dikerjakan karena fitur Rencana Karier membantu kamu merencanakan progres tiap semester dengan langkah yang jelas');
    final m5 = Mission(title: 'Catat aktivitas portofolio', iconAsset: 'assets/images/aktivitas.png', imageAsset: imgs[1], point: 100);
    final m6 = Mission(title: 'Gunakan rekomendasi portofolio', iconAsset: 'assets/images/pengisian.png', imageAsset: imgs[2], point: 100);
    final m7 = Mission(title: 'Akses modul materi edukasi', iconAsset: 'assets/images/modul.png', imageAsset: imgs[0], point: 100);
    final m8 = Mission(title: 'Buat CV Profesional', iconAsset: 'assets/images/cv.png', imageAsset: imgs[1], point: 100);
    final m9 = Mission(title: 'Penuhi kebutuhan seleksi kerja', iconAsset: 'assets/images/kebutuhan.png', imageAsset: imgs[2], point: 100);
    switch (type) {
      case PersonaType.pathfinder: return [m1, m2, m3, m4];
      case PersonaType.builder: return [m1, m2, m3, m4, m5, m6];
      case PersonaType.achiever: return [m1, m2, m3, m4, m5, m6, m7, m8, m9];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final missions = _missionsFor(type, context);
    final doneCount = missions.where((m) => m.done).length;
    final total = missions.length;
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(onPressed: () => _popOrGo(context, '/persona/welcome'), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          AspectRatio(aspectRatio: 392 / 200, child: Image.asset(header, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PROGRESS BOX ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54, height: 54,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2E6BFF), width: 2.5)),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset('assets/images/mission_progress_icon.png', fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A56FF), Color(0xFF38BDF8)])),
                                  child: const Icon(Icons.person, color: Colors.white),
                                )),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(style: _pp(14, FontWeight.w600, const Color(0xFF1F2937)), children: [
                                    TextSpan(text: '$doneCount', style: _pp(20, FontWeight.w800, const Color(0xFF2E6BFF))),
                                    const TextSpan(text: ' dari '),
                                    TextSpan(text: '$total', style: _pp(20, FontWeight.w800, const Color(0xFF1F2937))),
                                    const TextSpan(text: ' misi wajib Terselesaikan'),
                                  ]),
                                ),
                                const SizedBox(height: 8),
                                LayoutBuilder(builder: (ctx, cx) {
                                  final w = cx.maxWidth;
                                  final fw = (w * progress).clamp(0.0, w);
                                  return Stack(clipBehavior: Clip.none, children: [
                                    Container(height: 16, decoration: BoxDecoration(color: const Color(0xFFCEF3FB), borderRadius: BorderRadius.circular(20))),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 600),
                                      width: fw, height: 16,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                                          gradient: const LinearGradient(colors: [Color(0xFF1A56FF), Color(0xFF38BDF8)])),
                                    ),
                                    if (progress > 0)
                                      Positioned(
                                        left: fw - 11, top: -3,
                                        child: Container(
                                          width: 22, height: 22,
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                                              border: Border.all(color: const Color(0xFF1A56FF), width: 2.5),
                                              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4)]),
                                        ),
                                      ),
                                  ]);
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                        const SizedBox(width: 6),
                        Text('Persona berikutnya $nextPersona', style: _pp(12, FontWeight.w700, const Color(0xFF374151))),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- TENTANG PERSONA ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tentang Persona', style: _pp(18, FontWeight.w800, const Color(0xFF1F2937))),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(style: _pp(14, FontWeight.w400, const Color(0xFF4B5563)), children: [
                          TextSpan(text: switch (type) {
                            PersonaType.pathfinder => 'Sebagai ',
                            PersonaType.builder => 'Sebagai ',
                            PersonaType.achiever => 'Sebagai ',
                          }),
                          TextSpan(text: switch (type) {
                            PersonaType.pathfinder => 'Pathfinder',
                            PersonaType.builder => 'Builder',
                            PersonaType.achiever => 'Achiever',
                          }, style: _pp(14, FontWeight.w800, const Color(0xFF1F2937))),
                          TextSpan(text: switch (type) {
                            PersonaType.pathfinder => ', kamu sedang dalam\n',
                            PersonaType.builder => ', kamu mulai membangun\n',
                            PersonaType.achiever => ', kamu fokus mempersiapkan\n',
                          }),
                          TextSpan(text: switch (type) {
                            PersonaType.pathfinder => 'proses mencari dan merencanakan karier',
                            PersonaType.builder => 'fondasi karier dengan memperkuat portofolio',
                            PersonaType.achiever => 'diri untuk proses seleksi kerja',
                          }, style: _pp(14, FontWeight.w700, const Color(0xFF1F2937))),
                          const TextSpan(text: '\n'),
                          TextSpan(text: 'Lihat Selengkapnya', style: _pp(14, FontWeight.w700, const Color(0xFF2E6BFF))),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- MISI WAJIB ---
                Text('Misi Wajib Persona', style: _pp(20, FontWeight.w800, const Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Text('Mulai persiapan karir impian kamu dengan menyelesaikan misi wajib berikut', style: _pp(13, FontWeight.w400, const Color(0xFF4B5563))),
                const SizedBox(height: 14),
                ...missions.map((m) => _MissionTile(mission: m)),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity, height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A56FF), Color(0xFF38BDF8)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => context.go('/kenali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Lanjutkan', style: _pp(16, FontWeight.w700, Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionTile extends StatefulWidget {
  final Mission mission;
  const _MissionTile({required this.mission});
  @override
  State<_MissionTile> createState() => _MissionTileState();
}

class _MissionTileState extends State<_MissionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // Putih ke Biru (kiri putih, kanan biru muda)
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFD6EAFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDD9FF), width: 1),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: _isExpanded ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Gambar + Corner Ribbon ---
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: Stack(
                      children: [
                        // Gambar
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(m.imageAsset, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE5E7EB))),
                          ),
                        ),
                        // Corner Ribbon (Wajib/Dianjurkan) seperti desain
                        Positioned(
                          top: 0, left: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
                            child: CustomPaint(
                              size: const Size(68, 28),
                              painter: _RibbonPainter(isMandatory: m.isMandatory),
                              child: SizedBox(
                                width: 68, height: 28,
                                child: Align(
                                  alignment: const Alignment(-0.2, 0.2),
                                  child: Text(
                                    m.isMandatory ? 'Wajib!' : 'Dianjurkan',
                                    style: _pp(9, FontWeight.w700, Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // --- Detail teks dan chip ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: _pp(13, FontWeight.w700, const Color(0xFF1F2937)), maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Status chip
                            _chip(
                              label: m.done ? 'Selesai' : 'Belum Selesai',
                              bgColor: m.done ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                              textColor: m.done ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
                            ),
                            // Akses chip
                            if (!m.done)
                              _chip(
                                label: 'Akses Terbatas',
                                bgColor: const Color(0xFFFEE2E2),
                                textColor: const Color(0xFFEF4444),
                              ),
                            // Koin chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/images/rextra_koin.png', width: 16, height: 16, fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, size: 14, color: Color(0xFFD97706))),
                                  const SizedBox(width: 4),
                                  Text('+ ${m.point}', style: _pp(12, FontWeight.w800, const Color(0xFFD97706))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF9CA3AF), size: 22),
                ],
              ),
            ),
          ),

          // Expanded area
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),
                  Text(
                    m.description.isEmpty ? 'Misi ini akan membantu kamu mencapai tujuan karier.' : m.description,
                    style: _pp(13, FontWeight.w400, const Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity, height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1A56FF), Color(0xFF38BDF8)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: m.onTap ?? () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Kerjakan Misi', style: _pp(14, FontWeight.w700, Colors.white)),
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

  Widget _chip({required String label, required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: _pp(11, FontWeight.w700, textColor)),
    );
  }
}

// Custom painter untuk corner ribbon diagonal seperti desain
class _RibbonPainter extends CustomPainter {
  final bool isMandatory;
  const _RibbonPainter({required this.isMandatory});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    if (isMandatory) {
      paint.shader = LinearGradient(
        colors: [const Color(0xFF1A56FF), const Color(0xFF38BDF8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.shader = LinearGradient(
        colors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width * 0.55, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}