import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_service.dart';
import '../../../core/utils/nav_utils.dart';

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await _auth.login(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      if (!mounted) return;
      context.go('/persona/welcome');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal masuk: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F3F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => popOrGo(context, '/onboarding'),
        ),
        title: Image.asset(
          'assets/images/rextra.png',
          height: 26,
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              const SizedBox(height: 6),

              /// Mascot
              Center(
                child: Image.asset(
                  'assets/images/login.png', // welcome mascot
                  height: 180,
                ),
              ),

              const SizedBox(height: 24),

              /// Title
              const Text(
                'Masuk Akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Hi Sobat Rexi, Senang bertemu lagi!\n'
                    'Yuk, jelajahi REXTRA dengan masuk ke akunmu!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              /// Email
              const Text(
                'Alamat Email',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                decoration: _inputDecoration('Masukkan alamat email anda'),
              ),

              const SizedBox(height: 20),

              /// Password
              const Text(
                'Kata Sandi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: passC,
                obscureText: !showPass,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
                decoration: _inputDecoration('Masukkan kata sandi anda')
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPass
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => showPass = !showPass),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Forgot password
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    text: 'Lupa kata sandi? klik ',
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Lupa Kata Sandi',
                        style: const TextStyle(
                          color: Color(0xFF1E4ED8),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.go('/forgot'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Login button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Atau masuk dengan'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              /// Google button
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: () async {
                    setState(() => loading = true);
                    try {
                      await _auth.loginWithGoogle();
                      if (!mounted) return;
                      context.go('/persona/welcome');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login Google gagal: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => loading = false);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDDE7FF),
                    foregroundColor: const Color(0xFF1E4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Google',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// Register link
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Belum punya akun? klik ',
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Daftar Akun',
                        style: const TextStyle(
                          color: Color(0xFF1E4ED8),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => context.push('/register'),
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