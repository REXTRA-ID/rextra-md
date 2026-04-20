import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PersonaType { pathfinder, builder, achiever }
enum MembershipTier { basic, pro }
enum KenaliLockState { none, personaLocked, membershipLocked }

enum AssessmentBadgeType { wajib, disarankan, penguat }
enum AssessmentCategory {
  profilKarier,
  gayaKerja,
  kecerdasanMajemuk,
  kepribadian,
  gayaBelajar,
}

enum HistoryTabType { selesai, berlangsung, dibatalkan }

class AssessmentItem {
  final String title;
  final String description;
  final int tokenCost;
  final AssessmentBadgeType badge;
  final AssessmentCategory category;
  final String bannerAsset;

  const AssessmentItem({
    required this.title,
    required this.description,
    required this.tokenCost,
    required this.badge,
    required this.category,
    required this.bannerAsset,
  });
}

class HistoryItem {
  final String title;
  final String summary;
  final DateTime date;
  final int points;
  final int minutes;
  final HistoryTabType tab;
  final List<String> riasecAssets;
  final AssessmentCategory category;

  const HistoryItem({
    required this.title,
    required this.summary,
    required this.date,
    required this.points,
    required this.minutes,
    required this.tab,
    required this.riasecAssets,
    required this.category,
  });
}

@immutable
class KenaliDiriState {
  final PersonaType personaType;
  final MembershipTier membershipTier;
  final int tokenOwned;
  final KenaliLockState lockState;
  final String personaName;
  final List<AssessmentItem> assessments;
  final List<HistoryItem> history;

  const KenaliDiriState({
    required this.personaType,
    required this.membershipTier,
    required this.tokenOwned,
    required this.lockState,
    required this.personaName,
    required this.assessments,
    required this.history,
  });

  KenaliDiriState copyWith({
    PersonaType? personaType,
    MembershipTier? membershipTier,
    int? tokenOwned,
    KenaliLockState? lockState,
    String? personaName,
    List<AssessmentItem>? assessments,
    List<HistoryItem>? history,
  }) {
    return KenaliDiriState(
      personaType: personaType ?? this.personaType,
      membershipTier: membershipTier ?? this.membershipTier,
      tokenOwned: tokenOwned ?? this.tokenOwned,
      lockState: lockState ?? this.lockState,
      personaName: personaName ?? this.personaName,
      assessments: assessments ?? this.assessments,
      history: history ?? this.history,
    );
  }
}

final kenaliDiriProvider =
StateNotifierProvider<KenaliDiriController, KenaliDiriState>((ref) {
  return KenaliDiriController();
});

class KenaliDiriController extends StateNotifier<KenaliDiriState> {
  KenaliDiriController()
      : super(
    KenaliDiriState(
      personaType: PersonaType.pathfinder,
      membershipTier: MembershipTier.pro,
      tokenOwned: 600,
      lockState: KenaliLockState.none,
      personaName: 'Pathfinder',
      assessments: const [
        AssessmentItem(
          title: 'Tes Profil Karier',
          description:
          'Lorem ipsum dulur sit amet Lorem ipsum dulur sit amet Lorem ipsum dolor.',
          tokenCost: 50,
          badge: AssessmentBadgeType.disarankan,
          category: AssessmentCategory.profilKarier,
          bannerAsset: 'assets/images/kenali_diri/Rectangle34624559.png',
        ),
        AssessmentItem(
          title: 'Tes Gaya Kerja',
          description:
          'Lorem ipsum dulur sit amet Lorem ipsum dulur sit amet Lorem ipsum dolor.',
          tokenCost: 50,
          badge: AssessmentBadgeType.penguat,
          category: AssessmentCategory.gayaKerja,
          bannerAsset: 'assets/images/kenali_diri/Frame1000004901.png',
        ),
      ],
      history: [
        HistoryItem(
          title: 'Tes Profil Karier',
          summary: 'Realistic | Conventional | Artistic',
          date: DateTime(2025, 12, 10),
          points: 500,
          minutes: 10,
          tab: HistoryTabType.selesai,
          category: AssessmentCategory.profilKarier,
          riasecAssets: [
            'assets/images/kenali_diri/RIASECBLOCK.png',
            'assets/images/kenali_diri/RIASECBLOCK(1).png',
            'assets/images/kenali_diri/RIASECBLOCK(2).png',
          ],
        ),
        HistoryItem(
          title: 'Tes Profil Karier',
          summary: 'Realistic | Conventional | Artistic',
          date: DateTime(2025, 12, 10),
          points: 500,
          minutes: 10,
          tab: HistoryTabType.selesai,
          category: AssessmentCategory.gayaKerja,
          riasecAssets: [
            'assets/images/kenali_diri/RIASECBLOCK.png',
            'assets/images/kenali_diri/RIASECBLOCK(1).png',
            'assets/images/kenali_diri/RIASECBLOCK(2).png',
          ],
        ),
      ],
    ),
  );

  void setLockState(KenaliLockState value) {
    state = state.copyWith(lockState: value);
  }

  void setPersona(PersonaType type) {
    final personaName = switch (type) {
      PersonaType.pathfinder => 'Pathfinder',
      PersonaType.builder => 'Builder',
      PersonaType.achiever => 'Achiever',
    };
    state = state.copyWith(personaType: type, personaName: personaName);
  }

  bool hasEnoughToken(int needed) => state.tokenOwned >= needed;
}

extension AssessmentBadgeTypeX on AssessmentBadgeType {
  String get label {
    switch (this) {
      case AssessmentBadgeType.wajib:
        return 'WAJIB';
      case AssessmentBadgeType.disarankan:
        return 'DISARANKAN';
      case AssessmentBadgeType.penguat:
        return 'PENGUAT';
    }
  }

  Color get color {
    switch (this) {
      case AssessmentBadgeType.wajib:
        return const Color(0xFFE85050);
      case AssessmentBadgeType.disarankan:
        return const Color(0xFF1450E3);
      case AssessmentBadgeType.penguat:
        return const Color(0xFF1FB9B2);
    }
  }
}