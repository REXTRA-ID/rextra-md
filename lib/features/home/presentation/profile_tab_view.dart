import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_service.dart';

/// Konten tab "Profil" di halaman Home — menampilkan info akun
/// dan satu-satunya jalan resmi untuk keluar dari sesi login.
class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  final _auth = AuthService();
  Map<String, dynamic>? _personalInfo;
  bool _loading = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final res = await _auth.me();
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        _personalInfo = data['personal_info'] as Map<String, dynamic>?;
      }
    } catch (_) {
      // biarkan null, tampilkan seadanya
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await _auth.logout();
    } catch (_) {
      // tetap lanjut keluar walau request logout ke server gagal,
      // token lokal sudah pasti dihapus oleh AuthService.logout().
    } finally {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final fullname = _personalInfo?['username'] as String? ?? '-';
    final email = _personalInfo?['email'] as String? ?? '-';
    final phone = _personalInfo?['phone_number'] as String? ?? '-';
    final role = _personalInfo?['role'] as String? ?? '-';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFFEAF1FF),
          child: Icon(Icons.person, size: 44, color: Color(0xFF1E4ED8)),
        ),
        const SizedBox(height: 16),
        Text(
          fullname,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        _InfoTile(label: 'Nomor HP', value: phone),
        _InfoTile(label: 'Peran', value: role),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _loggingOut ? null : _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _loggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
