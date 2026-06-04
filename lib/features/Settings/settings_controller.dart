import 'package:app/features/auth/presentation/controllers/auth_controller.dart';

/// Controlador de configuracion; coordina casos de uso y expone operaciones para la capa de presentacion.
class SettingsController {
  final AuthController authController;

  SettingsController(this.authController);

  Future<void> logout() {
    return authController.logout();
  }
}
