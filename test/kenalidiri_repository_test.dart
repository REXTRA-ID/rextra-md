import 'package:flutter_test/flutter_test.dart';
import 'package:rextra_app/features/kenalidiri/data/kenalidiri_repository.dart';

void main() {
  group('KenaliDiriRepository API contract', () {
    test('prefers canonical assessment path but keeps legacy compatibility fallback', () {
      expect(
        KenaliDiriRepository.resolveAssessmentPath('validate_hash'),
        '/assessment/validate_hash',
      );
      expect(
        KenaliDiriRepository.resolveLegacyAssessmentPath('validate_hash'),
        '/assesment/validate_hash',
      );
    });

    test('validates successful backend response payloads', () {
      expect(
        KenaliDiriRepository.isSuccessfulAssessmentResponse({
          'success': true,
          'data': {'profile': 'RIA'},
        }),
        isTrue,
      );

      expect(
        KenaliDiriRepository.isSuccessfulAssessmentResponse({
          'success': false,
          'message': 'Validation failed',
        }),
        isFalse,
      );

      expect(
        KenaliDiriRepository.isSuccessfulAssessmentResponse({}),
        isFalse,
      );
    });
  });
}
