import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../kenalidiri_controller.dart';

class KenaliDiriHistoryPage extends ConsumerStatefulWidget {
  const KenaliDiriHistoryPage({super.key});

  @override
  ConsumerState<KenaliDiriHistoryPage> createState() => _KenaliDiriHistoryPageState();
}

class _KenaliDiriHistoryPageState extends ConsumerState<KenaliDiriHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AssessmentCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  HistoryTabType get currentTab {
    switch (_tabController.index) {
      case 0:
        return HistoryTabType.selesai;
      case 1:
        return HistoryTabType.berlangsung;
      case 2:
        return HistoryTabType.dibatalkan;
      default:
        return HistoryTabType.selesai;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kenaliDiriProvider);

    final filtered = state.history.where((item) {
      final tabMatch = item.tab == currentTab;
      final categoryMatch =
          selectedCategory == null || item.category == selectedCategory;
      return tabMatch && categoryMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'KENALI DIRI',
          style: TextStyle(
            color: Color(0xFF1E63F6),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Image.asset(
            'assets/images/kenali_diri/BannerKenaliDiri(1).png',
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1450E3),
            unselectedLabelColor: const Color(0xFFB6B6B6),
            indicatorColor: const Color(0xFF1450E3),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            tabs: const [
              Tab(text: 'Selesai'),
              Tab(text: 'Berlangsung'),
              Tab(text: 'Dibatalkan'),
            ],
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyHistoryState(tab: currentTab)
                : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _CategoryFilterButton(
                    selected: selectedCategory,
                    onChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                ...filtered.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _HistoryCard(item: e),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterButton extends StatelessWidget {
  final AssessmentCategory? selected;
  final ValueChanged<AssessmentCategory?> onChanged;

  const _CategoryFilterButton({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AssessmentCategory?>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem<AssessmentCategory?>(
          value: null,
          child: Text('Semua'),
        ),
        const PopupMenuItem(
          value: AssessmentCategory.profilKarier,
          child: Text('Profil Karier'),
        ),
        const PopupMenuItem(
          value: AssessmentCategory.gayaKerja,
          child: Text('Gaya Kerja'),
        ),
        const PopupMenuItem(
          value: AssessmentCategory.kecerdasanMajemuk,
          child: Text('Kecerdasan Majemuk'),
        ),
        const PopupMenuItem(
          value: AssessmentCategory.kepribadian,
          child: Text('Kepribadian'),
        ),
        const PopupMenuItem(
          value: AssessmentCategory.gayaBelajar,
          child: Text('Gaya Belajar'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1450E3), width: 1.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Filter Kategori',
              style: TextStyle(
                color: Color(0xFF1450E3),
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: Color(0xFF1450E3)),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  final HistoryTabType tab;

  const _EmptyHistoryState({required this.tab});

  @override
  Widget build(BuildContext context) {
    String title;
    switch (tab) {
      case HistoryTabType.selesai:
        title = 'Asesmen Selesai Tidak\nDitemukan';
        break;
      case HistoryTabType.berlangsung:
        title = 'Asesmen Berlangsung Tidak\nDitemukan';
        break;
      case HistoryTabType.dibatalkan:
        title = 'Asesmen Dibatalkan Tidak\nDitemukan';
        break;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
      children: [
        Image.asset(
          'assets/images/kenali_diri/Group48098852.png',
          height: 260,
        ),
        const SizedBox(height: 22),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        const Text(
          'Lorem ipsum dolor sit amet consectetur adipiscing elit lorem ipsum dolor',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tes Profil Karier',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1450E3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Hasil Asesmen',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            item.summary,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: item.riasecAssets
                .map(
                  (e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(e, width: 42, height: 42),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFF1450E3), size: 22),
              const SizedBox(width: 6),
              const Text(
                '10 Desember 2025',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/kenali_diri/Group48098863.png',
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '${item.points} Poin',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 18),
              const Icon(Icons.schedule, color: Color(0xFF1450E3), size: 22),
              const SizedBox(width: 6),
              Text(
                '${item.minutes} Menit',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1450E3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Detail Hasil',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C84F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Bagikan Hasil',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}