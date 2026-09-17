import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_service.dart';
import '../../../core/utils/nav_utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  bool agree = false;
  bool showPass = false;
  bool showConfirm = false;
  bool loading = false;

  final _auth = AuthService();

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passC.dispose();
    confirmC.dispose();
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
    return null;
  }

  String? _phoneValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Nomor HP wajib diisi';
    final ok = RegExp(r'^[0-9+()\-\s]{8,}$').hasMatch(s);
    if (!ok) return 'Format nomor HP tidak valid';
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
        phone: phoneC.text.trim(),
      );

      final email = Uri.encodeQueryComponent(emailC.text.trim());
      if (!mounted) return;
      context.go('/verify?mode=sent&email=$email');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    const borderRadius = BorderRadius.all(Radius.circular(14));
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9AA4B2)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      enabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Color(0xFFD7DDE5), width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Color(0xFF2E6BFF), width: 1.6),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Color(0xFFE74C3C), width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Color(0xFFE74C3C), width: 1.2),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2A37),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2E6BFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => popOrGo(context, '/onboarding'),
        ),
        title: Image.asset('assets/images/rextra.png', height: 24),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const SizedBox(height: 6),
              // Ilustrasi baru
              Center(
                child: Image.asset(
                  'assets/images/RegistrasiAkun(1).png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Daftar Akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yuk Buat Akun untuk Mulai Persiapan Karier\nDigital Bersama REXTRA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              _fieldLabel('Nama Lengkap'),
              TextFormField(
                controller: nameC,
                enabled: !loading,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Masukkan nama lengkap anda'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 18),

              _fieldLabel('Alamat Email'),
              TextFormField(
                controller: emailC,
                enabled: !loading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Masukkan email anda'),
                validator: _emailValidator,
              ),
              const SizedBox(height: 18),

              _fieldLabel('Nomor HP'),
              TextFormField(
                controller: phoneC,
                enabled: !loading,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Masukkan nomor HP anda'),
                validator: _phoneValidator,
              ),
              const SizedBox(height: 18),

              _fieldLabel('Kata Sandi'),
              TextFormField(
                controller: passC,
                enabled: !loading,
                obscureText: !showPass,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  'Masukkan kata sandi anda',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPass ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF111827),
                    ),
                    onPressed: loading ? null : () => setState(() => showPass = !showPass),
                  ),
                ),
                validator: _passwordValidator,
              ),
              const SizedBox(height: 18),

              _fieldLabel('Konfirmasi Kata Sandi'),
              TextFormField(
                controller: confirmC,
                enabled: !loading,
                obscureText: !showConfirm,
                decoration: _inputDecoration(
                  'Masukkan ulang kata sandi anda',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirm ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF111827),
                    ),
                    onPressed: loading ? null : () => setState(() => showConfirm = !showConfirm),
                  ),
                ),
                validator: (v) => (v ?? '') != passC.text ? 'Konfirmasi tidak sama' : null,
              ),
              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Checkbox(
                      value: agree,
                      onChanged: loading ? null : (v) => setState(() => agree = v ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      activeColor: primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Dengan mendaftar, saya menyetujui ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'syarat dan\nketentuan',
                            style: const TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w800,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              // TODO: buka halaman T&C
                            },
                          ),
                          const TextSpan(text: ' yang berlaku'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (loading || !agree) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    disabledBackgroundColor: primaryBlue.withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Daftar Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Divider "Atau masuk dengan"
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFD7DDE5), thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Atau masuk dengan',
                      style: TextStyle(
                        color: Color(0xFF9AA4B2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFD7DDE5), thickness: 1)),
                ],
              ),
              const SizedBox(height: 14),

              // Tombol Google (UI-only, hook logic belakangan)
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: loading ? null : () {
                    // TODO: implement Google Sign-In
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFDCE8FF),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),

                  label: const Text(
                    'Google',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Masuk',
                        style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.w900),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/login'),
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