/// Constantes globales de la aplicación.
///
/// Define valores constantes que se usan en toda la app.
class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.promomania.com/v1';
  static const String apiTimeout = '30000'; // milisegundos
  static const int maxRetries = 3;

  // Database
  static const String dbFileName = 'promomania.db';
  static const int dbVersion = 1;

  // Storage
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // Validación
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Estados
  static const String statusActive = 'activo';
  static const String statusInactive = 'inactivo';
  static const String statusPending = 'pendiente';
  static const String statusApproved = 'aprobada';
  static const String statusRejected = 'rechazada';

  // Roles
  static const String roleUser = 'usuario';
  static const String roleAdmin = 'admin';

  // Vigencia de promociones
  static const String promotionTypeByDate = 'por_fecha';
  static const String promotionTypePermanent = 'permanente';

  // Producto
  static const String productConditionNew = 'nuevo';
  static const String productConditionUsed = 'usado';
  static const String productConditionRefurbished = 'reacondicionado';

  // Timeout para operaciones
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheExpiration = Duration(hours: 24);
}
