import 'package:flutter/material.dart';
import 'Core/Routes/app_routes.dart';
import 'Authentication/login_screen.dart';
import 'Authentication/register_screen.dart';
import 'Authentication/forgot_password_screen.dart';
import 'Authentication/verify_code_screen.dart';
import 'Authentication/new_password_screen.dart';
import 'User/user_home_screen.dart';
import 'User/user_profile_screen.dart';
import 'User/user_favorites_screen.dart';
import 'User/user_profile_edit_screen.dart';
import 'User/user_config_screen.dart';
import 'User/user_explore_screen.dart';
import 'User/user_promo_detail_screen.dart';
import 'Settings/app_about_screen.dart';
import 'Settings/user_terms_service_screen.dart';
import 'Settings/help_center_screen.dart';
import 'Settings/privacy_policy_screen.dart';
import 'Promotions/add_promo1_screen.dart';
import 'Promotions/add_promo2_screen.dart';
import 'Promotions/add_promo3_screen.dart';
import 'Promotions/add_promo4_screen.dart';
import 'Promotions/add_promo5_screen.dart';
import 'Administrator/admin_dashboard_screen.dart';
import 'Administrator/admin_usuarios_screen.dart';
import 'Administrator/admin_promos_screen.dart';
import 'Administrator/admin_store_screen.dart';
import 'Administrator/admin_noti_activity_screen.dart';
import 'Administrator/admin_noti_report_screen.dart';
import 'Administrator/admin_noti_alert_screen.dart';
import 'Administrator/admin_noti_exportar_screen.dart';
import 'services/promo_service.dart';
import 'services/session_manager.dart';


initialRoute: sessionManager.isOnboardingSeen()
    ? AppRoutes.login
    : AppRoutes.onboarding1,

final sessionManager = SessionManager();
final promoService = PromoService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SessionManager.init();
  await promoService.init();
  await promoService.loadLocalPromociones();

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
            builder: (context) => VerifyCodeScreen(email: email),
            settings: settings,
          );
        }
        if (settings.name == AppRoutes.newPassword) {
          final email = settings.arguments is String
              ? settings.arguments as String
              : null;
          return MaterialPageRoute(
            builder: (context) => NewPasswordScreen(email: email),
            settings: settings,
          );
        }
        return null;
      },

      routes: {
        // 👇 NUEVA RUTA AGREGADA
        AppRoutes.onboarding1: (context) => const Onboarding1Screen(),

        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
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