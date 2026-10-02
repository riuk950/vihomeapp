/// Utilidad para formatear fechas de solicitudes de forma inteligente y localizada (RF-18.2, RF-18.3, QA 1.2).
class ApplicationDateFormatter {
  static const List<String> _spanishMonths = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  /// Formatea la fecha [dateTime] según su frescura respecto a [now].
  ///
  /// - Mismo día: `"Hoy, HH:mm"`
  /// - Día anterior: `"Ayer, HH:mm"`
  /// - Últimos 7 días: `"Hace X días"`
  /// - Fechas anteriores: `"d MMM yyyy"` (ej. `"14 ago 2026"`)
  static String format(DateTime dateTime, {DateTime? now}) {
    final current = now ?? DateTime.now();

    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final todayOnly = DateTime(current.year, current.month, current.day);

    final differenceInDays = todayOnly.difference(dateOnly).inDays;

    final hourStr = dateTime.hour.toString().padLeft(2, '0');
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');

    if (differenceInDays == 0) {
      return 'Hoy, $hourStr:$minuteStr';
    } else if (differenceInDays == 1) {
      return 'Ayer, $hourStr:$minuteStr';
    } else if (differenceInDays > 1 && differenceInDays <= 7) {
      return 'Hace $differenceInDays días';
    } else {
      final monthName = _spanishMonths[dateTime.month - 1];
      return '${dateTime.day} $monthName ${dateTime.year}';
    }
  }
}
