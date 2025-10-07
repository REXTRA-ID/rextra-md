import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_service.dart';

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
  final _auth = AuthService();
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
      await _auth.requestPasswordReset(emailC.text.trim());
      final q = Uri.encodeQueryComponent(emailC.text.trim());
      if (!mounted) return;
      context.go('/forgot/sent?email=$q');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengirim tautan: $e')));
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

/// Dialog input token manual (dipakai di Sent & Expired)
Future<void> _showManualTokenDialog(BuildContext context) async {
  final c = TextEditingController();
  String? fromClipboard;
  try {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    fromClipboard = data?.text;
  } catch (_) {}

  final tokenReg = RegExp(r'token=([^&]+)'); // kalau user paste full URL

  final result = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Tempel Token Manual'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: c,
            decoration: const InputDecoration(
              hintText: 'Tempel token di sini (atau URL lengkap)',
            ),
            maxLines: 2,
          ),
          if ((fromClipboard ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () { c.text = fromClipboard!; },
                icon: const Icon(Icons.paste),
                label: const Text('Tempel dari Clipboard'),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: ()=>Navigator.pop(context, c.text.trim()), child: const Text('Gunakan')),
      ],
    ),
  );

  if (result != null && result.isNotEmpty) {
    // kalau yang dipaste URL, ekstrak token=
    var token = result;
    final m = tokenReg.firstMatch(result);
    if (m != null) token = Uri.decodeComponent(m.group(1)!);

    final q = Uri.encodeQueryComponent(token);
    if (context.mounted) context.go('/forgot/new?token=$q');
  }
}

/// 2) Tautan reset terkirim (maskot rex51)
class ForgotPasswordSentPage extends StatefulWidget {
  final String email;
  const ForgotPasswordSentPage({super.key, required this.email});

  @override
  State<ForgotPasswordSentPage> createState() => _ForgotPasswordSentPageState();
}

class _ForgotPasswordSentPageState extends State<ForgotPasswordSentPage> {
  final _auth = AuthService();
  bool loading = false;

  Future<void> _resend() async {
    setState(() => loading = true);
    try {
      await _auth.requestPasswordReset(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tautan reset dikirim ulang')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal kirim ulang: $e')));
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CloudHeroPanel(
              mascotAsset: 'assets/images/rex51.png',
              title: 'Reset Password Terkirim',
              subtitle:
              'Kami telah mengirim tautan reset sandi ke ${widget.email}. Periksa kotak masuk/spam dan klik dalam 24 jam sebelum kadaluarsa.',
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
                    onPressed: loading ? null : _resend,
                    child: loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Kirim Ulang'),
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
                  const SizedBox(height: 18),
                  // ====== Tambahan: testing manual token ======
                  OutlinedButton.icon(
                    onPressed: () => _showManualTokenDialog(context),
                    icon: const Icon(Icons.vpn_key),
                    label: const Text('Saya sudah terima token (tempel manual)'),
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
class ForgotPasswordExpiredPage extends StatefulWidget {
  final String email;
  const ForgotPasswordExpiredPage({super.key, required this.email});

  @override
  State<ForgotPasswordExpiredPage> createState() => _ForgotPasswordExpiredPageState();
}

class _ForgotPasswordExpiredPageState extends State<ForgotPasswordExpiredPage> {
  final _auth = AuthService();
  bool loading = false;

  Future<void> _resend() async {
    setState(() => loading = true);
    try {
      await _auth.requestPasswordReset(widget.email);
      final q = Uri.encodeQueryComponent(widget.email);
      if (!mounted) return;
      context.go('/forgot/sent?email=$q');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal kirim ulang: $e')));
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
                    onPressed: loading ? null : _resend,
                    child: loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Kirim Ulang'),
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
                  const SizedBox(height: 18),
                  // ====== Tambahan: testing manual token ======
                  OutlinedButton.icon(
                    onPressed: () => _showManualTokenDialog(context),
                    icon: const Icon(Icons.vpn_key),
                    label: const Text('Saya sudah terima token (tempel manual)'),
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
  final tokenC = TextEditingController(); // untuk input token manual
  final _auth = AuthService();
  bool show1 = false, show2 = false, loading = false;
  late String _tokenInUse;

  @override
  void initState() {
    super.initState();
    _tokenInUse = widget.token;
    tokenC.text = widget.token;
  }

  @override
  void dispose() {
    passC.dispose();
    confirmC.dispose();
    tokenC.dispose();
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
    if (_tokenInUse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan. Tempel token terlebih dahulu.')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await _auth.changePassword(token: _tokenInUse, newPassword: passC.text);
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

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = (data?.text ?? '').trim();
      if (text.isEmpty) return;
      // support kalau user paste URL penuh
      final m = RegExp(r'token=([^&]+)').firstMatch(text);
      final tok = m != null ? Uri.decodeComponent(m.group(1)!) : text;
      setState(() {
        _tokenInUse = tok;
        tokenC.text = tok;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token ditempel')));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final missingToken = _tokenInUse.isEmpty;

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
              Text('Masukkan kata sandi barumu di bawah ini.', style: Theme.of(context).textTheme.bodyMedium),

              // ====== Banner/token manual bila token kosong ======
              const SizedBox(height: 16),
              if (missingToken) Card(
                color: const Color(0xFFFFF7E6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Token belum terbaca dari tautan',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tempel token reset password di bawah ini (boleh tempel URL penuh dari email).'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: tokenC,
                        decoration: InputDecoration(
                          hintText: 'Tempel token / URL di sini',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.paste),
                            onPressed: _pasteFromClipboard,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 2,
                        onChanged: (v){
                          final m = RegExp(r'token=([^&]+)').firstMatch(v);
                          _tokenInUse = m != null ? Uri.decodeComponent(m.group(1)!) : v.trim();
                        },
                      ),
                    ],
                  ),
                ),
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
