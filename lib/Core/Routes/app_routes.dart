/// Nombres de rutas usados por la navegacion declarativa de la aplicacion.
class AppRoutes {
  // ==========================================================================
  // MÓDULO: AUTENTICACIÓN
  // Rutas relacionadas con login, registro y recuperación de contraseña.
  // ==========================================================================

  // Pantalla de inicio de sesión
  static const login = '/login';

  // Registro de nuevos usuarios
  static const register = '/register';

  // Recuperación de contraseña (ingresar correo)
  static const forgotPassword = '/forgot_password';

  // Verificación de código enviado al usuario
  static const verifyCode = '/verify_code';

  // Crear nueva contraseña después de verificación
  static const newPassword = '/new_password';

  // ==========================================================================
  // MÓDULO: ONBOARDING
  // Flujo de introducción a la app (pantallas iniciales tipo tutorial)
  // ==========================================================================

  // 👇 ESTA ES LA LÍNEA QUE NECESITAS AGREGAR
  static const onboarding1 = '/onboarding1';

  // Pantalla inicial onboarding (la puedes dejar si ya la usabas)
  static const onboarding = '/onboarding';

  // Pantallas progresivas del onboarding
  static const onboarding2 = '/onboarding2';
  static const onboarding3 = '/onboarding3';
  static const onboarding4 = '/onboarding4';

  // ==========================================================================
  // MÓDULO: ADMINISTRADOR
  // Panel de control exclusivo para administradores
  // Incluye gestión completa del sistema
  // ==========================================================================

  // Dashboard principal del admin (métricas, resumen)
  static const adminDashboard = '/admin/dashboard';

  // Gestión de usuarios (CRUD usuarios)
  static const manageUsers = '/admin/manage_users';

  // Gestión de promociones (CRUD promociones)
  static const managePromotions = '/admin/manage_promotions';

  // Gestión de comercios (CRUD supermercados)
  static const manageStores = '/admin/manage_stores';

  // Gestión de notificaciones generales
  static const manageNotifications = '/admin/manage_notifications';

  // Submódulos de notificaciones (segmentación funcional)
  static const adminNotiActivity =
      '/admin/noti/activity'; // actividad del sistema
  static const adminNotiReport = '/admin/noti/report'; // reportes generados
  static const adminNotiAlert = '/admin/noti/alert'; // alertas críticas
  static const adminNotiExport = '/admin/noti/export'; // exportaciones

  // ==========================================================================
  // 👤 MÓDULO: USUARIO
  // Rutas del usuario final dentro de la app
  // ==========================================================================

  // Pantalla principal del usuario
  static const userHome = '/user/home';

  // Perfil del usuario
  static const userProfile = '/user/profile';

  // Lista de favoritos
  static const userFavorites = '/user/favorites';

  // Edición de perfil
  static const userEdit = '/user/edit';

  // Configuración de usuario
  static const userConfig = '/user/config';

  // Exploración de promociones
  static const explore = '/user/explore';

  // Detalle de una promoción específica
  static const promotionDetails = '/user/promotion_details';

  // ==========================================================================
  // MÓDULO: CREACIÓN DE PROMOCIONES
  // Flujo paso a paso (multi-step form)
  // ==========================================================================

  // Paso 1
  static const addPromotions = '/promotions/add';

  // Paso 2
  static const addPromotions2 = '/promotions/add2';

  // Paso 3
  static const addPromotions3 = '/promotions/add3';

  // Paso 4
  static const addPromotions4 = '/promotions/add4';

  // Paso 5
  static const addPromotions5 = '/promotions/add5';

  // ==========================================================================
  // MÓDULO: CONFIGURACIONES
  // Información legal y ayuda al usuario
  // ==========================================================================

  // Términos y condiciones del servicio
  static const termsService = '/settings/terms_service';

  // Política de privacidad
  static const privacyPolicy = '/settings/privacy_policy';

  // Información sobre la empresa/app
  static const aboutUs = '/settings/about_us';

  // Centro de ayuda / soporte
  static const helpCenter = '/settings/help_center';
}
