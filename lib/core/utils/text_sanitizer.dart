/// Utilidad para sanitizar textos, evitar distorsiones visuales y truncar contenido (RF-18.4, CL-15, QA 1.15).
class TextSanitizer {
  /// Colapsa saltos de línea (`\n`, `\r`) y tabulaciones en un solo espacio,
  /// normaliza espacios en blanco repetitivos y recorta los extremos.
  static String cleanSingleLine(String? text) {
    if (text == null) return '';
    final withoutNewlines = text.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    final normalized = withoutNewlines.replaceAll(RegExp(r'\s{2,}'), ' ');
    return normalized.trim();
  }

  /// Trunca el [text] a una longitud máxima de [maxLength] y le añade [suffix].
  /// Sanitiza previamente el texto a una sola línea.
  static String truncate(
    String? text, {
    int maxLength = 50,
    String suffix = '...',
  }) {
    final clean = cleanSingleLine(text);
    if (clean.length <= maxLength) {
      return clean;
    }
    return '${clean.substring(0, maxLength)}$suffix';
  }

  /// Limpia un número telefónico removiendo caracteres no numéricos
  /// excepto un signo `+` al inicio si está presente.
  static String sanitizePhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final trimmed = phone.trim();
    final hasLeadingPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    return hasLeadingPlus ? '+$digitsOnly' : digitsOnly;
  }
}
