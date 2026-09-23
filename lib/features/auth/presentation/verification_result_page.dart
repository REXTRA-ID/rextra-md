import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_service.dart';

/// Halaman yang dibuka dari link verifikasi di email
/// (contoh: https://rextra.io/verifikasi-akun?token=...).
/// Memanggil endpoint verify ke backend lalu menampilkan hasilnya.
class VerificationResultPage extends StatefulWidget {
  final String token;

  const VerificationResultPage({super.key, required this.token});

  @override
  State<VerificationResultPage> createState() =>
      _VerificationResultPageState();
}

enum _VerifyState { loading, success, failed }

class _VerificationResultPageState extends State<VerificationResultPage> {
  final _auth = AuthService();
  _VerifyState _state = _VerifyState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    if (widget.token.isEmpty) {
      setState(() {
        _state = _VerifyState.failed;
        _errorMessage = 'Tautan verifikasi tidak valid.';
      });
      return;
    }
    try {
      await _auth.verifyEmail(token: widget.token);
      if (!mounted) return;
      setState(() => _state = _VerifyState.success);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _VerifyState.failed;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/rextra.png', height: 26),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _state == _VerifyState.loading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              _state == _VerifyState.success
                                  ? 'assets/images/VerifikasiEmailResetPasswordUlang.png'
                                  : 'assets/images/VerifikasiEmailGagal.png',
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 28),
                            Text(
                              _state == _VerifyState.success
                                  ? 'Verifikasi Berhasil!'
                                  : 'Verifikasi Gagal',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _state == _VerifyState.success
                                  ? 'Akun kamu sudah terverifikasi. Yuk, mulai jelajahi REXTRA sekarang!'
                                  : (_errorMessage ??
                                      'Tautan verifikasi sudah tidak berlaku.'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_state != _VerifyState.loading)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4ED8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _state == _VerifyState.success
                          ? 'Masuk Sekarang'
                          : 'Kembali ke Login',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
