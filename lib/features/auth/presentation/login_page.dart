import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool showPass = false;
  bool loading = false;

  final _auth = AuthService();

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
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
    if ((v ?? '').isEmpty) return 'Kata sandi wajib diisi';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await _auth.login(email: emailC.text.trim(), password: passC.text);
      if (!mounted) return;
      context.go('/home'); // next flow: replace stack
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal masuk: $msg')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak pakai leading manual → biarkan implyLeading.
      appBar: AppBar(
        automaticallyImplyLeading: false, // matikan panah otomatis
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text('Masuk Akun', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                'Masuk untuk melanjutkan perjalanan kariermu 🚀',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              Text('Alamat Email', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailC,
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Masukkan alamat email anda'),
              ),
              const SizedBox(height: 14),

              Text('Kata Sandi', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: passC,
                validator: _passwordValidator,
                obscureText: !showPass,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi anda',
                  suffixIcon: IconButton(
                    icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: ()=>setState(()=>showPass=!showPass),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/forgot'),
                  child: const Text('Lupa kata sandi?'),
                ),
              ),
              const SizedBox(height: 4),

              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Masuk Aplikasi'),
              ),
              const SizedBox(height: 16),

              Row(children: const [
                Expanded(child: Divider(color: Color(0xFFE6EAF3))),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('atau')),
                Expanded(child: Divider(color: Color(0xFFE6EAF3))),
              ]),
              const SizedBox(height: 12),

              FilledButton(
                onPressed: loading ? null : () {/* TODO: Google sign-in */},
                child: const Text('Masuk dengan Google'),
              ),

              const SizedBox(height: 18),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Belum punya akun? ',
                    children: [
                      TextSpan(
                        text: 'Daftar',
                        style: const TextStyle(color: Color(0xFF2E6BFF), fontWeight: FontWeight.w700),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push('/register'), // pakai push biar back bisa pop
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
