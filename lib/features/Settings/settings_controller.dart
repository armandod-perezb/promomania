import 'package:app/features/auth/presentation/controllers/auth_controller.dart';

class SettingsController {
  final AuthController authController;

  SettingsController(this.authController);

  Future<void> logout() {
    return authController.logout();
  }
}
