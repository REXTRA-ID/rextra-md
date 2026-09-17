import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../kenalidiri_controller.dart';
import '../../../core/utils/nav_utils.dart';

class KenaliDiriHomePage extends ConsumerWidget {
  const KenaliDiriHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kenaliDiriProvider);
    final controller = ref.read(kenaliDiriProvider.notifier);

    if (state.lockState == KenaliLockState.personaLocked) {
      return const _PersonaLockedPage();
    }

    if (state.lockState == KenaliLockState.membershipLocked) {
      return Consumer(
        builder: (context, ref, _) {
          final s = ref.watch(kenaliDiriProvider);
          return _MembershipLockedPage(
            membershipTier: s.membershipTier,
            tokenOwned: s.tokenOwned,
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _appBar(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            const SizedBox(height: 6),

            Image.asset(
              'assets/images/kenali_diri/BannerKenaliDiri.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MembershipCard(
                isPro: state.membershipTier == MembershipTier.pro,
                tokenOwned: state.tokenOwned,
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Asesmen Karier',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1450E3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showInfoSheet(context),
                    icon: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            ...state.assessments.map(
                  (e) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _AssessmentCard(
                  item: e,
                  onTap: () {
                    if (!controller.hasEnoughToken(e.tokenCost)) {
                      _showTokenNotEnoughSheet(context, e.tokenCost);
                      return;
                    }
                    // TODO: route ke flow tes
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () => context.push('/kenali/history'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1450E3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lihat Riwayat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF3F4F6),
      surfaceTintColor: const Color(0xFFF3F4F6),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => popOrGo(context, '/home'),
      ),
      title: const Text(
        'KENALI DIRI',
        style: TextStyle(
          color: Color(0xFF1E63F6),
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _InfoBottomSheet(),
    );
  }

  void _showTokenNotEnoughSheet(BuildContext context, int need) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _TokenNotEnoughSheet(need: need),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final bool isPro;
  final int tokenOwned;

  const _MembershipCard({
    required this.isPro,
    required this.tokenOwned,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 343 / 94,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/images/kenali_diri/StatusMembership.png',
                fit: BoxFit.fill,
              ),
            ),
          ),

          Positioned(
            left: 14,
            top: 10,
            child: Image.asset(
              isPro
                  ? 'assets/images/kenali_diri/Pro.png'
                  : 'assets/images/kenali_diri/Basic.png',
              width: 76,
              height: 76,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            left: 100,
            top: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Membership',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPro ? 'PRO - REXTRA CLUB' : 'BASIC - REXTRA CLUB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 20,
            top: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Token Dimiliki',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/kenali_diri/Group48098863.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$tokenOwned',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final AssessmentItem item;
  final VoidCallback onTap;

  const _AssessmentCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF1450E3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item.bannerAsset,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: item.badge.color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.badge.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF1450E3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.asset(
                                'assets/images/kenali_diri/Group48098863.png',
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.tokenCost}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaLockedPage extends StatelessWidget {
  const _PersonaLockedPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => popOrGo(context, '/home'),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/kenali_diri/BackgroundAwan.png',
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              const SizedBox(height: 18),
              Image.asset(
                'assets/images/kenali_diri/PembatasanaksesfiturUntukPersona.png',
                height: 300,
              ),
              const SizedBox(height: 12),
              const Text(
                'Fitur Kenali Diri Terkunci',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sebagai Nama Persona, akses Kenali Diri masih terkunci karena misi wajib belum diselesaikan.\nSelesaikan misi berikut untuk membuka akses.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/kenali_diri/school-sharp.png',
                          width: 34,
                          height: 34,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Simpan data pendidikan terkini dan terdahulu di fitur Jejak Studi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Belum Selesai',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '5 poin',
                          style: TextStyle(
                            color: Color(0xFF1450E3),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1450E3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Detail Progres Persona',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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

class _MembershipLockedPage extends StatelessWidget {
  final MembershipTier membershipTier;
  final int tokenOwned;

  const _MembershipLockedPage({
    required this.membershipTier,
    required this.tokenOwned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => popOrGo(context, '/home'),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/kenali_diri/BackgroundAwan.png',
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/kenali_diri/MascotRexiSenyumTipis1.png',
                height: 280,
              ),
              const SizedBox(height: 12),
              const Text(
                'Fitur Kenali Diri Terkunci',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                'Status Membership kamu saat ini belum berhak mengakses fitur Kenali Diri.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 18),
              _MembershipCard(
                isPro: membershipTier == MembershipTier.pro,
                tokenOwned: tokenOwned,
              ),
              const SizedBox(height: 18),
              const Text(
                'Upgrade ke REXTRA Club untuk membuka akses fitur ini, atau cek kembali hak akses akun kamu pada membership saat ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1450E3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Upgrade Membership',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 58,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Lihat Hak Akses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
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

class _InfoBottomSheet extends StatelessWidget {
  const _InfoBottomSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Color(0xFF1450E3)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Informasi Umum',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tentang fitur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam dignissim posuere semper...',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: const Text('Lihat Selengkapnya'),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kategori Tes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kategori membantu menentukan prioritas asesmen sesuai kebutuhanmu',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 14),
            _InfoChip(
              text: 'WAJIB',
              color: const Color(0xFFE85050),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam dignissim posuere semper...',
              ),
            ),
            const SizedBox(height: 14),
            _InfoChip(
              text: 'DISARANKAN',
              color: const Color(0xFF1450E3),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam dignissim posuere semper...',
              ),
            ),
            const SizedBox(height: 14),
            _InfoChip(
              text: 'PENGUAT',
              color: const Color(0xFF1FB9B2),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam dignissim posuere semper...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _TokenNotEnoughSheet extends StatelessWidget {
  final int need;

  const _TokenNotEnoughSheet({required this.need});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/kenali_diri/berbagaibannerrextra-032.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Token Tidak Mencukupi Untuk\nAkses Asesmen',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'Dibutuhkan $need token untuk melanjutkan. Beli token untuk membuka asesmen.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1450E3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Beli Token',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}