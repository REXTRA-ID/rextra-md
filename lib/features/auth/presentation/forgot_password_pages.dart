import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_service.dart';
import '../../../core/utils/nav_utils.dart';

class _AuthUi {
  static const primaryBlue = Color(0xFF1E4ED8);
  static const softBlue = Color(0xFFDDE7FF);
  static const border = Color(0xFFD7DDE5);

  static InputDecoration inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9AA4B2)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryBlue, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.2),
      ),
    );
  }

  static Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  static PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => popOrGo(context, '/login'),
      ),
      title: Image.asset('assets/images/rextra.png', height: 26),
    );
  }

  static Widget hero({
    required String asset,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Image.asset(asset, height: 260, fit: BoxFit.contain),
        const SizedBox(height: 26),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  static Widget primaryButton({
    required bool loading,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: primaryBlue.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: softBlue,
          foregroundColor: primaryBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// 1) Lupa kata sandi – minta email (UI: ForgotPasswordd.png)
class ForgotPasswordRequestPage extends StatefulWidget {
  const ForgotPasswordRequestPage({super.key});

  @override
  State<ForgotPasswordRequestPage> createState() =>
      _ForgotPasswordRequestPageState();
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
      if (!mounted) return;
      final q = Uri.encodeQueryComponent(emailC.text.trim());
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
      backgroundColor: Colors.white,
      appBar: _AuthUi.appBar(context),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              _AuthUi.hero(
                asset: 'assets/images/ForgotPasswordd.png',
                title: 'Lupa Kata Sandi',
                subtitle: 'Hi Sobat REXTRA! Masukkan email kamu, dan\n'
                    'kami akan kirim tautan untuk atur ulang kata sandi.',
              ),
              const SizedBox(height: 26),
              _AuthUi.label('Alamat Email'),
              TextFormField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => loading ? null : _submit(),
                validator: _emailValidator,
                decoration:
                    _AuthUi.inputDecoration('Masukkan alamat email kamu'),
                enabled: !loading,
              ),
              const SizedBox(height: 26),
              _AuthUi.primaryButton(
                loading: loading,
                text: 'Kirim Tautan',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2) Reset password terkirim (UI: ResetPasswordDikirim.png)
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
      // Optional: pindah ke screen "sent" tetap sama, cukup snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan reset dikirim ulang')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal kirim ulang: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AuthUi.appBar(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _AuthUi.hero(
              asset: 'assets/images/ResetPasswordDikirim.png',
              title: 'Reset Password Terkirim',
              subtitle: 'Kami telah mengirim tautan reset sandi ke\n'
                  '${widget.email}. Periksa kotak masuk/spam\n'
                  'dan klik dalam 24 jam sebelum kadaluarsa',
            ),
            const SizedBox(height: 28),
            const Text(
              'Belum menerima tautan reset?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            _AuthUi.primaryButton(
              loading: loading,
              text: 'Kirim Ulang',
              onPressed: _resend,
            ),
            const SizedBox(height: 14),
            _AuthUi.secondaryButton(
              text: 'Ganti Email',
              onPressed: () => context.go('/forgot'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3) Reset kata sandi gagal/kadaluarsa (UI: ResetKataSandiGagal.png)
class ForgotPasswordExpiredPage extends StatefulWidget {
  final String email;
  const ForgotPasswordExpiredPage({super.key, required this.email});

  @override
  State<ForgotPasswordExpiredPage> createState() =>
      _ForgotPasswordExpiredPageState();
}

class _ForgotPasswordExpiredPageState extends State<ForgotPasswordExpiredPage> {
  final _auth = AuthService();
  bool loading = false;

  Future<void> _resend() async {
    setState(() => loading = true);
    try {
      await _auth.requestPasswordReset(widget.email);
      if (!mounted) return;
      final q = Uri.encodeQueryComponent(widget.email);
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
      backgroundColor: Colors.white,
      appBar: _AuthUi.appBar(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _AuthUi.hero(
              asset: 'assets/images/ResetKataSandiGagal.png',
              title: 'Reset Kata Sandi Gagal',
              subtitle: 'Maaf, tautan telah kadaluarsa. Kamu masih\n'
                  'dapat memperoleh tautan baru dengan\n'
                  'mengklik tombol di bawah ini.',
            ),
            const SizedBox(height: 28),
            _AuthUi.primaryButton(
              loading: loading,
              text: 'Kirim Ulang',
              onPressed: _resend,
            ),
            const SizedBox(height: 14),
            _AuthUi.secondaryButton(
              text: 'Ganti Email',
              onPressed: () => context.go('/forgot'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4) Buat password baru (UI: PasswordBaru.png)
class NewPasswordPage extends StatefulWidget {
  final String token;
  const NewPasswordPage({super.key, required this.token});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  final _auth = AuthService();

  bool show1 = false;
  bool show2 = false;
  bool loading = false;

  @override
  void dispose() {
    passC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Kata sandi wajib diisi';
    if (s.length < 8) return 'Minimal 8 karakter';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (passC.text != confirmC.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak sama')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await _auth.changePassword(
        token: widget.token,
        newPassword: passC.text.trim(),
      );
      if (!mounted) return;
      context.go('/forgot/success');
    } catch (e) {
      if (!mounted) return;
      // kalau backend kasih info expired/invalid token, kamu bisa arahkan ke /forgot/expired
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
      backgroundColor: Colors.white,
      appBar: _AuthUi.appBar(context),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              _AuthUi.hero(
                asset: 'assets/images/PasswordBaru.png',
                title: 'Buat Password Baru',
                subtitle: 'Hi Sobat REXTRA! Masukkan email kamu, dan\n'
                    'akan kirim tautan untuk atur ulang kata sandi.',
              ),
              const SizedBox(height: 26),
              _AuthUi.label('Kata Sandi Baru'),
              TextFormField(
                controller: passC,
                validator: _passwordValidator,
                obscureText: !show1,
                enabled: !loading,
                textInputAction: TextInputAction.next,
                decoration: _AuthUi.inputDecoration(
                  'Masukkan kata sandi baru',
                  suffixIcon: IconButton(
                    icon: Icon(show1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => show1 = !show1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _AuthUi.label('Konfirmasi Kata Sandi Baru'),
              TextFormField(
                controller: confirmC,
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'Wajib diisi';
                  if ((v ?? '') != passC.text) return 'Konfirmasi tidak sama';
                  return null;
                },
                obscureText: !show2,
                enabled: !loading,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => loading ? null : _submit(),
                decoration: _AuthUi.inputDecoration(
                  'Masukkan ulang kata sandi',
                  suffixIcon: IconButton(
                    icon: Icon(show2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => show2 = !show2),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _AuthUi.primaryButton(
                loading: loading,
                text: 'Ganti Password',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5) Sukses (UI: Group.png)
class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AuthUi.appBar(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _AuthUi.hero(
              asset: 'assets/images/Group.png',
              title: 'Kata Sandi Berhasil Diubah',
              subtitle: 'Selamat! Kata sandi kamu berhasil\n'
                  'diperbarui. Sekarang, kamu bisa masuk\n'
                  'kembali ke akun REXTRA kamu dengan\n'
                  'kata sandi yang baru.',
            ),
            const SizedBox(height: 28),
            _AuthUi.primaryButton(
              loading: false,
              text: 'Masuk Sekarang',
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
