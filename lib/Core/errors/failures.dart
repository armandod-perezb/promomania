/// Define los tipos de fallos que puede retornar la aplicación.
///
/// Se usa en lugar de lanzar excepciones en las capas de aplicación
/// para un manejo más elegante de errores.

abstract class Failure {
  final String message;

  Failure(this.message);
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure(String message) : super(message);
}

class UserNotFoundFailure extends Failure {
  UserNotFoundFailure(String message) : super(message);
}

class PromotionNotFoundFailure extends Failure {
  PromotionNotFoundFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  UnknownFailure(String message) : super(message);
}
