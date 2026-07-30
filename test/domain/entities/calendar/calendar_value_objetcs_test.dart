import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/error/calendar_domain_exception.dart';

void main() {
  group('Calendar Value Objects Invariants', () {
    test('WorldId should initialize correctly with valid format', () {
      const validId = 'wrld_12345-abcde';
      final worldId = WorldId(validId);

      expect(worldId.value, validId);
    });

    test('WorldId should throw CalendarDomainException if format is invalid', () {
      const invalidId = 'invalid_world_id';

      expect(
        () => WorldId(invalidId),
        throwsA(isA<CalendarDomainException>().having(
          (e) => e.error,
          'error',
          isA<InvalidWorldIdError>()
        )),
      );
    });

    test('TimezoneSchedule should throw if duration is zero or negative', () {
      expect(
        () => TimezoneSchedule(startTimeOfDay: '12:00', durationMinutes: 0, timezoneIana: 'UTC'),
        throwsA(isA<CalendarDomainException>().having((e) => e.error, 'error', isA<InvalidDurationError>())),
      );

      expect(
        () => TimezoneSchedule(startTimeOfDay: '12:00', durationMinutes: -30, timezoneIana: 'UTC'),
        throwsA(isA<CalendarDomainException>().having((e) => e.error, 'error', isA<InvalidDurationError>())),
      );
    });

    test('TimezoneSchedule should throw if timezone is empty', () {
      expect(
        () => TimezoneSchedule(startTimeOfDay: '12:00', durationMinutes: 60, timezoneIana: '  '),
        throwsA(isA<CalendarDomainException>().having((e) => e.error, 'error', isA<InvalidTimezoneError>())),
      );
    });

    test('IncrementalConfig next() should increment currentValue by stepValue if enabled', () {
      final config = IncrementalConfig(isEnabled: true, startValue: 1, stepValue: 2, currentValue: 3);
      final nextConfig = config.next();

      expect(nextConfig.currentValue, 5);
      expect(nextConfig.isEnabled, true);
    });

    test('IncrementalConfig next() should return identical instance if not enabled', () {
      final config = IncrementalConfig(isEnabled: false, startValue: 1, stepValue: 1, currentValue: 1);
      final nextConfig = config.next();

      expect(identical(config, nextConfig), isTrue);
      expect(config, equals(nextConfig));
    });
  });
}