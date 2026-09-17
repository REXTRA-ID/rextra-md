import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leadingWidth: 0, // tanpa leading
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/rextra.png', height: 24),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          // ikon notifikasi kecil dummy
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded,
                  color: Color(0xFF102542)),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ===== TOP PROFILE BANNER =====
          _ProfileBanner(
            onTapCta: () => context.go('/kenali'),
          ),

          const SizedBox(height: 16),

          // ===== HORIZ SCROLLER CARD (placeholder) =====
          SizedBox(
            height: 140,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => Container(
                width: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // CTA besar – Mulai Kenali Diri
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: ElevatedButton(
              onPressed: () => context.go('/kenali'),
              child: const Text('Mulai Kenali Diri'),
            ),
          ),
        ],
      ),

      // ===== BOTTOM NAV (dummy) =====
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          selectedIndex: navIndex,
          onDestinationSelected: (i) {
            setState(() => navIndex = i);
            // untuk saat ini belum ada tab lain → stay di satu halaman
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline_rounded),
              selectedIcon: Icon(Icons.work_rounded),
              label: 'Portofolio',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Cari',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note_rounded),
              label: 'Kegiatan',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

/// ======= WIDGET: Banner profil paling atas =======
class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({required this.onTapCta});

  final VoidCallback onTapCta;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 393 / 129, // ukuran header yang kamu kirim
      child: Stack(
        fit: StackFit.expand,
        children: [
          // background gambar
          Image.asset(
            'assets/images/bgprofil.png',
            fit: BoxFit.cover,
          ),

          // konten profil di atas background
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    // avatar dummy
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF102542)),
                    ),
                    const SizedBox(width: 10),
                    // nama + poin
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adhitya Pratama',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.stars_rounded,
                                    size: 16, color: Colors.yellow),
                                SizedBox(width: 4),
                                Text(
                                  '1000',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // badge FREE kecil
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FREE',
                        style: TextStyle(
                          color: Color(0xFF2E6BFF),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // tombol kecil (opsional) di bawah banner menuju Kenali Diri
          Positioned(
            left: 16,
            right: 16,
            bottom: 8,
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onPressed: onTapCta,
                child: const Text(
                  'Yuk, mulai Kenali Diri',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
