import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_service.dart';
import 'verify_failed_dialog.dart';

class VerifyEmailPage extends StatefulWidget {
  final String mode; // sent | expired | resent
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.mode,
    required this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _auth = AuthService();
  bool loading = false;

  Future<void> _resend() async {
    setState(() => loading = true);
    try {
      await _auth.resendVerification(widget.email);

      if (!mounted) return;

      context.go('/verify?mode=resent&email=${Uri.encodeQueryComponent(widget.email)}');
    } catch (_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => VerifyFailedDialog(
          onBack: () {},
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = widget.mode == 'expired';
    final isResent  = widget.mode == 'resent';

    String image;
    String title;
    String subtitle;
    String primaryLabel;

    if (isExpired) {
      image = 'assets/images/TautanVerifikasiKadaluarsa.png';
      title = 'Verifikasi Akun Gagal';
      subtitle =
      'Maaf, tautan verifikasi sudah kadaluarsa. '
          'Klik tombol di bawah untuk mendapatkan tautan verifikasi terbaru.';
      primaryLabel = 'Kirim Verifikasi';
    } else if (isResent) {
      image = 'assets/images/VerifikasiEmailUlang.png';
      title = 'Verifikasi Email Dikirim Ulang';
      subtitle =
      'Kami telah mengirimkan email verifikasi ke ${widget.email}. '
          'Periksa kotak masuk atau spam dan klik tautan dalam 24 jam sebelum kadaluarsa.';
      primaryLabel = 'Kirim Ulang Email';
    } else {
      image = 'assets/images/VerifikasiEmail.png';
      title = 'Periksa Email Sekarang';
      subtitle =
      'Kami telah mengirimkan email verifikasi ke ${widget.email}. '
          'Periksa kotak masuk atau spam dan klik tautan dalam 24 jam sebelum kadaluarsa.';
      primaryLabel = 'Kirim Ulang Email';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/auth/login'),
        ),
        title: Image.asset(
          'assets/images/rextra.png',
          height: 26,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      image,
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isExpired) ...[
                const Text(
                  'Belum menerima tautan verifikasi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
              ],

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _resend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => context.go('/register'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDDE7FF),
                    foregroundColor: const Color(0xFF1E4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Ganti Email',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}