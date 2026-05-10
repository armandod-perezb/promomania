/// Rutas de navegación de la aplicación.
///
/// Define todas las rutas disponibles en la app de manera centralizada.
/// Facilita cambios globales y evita strings mágicos.
class AppRoutes {
  // Autenticación
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String newPassword = '/new-password';

  // Onboarding
  static const String onboarding = '/onboarding';

  // Usuario
  static const String userHome = '/user/home';
  static const String userExplore = '/user/explore';
  static const String userFavorites = '/user/favorites';
  static const String userProfile = '/user/profile';
  static const String userProfileEdit = '/user/profile/edit';
  static const String userPromoDetail = '/user/promo/detail';
  static const String userConfig = '/user/config';

  // Promotions
  static const String addPromo = '/promo/add';
  static const String addPromoStep1 = '/promo/add/1';
  static const String addPromoStep2 = '/promo/add/2';
  static const String addPromoStep3 = '/promo/add/3';
  static const String addPromoStep4 = '/promo/add/4';
  static const String addPromoStep5 = '/promo/add/5';
  static const String promoDetail = '/promo/detail';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPromos = '/admin/promos';
  static const String adminUsers = '/admin/users';
  static const String adminStores = '/admin/stores';
  static const String adminNotifications = '/admin/notifications';
  static const String adminReports = '/admin/reports';

  // Settings
  static const String settings = '/settings';
  static const String privacyPolicy = '/settings/privacy';
  static const String termsOfService = '/settings/terms';
  static const String helpCenter = '/settings/help';
  static const String about = '/settings/about';
}
