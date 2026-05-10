/// Define los errores específicos del dominio de la aplicación.
///
/// Estos errores se utilizan en las capas de dominio e infraestructura
/// para comunicar problemas específicos de negocio.

abstract class DomainException implements Exception {
  final String message;

  DomainException(this.message);

  @override
  String toString() => message;
}

/// Excepción cuando hay un error de autenticación.
class AuthenticationException extends DomainException {
  AuthenticationException(String message) : super(message);
}

/// Excepción cuando el usuario no existe.
class UserNotFoundException extends DomainException {
  UserNotFoundException(String message) : super(message);
}

/// Excepción cuando una promoción no existe.
class PromotionNotFoundException extends DomainException {
  PromotionNotFoundException(String message) : super(message);
}

/// Excepción cuando hay un error de validación de datos.
class ValidationException extends DomainException {
  ValidationException(String message) : super(message);
}

/// Excepción cuando el usuario no tiene permisos para hacer una operación.
class UnauthorizedException extends DomainException {
  UnauthorizedException(String message) : super(message);
}

/// Excepción para errores de conexión o red.
class NetworkException extends DomainException {
  NetworkException(String message) : super(message);
}

/// Excepción para errores inesperados del servidor.
class ServerException extends DomainException {
  ServerException(String message) : super(message);
}

/// Excepción para errores inesperados generales.
class UnknownException extends DomainException {
  UnknownException(String message) : super(message);
}
