import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/application_date_formatter.dart';

void main() {
  group('ApplicationDateFormatter', () {
    final referenceNow = DateTime(2026, 9, 29, 14, 30);

    test('RF-18.2, QA 1.2: Formats dates from today with "Hoy, HH:mm"', () {
      final todayDate = DateTime(2026, 9, 29, 9, 15);
      final result = ApplicationDateFormatter.format(
        todayDate,
        now: referenceNow,
      );
      expect(result, 'Hoy, 09:15');
    });

    test('RF-18.2, QA 1.2: Formats dates from yesterday with "Ayer, HH:mm"', () {
      final yesterdayDate = DateTime(2026, 9, 28, 18, 45);
      final result = ApplicationDateFormatter.format(
        yesterdayDate,
        now: referenceNow,
      );
      expect(result, 'Ayer, 18:45');
    });

    test('RF-18.2, QA 1.2: Formats dates from the last 7 days with "Hace X días"', () {
      final threeDaysAgo = DateTime(2026, 9, 26, 11, 00);
      final result = ApplicationDateFormatter.format(
        threeDaysAgo,
        now: referenceNow,
      );
      expect(result, 'Hace 3 días');

      final sixDaysAgo = DateTime(2026, 9, 23, 10, 00);
      final resultSix = ApplicationDateFormatter.format(
        sixDaysAgo,
        now: referenceNow,
      );
      expect(resultSix, 'Hace 6 días');
    });

    test('RF-18.2, RF-18.3: Formats older dates with localized "d MMM yyyy"', () {
      final olderDate = DateTime(2026, 8, 14, 10, 00);
      final result = ApplicationDateFormatter.format(
        olderDate,
        now: referenceNow,
      );
      expect(result, '14 ago 2026');

      final pastYear = DateTime(2025, 12, 5, 8, 00);
      final resultPastYear = ApplicationDateFormatter.format(
        pastYear,
        now: referenceNow,
      );
      expect(resultPastYear, '5 dic 2025');
    });

    test('Handles single digit days and hours correctly with zero padding', () {
      final todayEarly = DateTime(2026, 9, 29, 4, 7);
      final result = ApplicationDateFormatter.format(
        todayEarly,
        now: referenceNow,
      );
      expect(result, 'Hoy, 04:07');
    });
  });
}
