import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatefulWidget {
  final String mode; // sent | resent | expired
  final String email;
  const VerifyEmailPage({super.key, required this.mode, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  void _showFailedDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/notapproved.png', height: 96),
              const SizedBox(height: 16),
              const Text(
                'Verifikasi Gagal Terkirim',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Permintaan verifikasi sudah diterima. Coba lagi setelah 1 jam agar tidak terdeteksi spam, dan cek email kamu setelahnya.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = widget.mode == 'expired';
    final isResent  = widget.mode == 'resent';

    // konten dinamis
    final String iconAsset = isExpired ? 'assets/images/rex41.png' : 'assets/images/rex51.png';
    final String title, subtitle, primaryLabel;
    if (isExpired) {
      title = 'Verifikasi Email Kadaluarsa';
      subtitle = 'Maaf, tautan verifikasi sudah kadaluarsa. Klik tombol di bawah untuk mendapatkan tautan verifikasi terbaru.';
      primaryLabel = 'Kirim Verifikasi';
    } else if (isResent) {
      title = 'Verifikasi Email Dikirim Ulang';
      subtitle = 'Email verifikasi telah dikirim ulang ke ${widget.email}. Periksa kotak masuk/spam dan klik tautan dalam 24 jam sebelum kadaluarsa.';
      primaryLabel = 'Kirim Ulang Email';
    } else {
      title = 'Periksa Email Sekarang';
      subtitle = 'Kami telah mengirimkan email verifikasi ke ${widget.email}. Periksa kotak masuk atau spam dan klik tautan dalam 24 jam sebelum kadaluarsa.';
      primaryLabel = 'Kirim Ulang Email';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, cons) {
          final w = MediaQuery.of(context).size.width;

          // panel & tata letak
          final double panelH  = (w * 1.00).clamp(480.0, 570.0);
          final double mascotW = panelH * 0.40;
          final double textTop = panelH * 0.58; // sedikit lebih tinggi agar aman

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= FULL-BLEED PANEL =================
                SizedBox(
                  width: w,
                  height: panelH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ====== background awan (satu file full) ======
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/cloud.png', // << semua diganti ke satu background
                          fit: BoxFit.cover,
                        ),
                      ),

                      // ====== maskot ======
                      Align(
                        alignment: const Alignment(0, -0.45), // agak naik biar teks muat
                        child: Image.asset(iconAsset, width: mascotW, fit: BoxFit.contain),
                      ),

                      // ====== teks ======
                      Positioned(
                        left: 20,
                        right: 20,
                        top: textTop,
                        child: Column(
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                color: Color(0xFF102542),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                color: Color(0xFF2E3A4C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= KONTEN BAWAH =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isExpired) ...[
                        const Text(
                          'Belum menerima tautan verifikasi?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          // TODO: call resend API; jika rate-limited => _showFailedDialog();
                          final emailQ = Uri.encodeQueryComponent(widget.email);
                          if (isExpired) {
                            context.go('/verify?mode=sent&email=$emailQ');
                          } else {
                            context.go('/verify?mode=resent&email=$emailQ');
                          }
                        },
                        child: Text(primaryLabel),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () => context.go('/register'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEAF1FF),
                          foregroundColor: const Color(0xFF2E6BFF),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Ganti Email'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
