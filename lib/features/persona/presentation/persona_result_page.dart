import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/persona_models.dart';
import 'providers/persona_provider.dart';

class PersonaResultPage extends ConsumerWidget {
  const PersonaResultPage({super.key});

  void _popOrGo(BuildContext context, String fallbackPath) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(fallbackPath);
    }
  }

  List<Mission> _missionsFor(PersonaType type, BuildContext context) {
    const m1 = Mission(title: 'Simpan data pendidikan', iconAsset: 'assets/images/pendidikan.png', point: 5, done: true);
    final m2 = Mission(title: 'Coba rekomendasi karier', iconAsset: 'assets/images/rekomendasi.png', point: 20, onTap: () => context.go('/kenali'));
    const m3 = Mission(title: 'Buka Kamus Karier', iconAsset: 'assets/images/kamus.png', point: 20);
    const m4 = Mission(title: 'Mulai membuat rencana karier', iconAsset: 'assets/images/rencana.png', point: 50);
    const m5 = Mission(title: 'Catat aktivitas portofolio', iconAsset: 'assets/images/aktivitas.png', point: 30);
    const m6 = Mission(title: 'Gunakan rekomendasi portofolio', iconAsset: 'assets/images/pengisian.png', point: 50);
    const m7 = Mission(title: 'Akses modul materi edukasi', iconAsset: 'assets/images/modul.png', point: 50);
    const m8 = Mission(title: 'Buat CV Profesional', iconAsset: 'assets/images/cv.png', point: 50);
    const m9 = Mission(title: 'Penuhi kebutuhan seleksi kerja', iconAsset: 'assets/images/kebutuhan.png', point: 50);

    switch (type) {
      case PersonaType.pathfinder: return [m1, m2, m3, m4];
      case PersonaType.builder: return [m1, m2, m3, m4, m5, m6];
      case PersonaType.achiever: return [m1, m2, m3, m4, m5, m6, m7, m8, m9];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil data dari Riverpod state
    final personaState = ref.watch(personaProvider);
    final type = personaState.finalPersona ?? PersonaType.pathfinder; // Default aman jika null

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
          onPressed: () => _popOrGo(context, '/persona/welcome'),
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
          AspectRatio(aspectRatio: 392 / 200, child: Image.asset(header, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          Image.asset('assets/images/bg_story.png', width: 26, height: 26, fit: BoxFit.contain),
                          const SizedBox(width: 10),
                          Text('$doneCount dari $total misi Terselesaikan', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress, minHeight: 8, color: const Color(0xFF2E6BFF), backgroundColor: const Color(0xFFE6EAF3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('⭐️ Persona berikutnya $nextPersona', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tentang Persona', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 6),
                Text(
                  switch (type) {
                    PersonaType.pathfinder => 'Sebagai Pathfinder, kamu sedang dalam proses mencari dan merencanakan karier.',
                    PersonaType.builder => 'Sebagai Builder, kamu mulai membangun fondasi karier dengan memperkuat portofolio.',
                    PersonaType.achiever => 'Sebagai Achiever, kamu fokus mempersiapkan diri untuk proses seleksi kerja.',
                  },
                ),
                const SizedBox(height: 18),
                const Text('Misi Wajib Persona', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 10),
                ...missions.map((m) => _MissionTile(mission: m)),
                const SizedBox(height: 22),
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
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Image.asset(mission.iconAsset, width: 26, height: 26, fit: BoxFit.contain)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(mission.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.2))),
                const Icon(Icons.chevron_right, color: Color(0xFF7A8795)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: mission.done ? const Color(0xFFE8F2FF) : const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(10)),
                  child: Text(mission.done ? 'Selesai' : 'Belum Selesai', style: TextStyle(color: mission.done ? const Color(0xFF2E6BFF) : const Color(0xFF6B7280), fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/bg_story.png', width: 18, height: 18, fit: BoxFit.contain),
                      const SizedBox(width: 6),
                      Text('${mission.point} poin', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF102542))),
                    ],
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