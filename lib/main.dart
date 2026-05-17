import 'package:flutter/material.dart';
import 'Core/Routes/app_routes.dart';
import 'features/auth/presentation/pages/Authentication/login_screen.dart';
import 'features/auth/presentation/pages/Authentication/register_screen.dart';
import 'features/auth/presentation/pages/Authentication/forgot_password_screen.dart';
import 'features/auth/presentation/pages/Authentication/verify_code_screen.dart';
import 'features/auth/presentation/pages/Authentication/new_password_screen.dart';
import 'features/users/presentation/pages/User/user_home_screen.dart';
import 'features/users/presentation/pages/User/user_profile_screen.dart';
import 'features/users/presentation/pages/User/user_favorites_screen.dart';
import 'features/users/presentation/pages/User/user_profile_edit_screen.dart';
import 'features/users/presentation/pages/User/user_config_screen.dart';
import 'features/users/presentation/pages/User/user_explore_screen.dart';
import 'features/users/presentation/pages/User/user_promo_detail_screen.dart';
import 'features/Settings/app_about_screen.dart';
import 'features/Settings/user_terms_service_screen.dart';
import 'features/Settings/help_center_screen.dart';
import 'features/Settings/privacy_policy_screen.dart';
import 'features/promotions/presentation/pages/Promotions/add_promo1_screen.dart';
import 'features/promotions/presentation/pages/Promotions/add_promo2_screen.dart';
import 'features/promotions/presentation/pages/Promotions/add_promo3_screen.dart';
import 'features/promotions/presentation/pages/Promotions/add_promo4_screen.dart';
import 'features/promotions/presentation/pages/Promotions/add_promo5_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_dashboard_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_usuarios_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_promos_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_store_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_noti_activity_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_noti_report_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_noti_alert_screen.dart';
import 'features/users/presentation/pages/Administrator/admin_noti_exportar_screen.dart';
import 'Core/di/app_scope.dart';

// 👇 IMPORTA TU ONBOARDING (agregado)
import 'features/Onboarding/onboarding1_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppScope.bootstrap();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,

      // 👇 CAMBIO PRINCIPAL AQUÍ
      initialRoute: AppRoutes.onboarding1,

      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.verifyCode) {
          final email = settings.arguments is String
              ? settings.arguments as String
              : '';
          return MaterialPageRoute(
            builder: (context) =>
                VerifyCodeScreen(
                  email: email,
                  authController: AppScope.authController,
                ),
            settings: settings,
          );
        }
        if (settings.name == AppRoutes.newPassword) {
          final email = settings.arguments is String
              ? settings.arguments as String
              : null;
          return MaterialPageRoute(
            builder: (context) => NewPasswordScreen(
              email: email,
              authController: AppScope.authController,
            ),
            settings: settings,
          );
        }
        return null;
      },

      routes: {
        // 👇 NUEVA RUTA AGREGADA
        AppRoutes.onboarding1: (context) => const SplashScreen(),

        AppRoutes.login: (context) =>
            LoginScreen(authController: AppScope.authController),
        AppRoutes.register: (context) =>
            RegisterScreen(authController: AppScope.authController),
        AppRoutes.forgotPassword: (context) =>
            ForgotPasswordScreen(authController: AppScope.authController),
        AppRoutes.userHome: (context) => const HomeMapScreen(),
        AppRoutes.userProfile: (context) => const UserProfileScreen(),
        AppRoutes.userFavorites: (context) => const MisFavoritosScreen(),
        AppRoutes.userEdit: (context) => const EditProfileScreen(),
        AppRoutes.userConfig: (context) => const SettingsScreen(),
        AppRoutes.explore: (context) => const ExploreScreen(),
        AppRoutes.promotionDetails: (context) => const PromoDetailScreen(),
        AppRoutes.termsService: (context) => const TermsOfServiceScreen(),
        AppRoutes.privacyPolicy: (context) => const PrivacyPolicyScreen(),
        AppRoutes.aboutUs: (context) => const AboutScreen(),
        AppRoutes.helpCenter: (context) => const HelpCenterScreen(),
        AppRoutes.addPromotions: (context) => const AddPromotion1Screen(),
        AppRoutes.addPromotions2: (context) => const AddPromotion2Screen(),
        AppRoutes.addPromotions3: (context) => const AddPromotion3Screen(),
        AppRoutes.addPromotions4: (context) => const AddPromotion4Screen(),
        AppRoutes.addPromotions5: (context) => const AddPromotion5Screen(),
        AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
        AppRoutes.manageUsers: (context) => const ManageUsersScreen(),
        AppRoutes.managePromotions: (context) => const ManagePromotionsScreen(),
        AppRoutes.manageStores: (context) => const ManageStoresScreen(),
        AppRoutes.manageNotifications: (context) => const AdminAuditScreen(),
        AppRoutes.adminNotiActivity: (context) => const AdminAuditScreen(),
        AppRoutes.adminNotiReport: (context) => const AdminNotiReportScreen(),
        AppRoutes.adminNotiAlert: (context) => const AdminNotiAlertScreen(),
        AppRoutes.adminNotiExport: (context) => const AdminNotiExportScreen(),
      },
    );
  }
}
