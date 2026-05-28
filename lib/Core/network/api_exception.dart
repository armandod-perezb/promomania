/// Excepción de bajo nivel del cliente HTTP.
///
/// Lleva el código de estado HTTP y el mensaje de error del servidor.
/// Las capas superiores (datasources) la convierten a excepciones de dominio
/// según sea necesario.
class ApiRequestException implements Exception {
  final int statusCode;
  final String message;

  const ApiRequestException(this.statusCode, this.message);

  @override
  String toString() => 'ApiRequestException($statusCode): $message';
}
