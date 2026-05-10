import 'package:intl/intl.dart';

/// Formateadores para datos comunes.
///
/// Proporciona funciones para formatear moneda, fechas, números, etc.
class Formatters {
  /// Formatea un número como moneda colombiana (COP).
  ///
  /// Ejemplo: 1000000 -> $1.000.000
  static String formatCurrency(double amount) {
    // Usamos NumberFormat.currency para tener control total sobre el símbolo y decimales
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Formatea una fecha en formato legible.
  ///
  /// Ejemplo: 2024-05-10 -> 10 de mayo de 2024
  static String formatDate(DateTime date) {
    // Usamos DateFormat para cumplir con el formato descrito en el comentario
    return DateFormat("d 'de' MMMM 'de' y", 'es_CO').format(date);
  }

  /// Formatea una fecha con hora.
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Formatea solo la hora.
  ///
  /// Ejemplo: 14:30:45 -> 2:30 PM
  static String formatTime(DateTime dateTime) {
    // El patrón 'h:mm a' genera el formato de 12 horas con AM/PM
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Formatea un número de teléfono colombiano.
  ///
  /// Ejemplo: 3001234567 -> 300 123 4567
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    return phone;
  }

  /// Formatea un porcentaje.
  ///
  /// Ejemplo: 0.15 -> 15%
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  /// Trunca un texto a una longitud específica y agrega "...".
  static String truncateText(String text, int length) {
    if (text.length <= length) {
      return text;
    }
    return '${text.substring(0, length)}...';
  }

  /// Capitaliza la primera letra de una cadena.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
