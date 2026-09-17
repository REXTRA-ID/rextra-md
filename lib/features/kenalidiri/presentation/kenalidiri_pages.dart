import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../kenalidiri/data/kenalidiri_repository.dart';
import '../data/models/ikigai_models.dart';
import '../data/models/riasec_models.dart';


/// ---------------------------------------------------------------------------
/// ASSETS CONSTANTS
/// ---------------------------------------------------------------------------
const _assetBgKenaliDiri = 'assets/images/bg_kenalidiri.png';
const _assetBannerRiasec = 'assets/images/riasec.png';
const _assetBannerIkigai = 'assets/images/ikigai.png';
const _assetIconLangkah = 'assets/images/icon_langkah.png';

/// Label skala (0..4)
const List<String> kScaleLabels = [
  'Tidak pernah',
  'Jarang',
  'Kadang-kadang',
  'Sering',
  'Sangat sering',
];

/// Ikon wajah (0..4) — aman kalau asset belum ada (pakai emoji fallback)
const List<String> kFaceAssets = [
  'assets/images/face1.png',
  'assets/images/face2.png',
  'assets/images/face3.png',
  'assets/images/face4.png',
  'assets/images/face5.png',
];

void _safeBack(BuildContext context, {String fallback = '/home'}) async {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    context.go(fallback);
  }
}

/// ============================================================================
/// KENALI DIRI – INFORMASI
/// ============================================================================
class KenaliDiriInfoPage extends StatefulWidget {
  const KenaliDiriInfoPage({super.key});

  @override
  State<KenaliDiriInfoPage> createState() => _KenaliDiriInfoPageState();
}

class _KenaliDiriInfoPageState extends State<KenaliDiriInfoPage> {
  bool expanded = true;

  // ukuran elemen pinned
  static const double _bannerH        = 166;  // tinggi banner
  static const double _statsOverlap   = 30;    // 0 = persis di bawah banner, >0 sedikit overlap
  static const double _statsHeightEst = 100;  // estimasi tinggi kartu (untuk padding konten)
  static const double _sidePad        = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _safeBack(context, fallback: '/persona/result'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Stack(
        children: [
          // -------------------- KONTEN SCROLLABLE --------------------
          ListView(
            padding: EdgeInsets.only(
              // MULAI di bawah kartu statistik (bukan banner)
              top: (_bannerH - _statsOverlap) + _statsHeightEst + 12,
              bottom: 120,
              left: 20,
              right: 20,
            ),
            children: [
              _title('Tentang Kenali Diri'),
              const SizedBox(height: 6),
              const Text(
                'Kenali Diri adalah fitur yang memberikan rekomendasi profesi di bidang digital '
                    'secara terpersonalisasi, berbasis self-assessment dengan implementasi teori '
                    'RIASEC oleh Holland dan pendekatan Ikigai.',
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => expanded = !expanded),
                child: Text(
                  expanded ? 'Sembunyikan' : 'Lihat Selengkapnya',
                  style: const TextStyle(color: Color(0xFF2E6BFF), fontWeight: FontWeight.w700),
                ),
              ),
              if (expanded) ...[
                const SizedBox(height: 18),
                _title('Subtest Kenali Diri'),
                const SizedBox(height: 6),
                const Text(
                  'Kenali Diri terdiri atas 2 subtest, dimulai dari tes RIASEC terdiri dari 72 soal berbentuk '
                      'pilihan ganda, serta profiling lanjutan dengan Ikigai.',
                ),
                const SizedBox(height: 18),
                _title('Tujuan Kenali Diri'),
                const SizedBox(height: 6),
                const Text(
                  'Riset internal REXTRA menetapkan tiga persona utama sesuai kondisi dan kebutuhan '
                      'persiapan karier mahasiswa.',
                ),
                const SizedBox(height: 18),
                _title('Langkah Penggunaan'),
                const SizedBox(height: 8),
                const _Bullet('Pastikan kamu sudah punya kode akses.'),
                const _Bullet('Klik tombol “Mulai Kenali Diri”.'),
                const _Bullet('Kerjakan semua subtes tanpa keluar aplikasi.'),
              ],
            ],
          ),

          // -------------------- PINNED LAYER (BANNER + STATS) --------------------
          IgnorePointer( // supaya tidak menghalangi scroll
            ignoring: true,
            child: SizedBox(
              // beri ruang cukup agar kartu tidak terpotong
              height: _bannerH + _statsHeightEst + 40,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // banner
                  Positioned.fill(
                    top: 0,
                    bottom: null,
                    child: SizedBox(
                      height: _bannerH,
                      child: Image.asset(_assetBgKenaliDiri, fit: BoxFit.cover),
                    ),
                  ),
                  // kartu statistik: di-set berada sedikit di bawah banner
                  Positioned(
                    top: _bannerH - _statsOverlap,
                    left: _sidePad,
                    right: _sidePad,
                    child: _StatsPanel(), // tidak diberi height fixed
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: GestureDetector(
            onLongPress: () => context.go('/kenali/riasec-intro'), // dev shortcut
            child: ElevatedButton(
              onPressed: () async {
                final ok = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  builder: (_) => const _AccessCodeSheet(),
                );
                if (ok == true && context.mounted) {
                  context.go('/kenali/riasec-intro');
                }
              },
              child: const Text('Mulai Kenali Diri'),
            ),
          ),
        ),
      ),
    );
  }


  Widget _title(String t) => Text(
    t,
    style: const TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 20,
      color: Color(0xFF102542),
    ),
  );
}

/// Stats panel (dipakai sebagai pinned di atas)
class _StatsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _MetricItem(value: '2', label: 'Subtest'),
          _MetricItem(value: '77', label: 'Soal'),
          _MetricItem(value: '15', label: 'Menit'),
          _MetricItem(value: '20', label: 'Point'),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String value; final String label;
  const _MetricItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Color(0xFF2E6BFF),
            )),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(_assetIconLangkah, width: 18, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// BOTTOM SHEET – KODE AKSES (VALIDASI via API)
/// ============================================================================
class _AccessCodeSheet extends StatefulWidget {
  const _AccessCodeSheet();

  @override
  State<_AccessCodeSheet> createState() => _AccessCodeSheetState();
}

class _AccessCodeSheetState extends State<_AccessCodeSheet> {
  final c = TextEditingController();
  final _repo = KenaliDiriRepository();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = c.text.trim();
    if (code.isEmpty) {
      setState(() => error = 'Kode tidak boleh kosong');
      return;
    }

    setState(() {
      error = null;
      loading = true;
    });

    try {
      final ok = await _repo.validateHash(code);
      if (ok) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() => error = 'Upps, kode salah atau sudah pernah digunakan!');
      }
    } catch (e) {
      setState(() => error = 'Terjadi kesalahan, coba lagi nanti.');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _openPurchaseUrl() async {
    const url = 'https://lynk.id/rextra'; // ✅ gunakan https

    try {
      final uri = Uri.parse(url);
      final can = await canLaunchUrl(uri);
      if (can) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat membuka link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kode Akses Kenali Diri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Masukkan kode akses yang didapat dari pembelian via website, Lynk, atau WhatsApp.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            /// TEXT FIELD
            TextField(
              controller: c,
              decoration: const InputDecoration(
                hintText: 'Masukkan Kode Akses',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitCode(),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /// TOMBOL MULAI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submitCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Mulai Kenali Diri'),
              ),
            ),

            const SizedBox(height: 10),

            /// TOMBOL BELI KODE AKSES
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openPurchaseUrl,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Beli Kode Akses'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// PERALIHAN – RIASEC INTRO
/// ============================================================================
class RiasecIntroPage extends StatelessWidget {
  const RiasecIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _IntroScaffold(
      title: 'Subtest 1 Kenali Diri',
      bannerAsset: _assetBannerRiasec,
      description:
      'Tes RIASEC membantu kamu mengenali tipe kepribadian karier berdasarkan minat dan kecenderungan aktivitas. '
          'Tes ini dikembangkan oleh John Holland untuk memetakan kesesuaian antara kepribadian dan lingkungan kerja. '
          'Terdiri dari 72 soal yang terbagi dalam 6 tahap penilaian sesuai kategori RIASEC.',
      resultText:
      'Setelah menyelesaikan tes, kamu akan mendapatkan hasil berupa kombinasi enam tipe kepribadian RIASEC serta '
          'rekomendasi profesi digital yang paling sesuai dengan potensimu. Hasil ini menjadi dasar untuk langkah '
          'selanjutnya dalam perencanaan kariermu.',
      onNext: () => context.go('/kenali/riasec-test'),
    );
  }
}

/// ============================================================================
/// PERALIHAN – IKIGAI INTRO
/// ============================================================================
class IkigaiIntroPage extends StatelessWidget {
  const IkigaiIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _IntroScaffold(
      title: 'Subtest 2 Ikigai',
      bannerAsset: _assetBannerIkigai,
      description:
      'Tes IKIGAI membantu kamu menemukan keseimbangan antara apa yang kamu sukai, kuasai, dibutuhkan dunia, dan '
          'bernilai secara profesional. Tes ini memetakan potensi dirimu agar bisa menentukan arah karier yang bermakna '
          'dan sesuai passion di era digital.',
      resultText:
      'Setelah menyelesaikan tes, kamu akan mendapatkan hasil berupa peta potensi diri IKIGAI yang menunjukkan '
          'hubungan antara minat, bakat, dan tujuan karier digitalmu. Hasil ini menjadi panduan awal untuk menentukan '
          'arah dan strategi pengembangan karier berikutnya.',
      onNext: () => context.go('/kenali/ikigai-test'),
    );
  }
}

/// Kerangka intro (riasec/ikigai)
class _IntroScaffold extends StatelessWidget {
  final String title;
  final String bannerAsset;
  final String description;
  final String resultText;
  final VoidCallback onNext;

  const _IntroScaffold({
    required this.title,
    required this.bannerAsset,
    required this.description,
    required this.resultText,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => _safeBack(context, fallback: '/kenali'), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 392 / 169,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(bannerAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          _title('Tentang'),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          _title('Langkah Pengerjaan'),
          const _Bullet('Baca setiap pernyataan dengan cermat.'),
          const _Bullet('Pilih opsi yang paling menggambarkan dirimu (dilihat dari minat/bakat).'),
          const _Bullet('Jawab secara jujur dan spontan agar hasilnya akurat.'),
          const _Bullet('Selesaikan semua pertanyaan tanpa keluar dari aplikasi.'),
          const SizedBox(height: 14),
          _title('Hasil Akhir'),
          const SizedBox(height: 6),
          Text(resultText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(onPressed: onNext, child: const Text('Lanjutkan')),
        ),
      ),
    );
  }

  Widget _title(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20));
}

/// ============================================================================
/// RIASEC TEST – 72 soal, 6 bagian (12 soal per bagian), opsi horizontal 5 kolom
/// ============================================================================
class RiasecTestPage extends StatefulWidget {
  const RiasecTestPage({super.key});

  @override
  State<RiasecTestPage> createState() => _RiasecTestPageState();
}

class _RiasecTestPageState extends State<RiasecTestPage> {
  final _repo = KenaliDiriRepository();

  static const int perSection = 12;
  int _section = 0; // 0..5

  bool _loading = true;
  String? _error;
  bool _submitting = false;

  late final ScrollController _scroll;

  /// dari API
  List<RiasecQuestion> _questions = [];

  /// jawaban: questionId (String) -> 0..4 (index opsi di UI)
  final Map<String, int> _answers = {};

  int get totalQuestions => _questions.length;
  int get sections => totalQuestions == 0 ? 1 : (totalQuestions / perSection).ceil();

  int get _start => _section * perSection;
  int get _end => (_start + perSection) > totalQuestions ? totalQuestions : (_start + perSection);

  double get _progress => totalQuestions == 0 ? 0 : (_answers.length / totalQuestions);

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _loadQuestions();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _questions = await _repo.getRiasecQuestions();
      debugPrint('RIASEC QUESTIONS FETCHED => ${_questions.length}');
      // reset state
      _section = 0;
      _answers.clear();
    } catch (e) {
      _error = 'Gagal memuat pertanyaan';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    _submitting = true;

    try {
      final unanswered = totalQuestions - _answers.length;
      if (unanswered > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Masih ada $unanswered soal yang belum dijawab')),
        );
        return;
      }

      // Susun payload 1..5 sesuai urutan pertanyaan
      final ordered = _questions.map((q) {
        final idx0to4 = _answers[q.id] ?? 2; // default netral kalau somehow kosong
        return idx0to4 + 1;
      }).toList(growable: false);

      await _repo.submitRiasecList(ordered);

      // Polling hasil agar profil RIASEC ter-set sebelum lanjut IKIGAI
      for (int i = 1; i <= 10; i++) {
        final res = await _repo.getRiasecResult();
        debugPrint('RIASEC RESULT POLLING ($i/10) => ${res.code}');
        if (res.code.isNotEmpty) break;
        await Future.delayed(const Duration(milliseconds: 800));
      }

      if (!mounted) return;
      context.go('/kenali/ikigai-intro');
      return;
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Gagal mengirim jawaban RIASEC';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim jawaban RIASEC')),
      );
    } finally {
      _submitting = false;
    }
  }

  void _jumpToSection(int i) {
    setState(() => _section = i.clamp(0, sections - 1));
    // scroll ke atas biar UX enak saat pindah section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: _appBarRiasec(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: _appBarRiasec(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _loadQuestions, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    final firstNumber = _start + 1;
    return Scaffold(
      appBar: _appBarRiasec(),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RIASEC TEST',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              Text('Soal ke $firstNumber dari $totalQuestions',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            color: const Color(0xFF2E6BFF),
            backgroundColor: const Color(0xFFE6EAF3),
          ),
          const SizedBox(height: 14),

          // ---- 12 soal per section ----
          ...List.generate((_end - _start), (i) {
            final q = _questions[_start + i];
            final sel0to4 = _answers[q.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RiasecQuestionCard(
                number: _start + i + 1,
                question: q.question,
                selected: sel0to4,              // 0..4 (null = belum)
                onSelect: (opt0to4) => setState(() => _answers[q.id] = opt0to4),
              ),
            );
          }),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          const Text(
            'Bagian Soal ke:',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(sections, (i) {
              final selected = _section == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 6,
                    right: i == sections - 1 ? 0 : 6,
                  ),
                  child: _SectionDot(
                    label: '${i + 1}',
                    selected: selected,
                    onTap: () => _jumpToSection(i),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _section == 0 ? null : () => _jumpToSection(_section - 1),
                  child: const Text('Sebelumnya'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_section < sections - 1) {
                      _jumpToSection(_section + 1);
                    } else {
                      _submit();
                    }
                  },
                  child: const Text('Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBarRiasec() => AppBar(
    leading: IconButton(
      onPressed: () => _safeBack(context, fallback: '/kenali/riasec-intro'),
      icon: const Icon(Icons.arrow_back_ios_new),
    ),
    title: Image.asset('assets/images/rextra.png', height: 22),
    centerTitle: true,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
  );
}

class _SectionDot extends StatelessWidget {
  const _SectionDot({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF1FF) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2E6BFF) : const Color(0xFFE6EAF3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: selected ? const Color(0xFF2E6BFF) : const Color(0xFF102542),
            ),
          ),
        ),
      ),
    );
  }
}


/// Kartu 1 soal RIASEC
class RiasecQuestionCard extends StatelessWidget {
  const RiasecQuestionCard({
    super.key,
    required this.number,
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final int number;          // nomor soal 1..72
  final String question;     // teks soal
  final int? selected;       // 0..4 (null jika belum dipilih)
  final ValueChanged<int> onSelect;

  static const double _optWidth  = 140;
  static const double _optHeight = 125;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6EAF3)),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge
          Row(
            children: [
              _Badge('Soal $number'),
              const SizedBox(width: 8),
              const _Badge(
                'Skala: Peminatan',
                color: Color(0xFFEAF1FF),
                textColor: Color(0xFF2E6BFF),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Teks soal
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // 5 opsi – horizontal scroll, ukuran sama
          SizedBox(
            height: _optHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, opt) {
                final bool isSel = selected == opt;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(opt),
                  child: Container(
                    width: _optWidth,
                    height: _optHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSel ? const Color(0xFF2E6BFF) : const Color(0xFFE6EAF3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSel ? const Color(0xFFEAF1FF) : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ikon aman: kalau asset tidak ada → tampilkan emoji
                        Image.asset(
                          kFaceAssets[opt],
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) {
                            const emojis = ['😖','☹️','😐','🙂','🤩'];
                            return Text(emojis[opt], style: const TextStyle(fontSize: 32));
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          kScaleLabels[opt],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Badge(this.text, {this.color = const Color(0xFF2E6BFF), this.textColor = Colors.white, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
    );
  }
}

/// ============================================================================
/// IKIGAI TEST – integrasi API, opsi TEKS, max 2 pilihan per halaman
/// ============================================================================
class IkigaiTestPage extends StatefulWidget {
  const IkigaiTestPage({super.key});

  @override
  State<IkigaiTestPage> createState() => _IkigaiTestPageState();
}

class _IkigaiTestPageState extends State<IkigaiTestPage> {
  final _repo = KenaliDiriRepository();

  bool _loading = true;
  String? _error;

  /// list pertanyaan dari API (sudah flatten)
  List<IkigaiQuestion> _questions = [];

  /// selections: questionId -> set index opsi yg dipilih (maks. 2)
  final Map<int, Set<int>> _selections = {};

  /// alasan/teks tambahan per questionId (jika enableReason==true)
  final Map<int, TextEditingController> _reasonCtrl = {};

  /// flag error per halaman (untuk highlight isian wajib)
  final Map<int, bool> _showError = {};

  int halaman = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    for (final c in _reasonCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    const maxTry = 12; // up to ~12 detik
    for (var i = 1; i <= maxTry; i++) {
      try {
        debugPrint('  MULAI GET IKIGAI QUESTIONS (try $i/$maxTry)');
        final list = await _repo.getIkigaiQuestions();

        // kalau sukses tapi list kosong -> tampilkan info
        if (list.isEmpty) {
          if (!mounted) return;
          setState(() {
            _questions = [];
            _loading = false;
            _error = 'Pertanyaan IKIGAI belum tersedia. Coba lagi nanti.';
          });
          return;
        }

        if (!mounted) return;
        setState(() {
          _questions = list;
          // normalisasi index
          if (halaman < 0 || halaman >= _questions.length) {
            halaman = 0;
          }
          _loading = false;
        });
        return; // selesai
      } on DioException catch (e) {
        final data = e.response?.data;
        final msg = data is Map ? (data['error'] ?? data['message'] ?? '') : '';

        // Profil RIASEC belum siap -> retry tiap 1 detik
        if (e.response?.statusCode == 400 &&
            msg.toString().toLowerCase().contains('riasec')) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        if (!mounted) return;
        setState(() {
          _error = 'Gagal memuat pertanyaan IKIGAI';
          _loading = false;
        });
        return;
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = 'Gagal memuat pertanyaan IKIGAI';
          _loading = false;
        });
        return;
      }
    }

    // bila 12x retry tetap gagal
    if (!mounted) return;
    setState(() {
      _error = 'Profil RIASEC belum siap. Coba lagi beberapa saat.';
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    _submitting = true;

    // misal tiap halaman merepresentasikan 1 pertanyaan
    final answers = <int, int>{};
    for (var i = 0; i < _questions.length; i++) {
      // ambil pilihan pertama (1–5) sesuai logika kamu
      final picks = _selections[_questions[i].id];
      if (picks != null && picks.isNotEmpty) {
        answers[i + 1] = picks.first + 1; // contoh konversi index ke nilai 1–5
      } else {
        answers[i + 1] = 3; // default netral
      }
    }

    try {
      await _repo.submitIkigaiSimple(answers);

      // ambil hasil setelah submit
      final result = await _repo.getIkigaiResult();
      debugPrint('IKIGAI RESULT => ${result.riasecCode}');

      if (!mounted) return;
      context.go('/kenali/result');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim jawaban IKIGAI')),
      );
    } finally {
      _submitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: _appBarIkigai(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: _appBarIkigai(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Guard: kalau kosong (tetap tidak percaya diri ke backend)
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: _appBarIkigai(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pertanyaan IKIGAI belum tersedia'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _loadQuestions, child: const Text('Muat ulang')),
            ],
          ),
        ),
      );
    }

    // Aman akses pertanyaan ke-`halaman`
    final q = _questions[halaman];
    final picks = _selections.putIfAbsent(q.id, () => <int>{});
    final ctrl = _reasonCtrl.putIfAbsent(q.id, () => TextEditingController());
    final showError = _showError[halaman] ?? false;

    final progress = (halaman + 1) / _questions.length;

    return Scaffold(
      appBar: _appBarIkigai(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('IKIGAI TEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              Text('Soal ke ${halaman + 1} dari ${_questions.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: const Color(0xFF2E6BFF),
            backgroundColor: const Color(0xFFE6EAF3),
          ),
          const SizedBox(height: 14),

          _IkigaiQuestionCard(
            nomor: halaman + 1,
            questionText: q.text,
            options: q.options,
            enableReason: q.enableReason,
            selected: picks,
            controller: ctrl,
            showError: showError,
            onToggle: (idx) {
              setState(() {
                if (picks.contains(idx)) {
                  picks.remove(idx);
                } else if (picks.length < 2) {
                  picks.add(idx);
                }
              });
            },
            onChangedText: (_) {
              if (showError) setState(() => _showError[halaman] = false);
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: halaman == 0 ? null : () => setState(() => halaman--),
                  child: const Text('Sebelumnya'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Validasi halaman aktif
                    if (q.enableReason && picks.isEmpty && ctrl.text.trim().isEmpty) {
                      setState(() => _showError[halaman] = true);
                      return;
                    }
                    if (halaman < _questions.length - 1) {
                      setState(() => halaman++);
                    } else {
                      _submit();
                    }
                  },
                  child: const Text('Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBarIkigai() => AppBar(
    leading: IconButton(
      onPressed: () => _safeBack(context, fallback: '/kenali/ikigai-intro'),
      icon: const Icon(Icons.arrow_back_ios_new),
    ),
    title: Image.asset('assets/images/rextra.png', height: 22),
    centerTitle: true,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
  );
}

/// kartu soal + text area + opsi
class _IkigaiQuestionCard extends StatelessWidget {
  const _IkigaiQuestionCard({
    required this.nomor,
    required this.questionText,
    required this.options,
    required this.enableReason,
    required this.selected,
    required this.controller,
    required this.showError,
    required this.onToggle,
    required this.onChangedText,
  });

  final int nomor;
  final String questionText;
  final List<String> options;
  final bool enableReason;
  final Set<int> selected;
  final TextEditingController controller;
  final bool showError;
  final ValueChanged<int> onToggle;
  final ValueChanged<String> onChangedText;

  @override
  Widget build(BuildContext context) {
    final len = controller.text.characters.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6EAF3)),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _Badge('Soal $nomor'),
          ]),
          const SizedBox(height: 8),
          Text(questionText, style: const TextStyle(fontWeight: FontWeight.w700)),

          if (showError) ...[
            const SizedBox(height: 8),
            const Text(
              'Perhatian!! Anda harus mengisi isian berikut sebelum melanjutkan',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
            ),
          ],

          if (enableReason) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6EAF3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    maxLength: 200,
                    buildCounter: (_, {required int currentLength, maxLength, required bool isFocused}) =>
                        Text('$currentLength/200', style: const TextStyle(color: Color(0xFF9AA5B1))),
                    decoration: const InputDecoration(
                      hintText: 'Jelaskan alasan/pilihan Anda di sini (optional)',
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: onChangedText,
                  ),
                  Text('$len/200', style: const TextStyle(color: Color(0xFF9AA5B1))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          ...List.generate(options.length, (i) {
            final sel = selected.contains(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onToggle(i),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: sel ? const Color(0xFF2E6BFF) : const Color(0xFFE6EAF3), width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: sel ? const Color(0xFFEAF1FF) : Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(sel ? Icons.check_circle : Icons.circle_outlined,
                          color: sel ? const Color(0xFF2E6BFF) : const Color(0xFF9AA5B1)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(options[i], style: const TextStyle(fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
