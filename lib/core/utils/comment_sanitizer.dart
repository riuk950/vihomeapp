/// Utilidad para normalizar, sanitizar y validar comentarios de calificaciones
class CommentSanitizer {
  static const int maxCommentLength = 500;

  /// Sanitiza un comentario:
  /// - Normaliza retornos de carro `\r\n` a `\n`.
  /// - Colapsa secuencias de 3 o más saltos de línea consecutivos a máximo 2 (`\n\n`).
  /// - Recorta espacios exteriores (`trim()`).
  /// - Si queda vacío tras el recorte, retorna `null`.
  /// - Trunca de forma defensiva a un máximo de 500 caracteres.
  static String? sanitize(String? comment) {
    if (comment == null) return null;

    // Normalizar retornos de carro Windows/Mac clásicos
    String text = comment.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Recortar espacios y saltos externos
    text = text.trim();
    if (text.isEmpty) return null;

    // Colapsar saltos excesivos (3 o más) a exactamente 2 saltos
    final regexConsecutiveNewlines = RegExp(r'\n{3,}');
    text = text.replaceAll(regexConsecutiveNewlines, '\n\n');

    // Truncar a máximo 500 caracteres
    if (text.length > maxCommentLength) {
      text = text.substring(0, maxCommentLength);
    }

    return text;
  }

  /// Verifica si la longitud del comentario está dentro del límite permitido (<= 500).
  static bool isValidLength(String? comment) {
    if (comment == null) return true;
    return comment.length <= maxCommentLength;
  }
}
