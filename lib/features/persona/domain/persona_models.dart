enum PersonaType { pathfinder, builder, achiever }

/// Chip akses fitur di kartu misi (Figma: "Akses Token" / "Akses Terbatas").
enum MissionAccess { open, token, limited }

/// Satu misi persona. Daftar & teksnya mengikuti Figma terbaru
/// (Task Flow 6 – Hasil Persona Rextra), status selesainya dibaca dari
/// backend berdasarkan [key] (`GET /persona` -> `missions[].key`).
class MissionSpec {
  final String key;
  final String title;
  final String imageAsset;
  final bool isMandatory;
  final MissionAccess access;
  final String description;

  /// Rute fitur tujuan. Null = fitur belum tersedia di app.
  final String? route;
  final int point;

  const MissionSpec({
    required this.key,
    required this.title,
    required this.imageAsset,
    required this.isMandatory,
    required this.description,
    this.access = MissionAccess.open,
    this.route,
    this.point = 100,
  });
}

// Key backend (rextra-backend persona_service.go staticMissions).
// `profession_fit_checked` belum ada di backend -> selalu "Belum Selesai".
const _kJejakStudi = 'education_saved';
const _kKenaliDiri = 'career_recommendation_tried';
const _kJelajahProfesi = 'career_dictionary_accessed';
const _kRencanaKarier = 'career_plan_created';
const _kUjiKecocokan = 'profession_fit_checked';

const _titleJejakStudi =
    'Simpan Data Pendidikan Terkini & Terdahulu Dengan Jejak Studi';
const _titleKenaliDiri =
    'Menetapkan Tujuan Karier Dengan Tes Profil Karier di Fitur Kenali Diri';
const _titleJelajahProfesi =
    'Jelajahi Profesi Digital Berprospek Tinggi di Jelajah Profesi';
const _titleUjiKecocokan =
    'Uji kecocokan profesi pilihanmu dengan profil karier di Uji Kecocokan Profesi';
const _titleRencanaKarier =
    'Susun Rencana Karier Awal Agar Langkahmu Lebih Terarah di Rencana Karier';

const _imgJejakStudi = 'assets/images/mission_simpan_pendidikan.png';
const _imgKenaliDiri = 'assets/images/mission_tujuan_karir.png';
const _imgJelajahProfesi = 'assets/images/mission_jelajahi_profesi.png';
// Figma masih placeholder untuk dua ikon ini.
const _imgUjiKecocokan = 'assets/images/rekomendasi.png';
const _imgRencanaKarier = 'assets/images/rencana.png';

const _descRencanaWajib =
    'Misi wajib dikerjakan karena fitur Rencana Karier membantu kamu merencanakan progres tiap semester dengan langkah yang jelas, sehingga kamu lebih siap mewujudkan tujuan karier';

const _pathfinderMissions = <MissionSpec>[
  MissionSpec(
    key: _kJejakStudi,
    title: _titleJejakStudi,
    imageAsset: _imgJejakStudi,
    route: '/jejak-studi',
    isMandatory: true,
    description:
        'Misi wajib karena Jejak Studi menyimpan riwayat pendidikanmu, agar sistem bisa membantu persiapan karier selama kuliah dengan lebih tepat',
  ),
  MissionSpec(
    key: _kKenaliDiri,
    title: _titleKenaliDiri,
    imageAsset: _imgKenaliDiri,
    isMandatory: true,
    access: MissionAccess.token,
    route: '/kenali',
    description:
        'Misi wajib karena tes profil karier memberi rekomendasi profesi awal agar tujuan karier lebih jelas dan langkah selanjutnya lebih terarah',
  ),
  MissionSpec(
    key: _kJelajahProfesi,
    title: _titleJelajahProfesi,
    imageAsset: _imgJelajahProfesi,
    isMandatory: false,
    access: MissionAccess.limited,
    description:
        'Misi dianjurkan karena Jelajah Profesi di Kamus Karier membantu kamu mengeksplor profesi digital dan prospeknya saat kamu ingin melihat opsi selain rekomendasi tes profil karier',
  ),
  MissionSpec(
    key: _kRencanaKarier,
    title: _titleRencanaKarier,
    imageAsset: _imgRencanaKarier,
    isMandatory: true,
    access: MissionAccess.limited,
    description: _descRencanaWajib,
  ),
];

const _builderMissions = <MissionSpec>[
  MissionSpec(
    key: _kJejakStudi,
    title: _titleJejakStudi,
    imageAsset: _imgJejakStudi,
    route: '/jejak-studi',
    isMandatory: true,
    description:
        'Misi wajib karena Jejak Studi menyimpan riwayat pendidikanmu, agar sistem bisa membantu persiapan karier selama kuliah dengan lebih tepat',
  ),
  MissionSpec(
    key: _kKenaliDiri,
    title: _titleKenaliDiri,
    imageAsset: _imgKenaliDiri,
    isMandatory: false,
    access: MissionAccess.token,
    route: '/kenali',
    description:
        'Misi dianjurkan karena tes profil karier membantu kamu memahami profil karier dan memastikan arah profesi yang kamu pilih sudah lebih meyakinkan',
  ),
  MissionSpec(
    key: _kJelajahProfesi,
    title: _titleJelajahProfesi,
    imageAsset: _imgJelajahProfesi,
    isMandatory: false,
    access: MissionAccess.limited,
    description:
        'Misi dianjurkan karena Jelajah Profesi di Kamus Karier membantu kamu mengeksplor profesi digital dan prospeknya saat kamu ingin melihat opsi selain profesi yang sudah kamu incar',
  ),
  MissionSpec(
    key: _kUjiKecocokan,
    title: _titleUjiKecocokan,
    imageAsset: _imgUjiKecocokan,
    isMandatory: false,
    access: MissionAccess.limited,
    description:
        'Misi dianjurkan karena kamu bisa mencocokkan profil kariermu dengan profil profesi, sehingga kamu tahu tingkat kecocokan profesi yang kamu inginkan',
  ),
  MissionSpec(
    key: _kRencanaKarier,
    title: _titleRencanaKarier,
    imageAsset: _imgRencanaKarier,
    isMandatory: true,
    access: MissionAccess.limited,
    description: _descRencanaWajib,
  ),
];

const _achieverMissions = <MissionSpec>[
  MissionSpec(
    key: _kJejakStudi,
    title: _titleJejakStudi,
    imageAsset: _imgJejakStudi,
    route: '/jejak-studi',
    isMandatory: true,
    description:
        'Misi wajib karena Jejak Studi menyimpan riwayat pendidikanmu, agar sistem bisa membantu persiapan karier dengan lebih tepat',
  ),
  MissionSpec(
    key: _kKenaliDiri,
    title: _titleKenaliDiri,
    imageAsset: _imgKenaliDiri,
    isMandatory: false,
    access: MissionAccess.token,
    route: '/kenali',
    description:
        'Misi dianjurkan karena tes profil karier membantu kamu memahami profil karier dan memastikan profesi yang kamu incar sudah sesuai',
  ),
  MissionSpec(
    key: _kJelajahProfesi,
    title: _titleJelajahProfesi,
    imageAsset: _imgJelajahProfesi,
    isMandatory: false,
    access: MissionAccess.limited,
    description:
        'Misi dianjurkan karena Jelajah Profesi di Kamus Karier membantu kamu melihat opsi profesi lain dan prospeknya saat kamu ingin memperluas pilihan',
  ),
  MissionSpec(
    key: _kUjiKecocokan,
    title: _titleUjiKecocokan,
    imageAsset: _imgUjiKecocokan,
    isMandatory: false,
    access: MissionAccess.limited,
    description:
        'Misi dianjurkan karena kamu bisa mengecek tingkat kecocokan antara profil kariermu dan profesi yang kamu incar sebelum lanjut ke tahap seleksi',
  ),
  MissionSpec(
    key: _kRencanaKarier,
    title: _titleRencanaKarier,
    imageAsset: _imgRencanaKarier,
    isMandatory: false,
    access: MissionAccess.limited,
    description:
        'Misi dianjurkan karena Achiever umumnya sudah lulus, tetapi Rencana Karier tetap bisa dipakai untuk mengecek apakah portofoliomu sudah relevan dan cukup kuat terhadap tujuan karier',
  ),
];

List<MissionSpec> missionsFor(PersonaType type) {
  switch (type) {
    case PersonaType.pathfinder:
      return _pathfinderMissions;
    case PersonaType.builder:
      return _builderMissions;
    case PersonaType.achiever:
      return _achieverMissions;
  }
}

/// Jumlah misi yang sudah selesai dari daftar misi persona [type].
int completedMissionCount(PersonaType type, Map<String, bool> status) =>
    missionsFor(type).where((m) => status[m.key] == true).length;
