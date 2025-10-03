import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Panel hero awan + maskot + judul/subjudul
class _CloudHeroPanel extends StatelessWidget {
  const _CloudHeroPanel({
    required this.mascotAsset,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String mascotAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Samakan dengan VerifyEmailPage
    final double panelH  = (w * 1.00).clamp(480.0, 570.0);
    final double mascotW = panelH * 0.46;
    final double textTop = panelH * 0.62;

    return SizedBox(
      width: w,
      height: panelH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgawanawan.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: const Alignment(-0.3, -0.50),
            child: Image.asset(
              mascotAsset,
              width: mascotW * 1.2,
              fit: BoxFit.contain,
            ),
          ),
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
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
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
    );
  }
}

/// 1) Lupa kata sandi – minta email
class ForgotPasswordRequestPage extends StatefulWidget {
  const ForgotPasswordRequestPage({super.key});
  @override
  State<ForgotPasswordRequestPage> createState() => _ForgotPasswordRequestPageState();
}

class _ForgotPasswordRequestPageState extends State<ForgotPasswordRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailC.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email wajib diisi';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return 'Format email tidak valid';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      // TODO: panggil API request reset, mis. POST /auth/forgot-password
      // await _auth.requestReset(emailC.text.trim());

      final q = Uri.encodeQueryComponent(emailC.text.trim());
      if (!mounted) return;
      context.go('/forgot/sent?email=$q');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim tautan: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>context.pop(), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Lupa Kata Sandi',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hi Sobat REXTRA! Masukkan email kamu, dan kami akan kirim tautan untuk atur ulang kata sandi.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Text('Alamat Email', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailC,
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Masukkan alamat email kamu'),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Kirim Tautan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2) Tautan reset terkirim (maskot rex51)
class ForgotPasswordSentPage extends StatelessWidget {
  final String email;
  const ForgotPasswordSentPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>context.pop(), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CloudHeroPanel(
              mascotAsset: 'assets/images/rex51.png',
              title: 'Reset Password Terkirim',
              subtitle: 'Kami telah mengirim tautan reset sandi ke $email. Periksa kotak masuk/spam dan klik dalam 24 jam sebelum kadaluarsa.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Belum menerima tautan reset?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // TODO: call resend reset password endpoint
                      // await _auth.resendReset(email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tautan reset dikirim ulang (dummy)')),
                      );
                    },
                    child: const Text('Kirim Ulang'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.go('/forgot'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF1FF),
                      foregroundColor: const Color(0xFF2E6BFF),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Ganti Email'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3) Tautan reset kadaluarsa (maskot rex41)
class ForgotPasswordExpiredPage extends StatelessWidget {
  final String email;
  const ForgotPasswordExpiredPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>context.pop(), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CloudHeroPanel(
              mascotAsset: 'assets/images/rex41.png',
              title: 'Reset Password Kadaluarsa',
              subtitle: 'Maaf, tautan telah kadaluarsa. Kamu masih dapat memperoleh tautan baru dengan mengklik tombol di bawah ini.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // TODO: kirim ulang reset untuk email terkait
                      final q = Uri.encodeQueryComponent(email);
                      context.go('/forgot/sent?email=$q');
                    },
                    child: const Text('Kirim Ulang'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.go('/forgot'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF1FF),
                      foregroundColor: const Color(0xFF2E6BFF),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Ganti Email'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4) Buat Password Baru (tanpa maskot)
class NewPasswordPage extends StatefulWidget {
  final String token; // token dari email reset
  const NewPasswordPage({super.key, required this.token});
  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  bool show1 = false, show2 = false, loading = false;

  @override
  void dispose() {
    passC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Kata sandi wajib diisi';
    if (s.length < 8) return 'Minimal 8 karakter';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (passC.text != confirmC.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi tidak sama')),
      );
      return;
    }
    setState(() => loading = true);
    try {
      // TODO: panggil API reset password pakai token
      // await _auth.resetPassword(token: widget.token, newPassword: passC.text);

      if (!mounted) return;
      context.go('/forgot/success');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengganti password: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>context.pop(), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                'Buat Password Baru',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Masukkan kata sandi barumu di bawah ini.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Text('Kata Sandi Baru', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: passC,
                validator: _passwordValidator,
                obscureText: !show1,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi baru',
                  suffixIcon: IconButton(
                    icon: Icon(show1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: ()=>setState(()=>show1 = !show1),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Konfirmasi Kata Sandi Baru', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: confirmC,
                validator: (v){
                  if ((v ?? '').isEmpty) return 'Wajib diisi';
                  if (v != passC.text) return 'Konfirmasi tidak sama';
                  return null;
                },
                obscureText: !show2,
                decoration: InputDecoration(
                  hintText: 'Masukkan ulang kata sandi',
                  suffixIcon: IconButton(
                    icon: Icon(show2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: ()=>setState(()=>show2 = !show2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Ganti Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5) Sukses ubah password (maskot rex51)
class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>context.pop(), icon: const Icon(Icons.arrow_back_ios_new)),
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CloudHeroPanel(
              mascotAsset: 'assets/images/rex51.png',
              title: 'Password Telah Berhasil Dirubah',
              subtitle:
              'Selamat! Kata sandi barumu sudah berhasil disimpan. Sekarang kamu bisa login ke akun REXTRA dengan kata sandi yang baru.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Masuk Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
