import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_service.dart';
import '../../persona/data/persona_repository.dart';
import '../../persona/domain/persona_models.dart';

/// Konten tab "Profil" di halaman Home — menampilkan info akun
/// dan satu-satunya jalan resmi untuk keluar dari sesi login.
class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  final _auth = AuthService();
  final _personaRepo = PersonaRepository();
  Map<String, dynamic>? _personalInfo;
  PersonaStatus? _personaStatus;
  bool _loading = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
    _loadPersona();
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

  Future<void> _loadPersona() async {
    try {
      final status = await _personaRepo.getPersona();
      if (mounted) setState(() => _personaStatus = status);
    } catch (_) {
      // biarkan null, kartu pengingat misi cukup disembunyikan
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
        if (_personaStatus != null && !_personaStatus!.isComplete) ...[
          const SizedBox(height: 24),
          _MissionReminderCard(status: _personaStatus!),
        ],
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

/// Kartu pengingat misi wajib persona yang belum diselesaikan, ditampilkan
/// di halaman Profil selama masih ada misi yang tersisa.
class _MissionReminderCard extends StatelessWidget {
  final PersonaStatus status;
  const _MissionReminderCard({required this.status});

  String get _personaLabel {
    switch (status.type) {
      case PersonaType.pathfinder:
        return 'Pathfinder';
      case PersonaType.builder:
        return 'Builder';
      case PersonaType.achiever:
        return 'Achiever';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = status.totalMissions == 0
        ? 0.0
        : status.completedMissions / status.totalMissions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDD9FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Color(0xFF1E4ED8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Misi Wajib Persona $_personaLabel',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${status.completedMissions} dari ${status.totalMissions} misi wajib terselesaikan',
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFCEF3FB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF1E4ED8)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/persona/result'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4ED8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lanjutkan Misi',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
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
