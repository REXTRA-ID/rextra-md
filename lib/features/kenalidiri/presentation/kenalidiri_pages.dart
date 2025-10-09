import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ---------------------------------------------------------------------------
/// ASSETS CONSTANTS
/// ---------------------------------------------------------------------------
const _assetBgKenaliDiri = 'assets/images/bg_kenalidiri.png';
const _assetBannerRiasec = 'assets/images/riasec.png';
const _assetBannerIkigai = 'assets/images/ikigai.png';
const _assetIconLangkah = 'assets/images/icon_langkah.png';

const _faceAssets = <String>[
  'assets/images/face1.png', // sangat setuju
  'assets/images/face2.png', // setuju
  'assets/images/face3.png', // netral
  'assets/images/face4.png', // tidak setuju
  'assets/images/face5.png', // sangat tidak setuju
];

const _scaleLabels = <String>[
  'Sangat Setuju',
  'Setuju',
  'Netral',
  'Tidak Setuju',
  'Sangat Tidak Setuju',
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

  @override
  Widget build(BuildContext context) {
    final bannerHeight = 166.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _safeBack(context, fallback: '/home'),
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
          /// ------- Banner -------
          SizedBox(
            height: bannerHeight,
            width: double.infinity,
            child: Image.asset(_assetBgKenaliDiri, fit: BoxFit.cover),
          ),

          /// ------- Konten scrollable -------
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              SizedBox(height: bannerHeight - 22),

              /// ------- Panel metrik (floating) -------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                ),
              ),

              /// ------- Isi artikel -------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
            ],
          ),
        ],
      ),

      /// ------- CTA bawah -------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: GestureDetector(
            onLongPress: () => context.go('/kenali/riasec-intro'), // DEV shortcut
            child: ElevatedButton(
              onPressed: () async {
                final ok = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF102542)),
  );
}

class _MetricItem extends StatelessWidget {
  final String value;
  final String label;
  const _MetricItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF2E6BFF)),
        ),
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
/// BOTTOM SHEET – KODE AKSES
/// ============================================================================
class _AccessCodeSheet extends StatefulWidget {
  const _AccessCodeSheet();

  @override
  State<_AccessCodeSheet> createState() => _AccessCodeSheetState();
}

class _AccessCodeSheetState extends State<_AccessCodeSheet> {
  final c = TextEditingController();
  String? error;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
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
            Row(
              children: [
                const Expanded(
                  child: Text('Kode Akses Kenali Diri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
              ],
            ),
            Text(
              'Masukkan kode akses yang didapat dari pembelian via website, Lynk, atau WhatsApp',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: c,
              decoration: const InputDecoration(hintText: 'Masukkan Kode Akses'),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (c.text.trim().toUpperCase() == 'REXTRA') {
                  Navigator.pop(context, true);
                } else {
                  setState(() => error = 'Upps, kode salah/sudah pernah digunakan!!');
                }
              },
              child: const Text('Mulai Kenali Diri'),
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: () {}, child: const Text('Beli Kode Akses')),
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
  static const int totalQuestions = 72;
  static const int perSection = 12;
  static const int sections = totalQuestions ~/ perSection; // 6

  /// dummy 72 soal (boleh diganti real)
  final List<String> _questions = List.generate(
    totalQuestions,
        (i) => 'Saya senang merakit dan memperbaiki komputer, laptop, atau perangkat elektronik (soal ${i + 1}).',
  );

  /// jawaban: indexSoal -> 0..4
  final Map<int, int> _answers = {};

  int _section = 0; // 0..5

  int get _start => _section * perSection;
  int get _end => _start + perSection;

  double get _progress =>
      _answers.length == 0 ? 0 : (_answers.length / totalQuestions);

  @override
  Widget build(BuildContext context) {
    final firstNumber = _start + 1; // contoh tampilan "Soal ke 1 dari 72"
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _safeBack(context, fallback: '/kenali/riasec-intro'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
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

          /// -------- 12 soal dalam 1 bagian (scroll vertikal) ----------
          ...List.generate(perSection, (i) {
            final qIndex = _start + i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RiasecQuestionCard(
                number: qIndex + 1,
                question: _questions[qIndex],
                selected: _answers[qIndex],
                onSelect: (opt) => setState(() => _answers[qIndex] = opt),
              ),
            );
          }),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          /// -------- Indikator "Bagian Soal ke:" ----------
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
                      left: i == 0 ? 0 : 6, right: i == sections - 1 ? 0 : 6),
                  child: _SectionDot(
                    label: '${i + 1}',
                    selected: selected,
                    onTap: () => setState(() => _section = i),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 100),
        ],
      ),

      /// -------- Navigasi bawah ----------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _section == 0
                      ? null
                      : () => setState(() => _section--),
                  child: const Text('Sebelumnya'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_section < sections - 1) {
                      setState(() => _section++);
                    } else {
                      // semua bagian selesai -> ke IKIGAI Intro
                      context.go('/kenali/ikigai-intro');
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
}

/// Kartu 1 soal RIASEC
class _RiasecQuestionCard extends StatelessWidget {
  const _RiasecQuestionCard({
    required this.number,
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final int number; // 1..72
  final String question;
  final int? selected; // 0..4
  final ValueChanged<int> onSelect;

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
          Row(children: [
            _Badge('Soal $number'),
            const SizedBox(width: 8),
            const _Badge('Skala: Peminatan',
                color: Color(0xFFEAF1FF), textColor: Color(0xFF2E6BFF)),
          ]),
          const SizedBox(height: 8),
          Text(question, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          /// ------------ 5 opsi mendatar, lebar sama ---------------
          Row(
            children: List.generate(5, (opt) {
              final isSel = selected == opt;
              return Expanded(
                child: Padding(
                  padding:
                  EdgeInsets.only(right: opt == 4 ? 0 : 8), // jarak antar kolom
                  child: InkWell(
                    onTap: () => onSelect(opt),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 120, // supaya tinggi tiap kotak sama
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
                          Image.asset(_faceAssets[opt], width: 38, height: 38),
                          const SizedBox(height: 6),
                          Text(
                            _scaleLabels[opt],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Dot/Chip nomor bagian (1..6)
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Badge(this.text, {this.color = const Color(0xFF2E6BFF), this.textColor = Colors.white});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
    );
  }
}

class _FaceOption extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FaceOption({required this.iconAsset, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 112,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? const Color(0xFF2E6BFF) : const Color(0xFFE6EAF3), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0xFFEAF1FF) : Colors.white,
        ),
        child: Column(
          children: [
            Image.asset(iconAsset, width: 40, height: 40),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// IKIGAI TEST – opsi TEKS, max 2 pilihan per halaman (dummy 5 halaman)
/// ============================================================================
class IkigaiTestPage extends StatefulWidget {
  const IkigaiTestPage({super.key});

  @override
  State<IkigaiTestPage> createState() => _IkigaiTestPageState();
}

class _IkigaiTestPageState extends State<IkigaiTestPage> {
  // 5 halaman; opsi sama untuk demo
  final List<List<String>> _options = List.generate(
    5,
        (_) => [
      'Menciptakan pengalaman digital interaktif yang memikat pengguna dengan grafis, animasi, dan audio yang dinamis',
      'Merancang dan membangun pengalaman dan lingkungan simulasi dimana pengguna dapat berinteraksi dan terlibat',
      'Mengembangkan Aplikasi yang menggabungkan dunia nyata dengan elemen virtual, menciptakan pengalaman yang imersif dan informatif',
      'Menulis kode yang menghidupkan karakter dan cerita dalam dunia virtual yang mempesona',
      'Menulis kode yang menghidupkan karakter dan cerita dalam dunia virtual yang mempesona',
    ],
  );

  int halaman = 0;
  final Map<int, Set<int>> _selected = {}; // halaman -> index opsi

  @override
  Widget build(BuildContext context) {
    final progress = (halaman + 1) / _options.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => _safeBack(context, fallback: '/kenali/ikigai-intro'), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('IKIGAI TEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              Text('Soal ke ${halaman + 1} dari ${_options.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, minHeight: 8, color: const Color(0xFF2E6BFF), backgroundColor: const Color(0xFFE6EAF3)),
          const SizedBox(height: 14),

          _IkigaiQuestionCard(
            nomor: halaman + 1,
            options: _options[halaman],
            selected: _selected[halaman] ?? <int>{},
            onToggle: (i) {
              setState(() {
                final set = _selected.putIfAbsent(halaman, () => <int>{});
                if (set.contains(i)) {
                  set.remove(i);
                } else {
                  if (set.length < 2) set.add(i);
                }
              });
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
                    if (halaman < _options.length - 1) {
                      setState(() => halaman++);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selesai – hasil akan diproses!')),
                      );
                      context.go('/home');
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
}

class _IkigaiQuestionCard extends StatelessWidget {
  final int nomor;
  final List<String> options;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  const _IkigaiQuestionCard({required this.nomor, required this.options, required this.selected, required this.onToggle});

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
          Row(children: const [_Badge('Soal 1')]),
          const SizedBox(height: 8),
          const Text(
            'Di antara aktivitas berikut, pilih satu atau dua yang paling anda sukai, paling menarik bagi anda, '
                'dan dapat anda lakukan secara rutin dalam jangka panjang',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
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
                      Icon(sel ? Icons.check_circle : Icons.circle_outlined, color: sel ? const Color(0xFF2E6BFF) : const Color(0xFF9AA5B1)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(options[i])),
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
