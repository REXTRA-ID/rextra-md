import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// >>> SESUAIKAN PATH DENGAN STRUKTUR PROYEKMU <<<
import '../data/kenalidiri_repository.dart';
import '../data/models/ikigai_models.dart';

const _assetBgHasil = 'assets/images/bg_hasil.png';

class HasilKenaliDiriPage extends StatefulWidget {
  const HasilKenaliDiriPage({super.key});

  @override
  State<HasilKenaliDiriPage> createState() => _HasilKenaliDiriPageState();
}

class _HasilKenaliDiriPageState extends State<HasilKenaliDiriPage> {
  final _repo = KenaliDiriRepository();

  bool _loading = true;
  String? _error;

  IkigaiResult? _result;
  bool _expandSummary = false;

  // Map huruf → nama panjang
  static const Map<String, String> _riasecNames = {
    'R': 'Realistic',
    'I': 'Investigative',
    'A': 'Artistic',
    'S': 'Social',
    'E': 'Enterprising',
    'C': 'Conventional',
  };

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getIkigaiResult();
      _result = data;
    } catch (e) {
      _error = 'Gagal memuat hasil Kenali Diri';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
      title: Image.asset('assets/images/rextra.png', height: 22),
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
    );

    if (_loading) {
      return Scaffold(appBar: appBar, body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _loadResult, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }
    final res = _result!;
    final recs = res.recommendations; // List<IkigaiRecommendation>
    final code = res.riasecCode;      // misal "RIA"
    final summary = res.riasecSummary;
    final letters = res.letters;      // Map<String, String>

    // urutkan penjelasan tiap huruf: dahulukan huruf di kode RIASEC, lalu sisa
    final orderedLetters = <String>[];
    for (final c in code.characters) {
      if (!orderedLetters.contains(c) && letters.containsKey(c)) {
        orderedLetters.add(c);
      }
    }
    for (final k in letters.keys) {
      if (!orderedLetters.contains(k)) orderedLetters.add(k);
    }

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          // header banner
          AspectRatio(
            aspectRatio: 392 / 170,
            child: Image.asset(_assetBgHasil, fit: BoxFit.cover),
          ),
          // isi – refreshable
          RefreshIndicator(
            onRefresh: _loadResult,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 160, 20, 140),
              children: [
                _BigCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ---------------- Hasil Rekomendasi ----------------
                      const Text(
                        'Hasil Rekomendasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: Color(0xFF102542),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Berikut 2 profesi digital teratas yang paling cocok dengan profil minat dan bakat kamu',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      if (recs.isEmpty)
                        const Text('Belum ada rekomendasi', textAlign: TextAlign.center)
                      else
                        ...recs.take(2).map((e) => _RecommendationTile(data: e)).toList(),

                      const SizedBox(height: 18),

                      // ---------------- Penjelasan Hasil -----------------
                      const Text(
                        'Penjelasan Hasil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: Color(0xFF102542),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Rekomendasi profesi digital di atas dibuat berdasarkan kode RIASEC dari hasil tes sebelumnya. '
                            'Kamu memperoleh kode:',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        code.isEmpty ? '-' : code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 44,
                          color: Color(0xFF2E6BFF),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              summary.isEmpty ? '-' : summary,
                              textAlign: TextAlign.center,
                              maxLines: _expandSummary ? null : 3,
                              overflow:
                              _expandSummary ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _expandSummary = !_expandSummary),
                              child: Text(
                                _expandSummary ? 'Sembunyikan' : 'Lihat Selengkapnya',
                                style: const TextStyle(
                                  color: Color(0xFF2E6BFF),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      // -------------- Penjelasan Tiap Huruf --------------
                      const Text(
                        'Penjelasan Tiap Huruf',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF2E6BFF),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (orderedLetters.isEmpty)
                        const Text('Tidak ada penjelasan huruf', textAlign: TextAlign.center)
                      else
                        ...orderedLetters.map((letter) {
                          final title = '${_riasecNames[letter] ?? 'Unknown'} ($letter)';
                          final desc = letters[letter] ?? '-';
                          return _LetterInfoCard(
                            titleCenter: title,
                            description: desc,
                            onTapMore: () => _showLetterDetail(letter, title, desc),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(onPressed: () {/* TODO: navigasi rencana karier */}, child: const Text('Buat Rencana Karier')),
              const SizedBox(height: 10),
              FilledButton(onPressed: () {/* TODO: ulangi tes */}, child: const Text('Ulangi Tes')),
            ],
          ),
        ),
      ),
    );
  }

  void _showLetterDetail(String letter, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            controller: controller,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Color(0xFF102542),
                      ),
                    ),
                  ),
                  IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Text(content),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- WIDGET BANTU ----------------

class _BigCard extends StatelessWidget {
  const _BigCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: child,
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.data});
  final IkigaiRecommendation data;

  String get priorityLabel {
    // backend bisa kirim "first"/"second" atau raw string → normalisasi
    final p = (data.priority).toLowerCase();
    if (p.contains('pertama') || p.contains('first')) {
      return 'Profesi Prioritas Pertama';
    }
    if (p.contains('kedua') || p.contains('second')) {
      return 'Profesi Prioritas Kedua';
    }
    return data.priority; // fallback sesuai API
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFF2E6BFF),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF7A8795)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              priorityLabel,
              style: const TextStyle(color: Color(0xFF2E6BFF), fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 8),
          Text('Tingkat kecocokan profesi ini ${data.match}%'),
        ],
      ),
    );
  }
}

class _LetterInfoCard extends StatelessWidget {
  const _LetterInfoCard({
    required this.titleCenter,
    required this.description,
    this.onTapMore,
  });

  final String titleCenter;
  final String description;
  final VoidCallback? onTapMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF3)),
      ),
      child: Column(
        children: [
          Text(
            titleCenter,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Color(0xFF102542),
            ),
          ),
          const SizedBox(height: 6),
          Text(description),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onTapMore,
              child: const Text(
                'Lihat Selengkapnya',
                style: TextStyle(color: Color(0xFF2E6BFF), fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
