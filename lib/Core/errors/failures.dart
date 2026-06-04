/// Define los tipos de fallos que puede retornar la aplicación.
///
/// Se usa en lugar de lanzar excepciones en las capas de aplicación
/// para un manejo más elegante de errores.

abstract class Failure {
  final String message;

  Failure(this.message);
}

/// Fallo producido durante autenticacion, registro o recuperacion de cuenta.
class AuthenticationFailure extends Failure {
  AuthenticationFailure(String message) : super(message);
}

/// Fallo usado cuando no existe el usuario solicitado.
class UserNotFoundFailure extends Failure {
  UserNotFoundFailure(String message) : super(message);
}

/// Fallo usado cuando no existe la promocion solicitada.
class PromotionNotFoundFailure extends Failure {
  PromotionNotFoundFailure(String message) : super(message);
}

/// Fallo de validacion de datos ingresados o reglas de negocio.
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

/// Fallo usado cuando el usuario no tiene permisos para la accion solicitada.
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure(String message) : super(message);
}

/// Fallo de conectividad, timeout o comunicacion con servicios remotos.
class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

/// Fallo producido por una respuesta inesperada del backend.
class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

/// Fallo de reserva para errores que no encajan en categorias conocidas.
class UnknownFailure extends Failure {
  UnknownFailure(String message) : super(message);
}
