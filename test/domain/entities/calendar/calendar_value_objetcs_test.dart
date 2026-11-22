import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/error/calendar_domain_exception.dart';

void main() {
  group('Calendar Value Objects Invariants', () {
    group('WorldId', () {
      test('should initialize correctly with valid format', () {
        const validId = 'wrld_12345-abcde';
        final worldId = WorldId(validId);
        expect(worldId.value, validId);
      });

      test('should throw CalendarDomainException when format does not start with wrld_', () {
        expect(
          () => WorldId('invalid_world_id'),
          throwsA(isA<CalendarDomainException>().having(
            (e) => e.error,
            'error',
            isA<InvalidWorldIdError>(),
          )),
        );
      });
    });

    group('TimeOfDayValue', () {
      test('should create valid instance and format to 24h string correctly', () {
        final time = TimeOfDayValue(hour: 9, minute: 5);
        expect(time.formatted, '09:05');
        expect(time.totalMinutes, 9 * 60 + 5);
      });

      test('should throw CalendarDomainException on out of bounds time creation', () {
        expect(() => TimeOfDayValue(hour: 24, minute: 0), throwsA(isA<CalendarDomainException>()));
        expect(() => TimeOfDayValue(hour: 12, minute: 60), throwsA(isA<CalendarDomainException>()));
        expect(() => TimeOfDayValue(hour: -1, minute: 0), throwsA(isA<CalendarDomainException>()));
      });

      test('should parse valid string and compute arithmetic accurately', () {
        final parsed = TimeOfDayValue.parse('20:30');
        expect(parsed.hour, 20);
        expect(parsed.minute, 30);

        final added = parsed.addMinutes(45);
        expect(added.formatted, '21:15');

        final overflowAdded = parsed.addMinutes(4 * 60);
        expect(overflowAdded.formatted, '00:30');
      });

      test('minutesDifference should calculate forward duration including overnight intervals', () {
        final start = TimeOfDayValue(hour: 22, minute: 0);
        final end = TimeOfDayValue(hour: 2, minute: 0);
        expect(start.minutesDifference(end), 240);
      });
    });

    group('TimezoneSchedule', () {
      test('should throw if duration is zero or negative', () {
        expect(
          () => TimezoneSchedule(
            startTime: TimeOfDayValue(hour: 12, minute: 0),
            durationMinutes: 0,
            timezoneIana: 'UTC',
          ),
          throwsA(isA<CalendarDomainException>().having(
            (e) => e.error,
            'error',
            isA<InvalidDurationError>(),
          )),
        );

        expect(
          () => TimezoneSchedule(
            startTime: TimeOfDayValue(hour: 12, minute: 0),
            durationMinutes: -30,
            timezoneIana: 'UTC',
          ),
          throwsA(isA<CalendarDomainException>().having(
            (e) => e.error,
            'error',
            isA<InvalidDurationError>(),
          )),
        );
      });

      test('should throw if timezone is empty', () {
        expect(
          () => TimezoneSchedule(
            startTime: TimeOfDayValue(hour: 12, minute: 0),
            durationMinutes: 60,
            timezoneIana: '  ',
          ),
          throwsA(isA<CalendarDomainException>().having(
            (e) => e.error,
            'error',
            isA<InvalidTimezoneError>(),
          )),
        );
      });
    });

    group('IncrementalConfig', () {
      test('next() should increment currentValue by stepValue if enabled', () {
        final config = IncrementalConfig(isEnabled: true, startValue: 1, stepValue: 2, currentValue: 3);
        final nextConfig = config.next();

        expect(nextConfig.currentValue, 5);
        expect(nextConfig.isEnabled, true);
      });

      test('next() should return identical instance if not enabled', () {
        final config = IncrementalConfig(isEnabled: false, startValue: 1, stepValue: 1, currentValue: 1);
        final nextConfig = config.next();

        expect(identical(config, nextConfig), isTrue);
        expect(config, equals(nextConfig));
      });
    });
  });
}