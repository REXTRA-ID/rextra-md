import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  final phoneC = TextEditingController();

  bool agree = false;
  bool showPass = false;
  bool showConfirm = false;
  bool loading = false;

  final _auth = AuthService();

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email wajib diisi';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return 'Format email tidak valid';
    return null;
  }

  String? _passwordValidator(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'Minimal 8 karakter';
    // kalau backend mewajibkan kombinasi, aktifkan baris2 ini:
    // if (!RegExp(r'[A-Z]').hasMatch(s)) return 'Harus ada huruf besar';
    // if (!RegExp(r'[a-z]').hasMatch(s)) return 'Harus ada huruf kecil';
    // if (!RegExp(r'[0-9]').hasMatch(s)) return 'Harus ada angka';
    // if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(s)) return 'Harus ada simbol';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu harus menyetujui syarat & ketentuan')),
      );
      return;
    }
    if (passC.text != confirmC.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak sama')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await _auth.register(
        fullname: nameC.text.trim(),
        email: emailC.text.trim(),
        password: passC.text.trim(),
        phone: phoneC.text.trim(), // wajib -> dikirim sebagai phone_number
      );

      final email = Uri.encodeQueryComponent(emailC.text.trim());
      if (!mounted) return;
      // Sukses register → pindah flow ke verifikasi (pakai go)
      context.go('/verify?mode=sent&email=$email');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NOTE: Tidak set 'leading' manual → biar AppBar pakai implyLeading.
      appBar: AppBar(
        automaticallyImplyLeading: false, // matikan panah dekor
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(), // panah asli
        ),
        title: Image.asset('assets/images/rextra.png', height: 24),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text('Daftar Akun',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                'Buat akun REXTRA kamu untuk mulai\nrencanakan dan wujudkan karier impian 🔥',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'Alamat Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: passC,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  suffixIcon: IconButton(
                    icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => showPass = !showPass),
                  ),
                ),
                obscureText: !showPass,
                validator: _passwordValidator,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: confirmC,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi',
                  suffixIcon: IconButton(
                    icon: Icon(showConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => showConfirm = !showConfirm),
                  ),
                ),
                obscureText: !showConfirm,
                validator: (v) => (v ?? '') != passC.text ? 'Konfirmasi tidak sama' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: phoneC,
                decoration: const InputDecoration(labelText: 'Nomor HP'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Nomor HP wajib diisi';
                  if (!RegExp(r'^0[0-9]{9,13}$').hasMatch(s)) return 'Nomor HP tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agree,
                    onChanged: loading ? null : (v) => setState(() => agree = v ?? false),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Dengan mendaftar, saya menyetujui ',
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'syarat dan ketentuan',
                            style: const TextStyle(color: Color(0xFF2E6BFF), fontWeight: FontWeight.w700),
                            recognizer: TapGestureRecognizer()..onTap = () {/* TODO: open T&C */},
                          ),
                          const TextSpan(text: ' yang berlaku'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Daftar'),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    children: [
                      TextSpan(
                        text: 'Masuk',
                        style: const TextStyle(color: Color(0xFF2E6BFF), fontWeight: FontWeight.w700),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push('/login'), // gunakan push agar back bisa pop
                      ),
                    ],
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
