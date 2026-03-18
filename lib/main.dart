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


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
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
        return null;
      },
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.newPassword: (context) => const NewPasswordScreen(),
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
        /*
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.onboarding2: (context) => const OnboardingScreen2(),
        AppRoutes.onboarding3: (context) => const OnboardingScreen3(),
        AppRoutes.onboarding4: (context) => const OnboardingScreen4(),
        AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
        AppRoutes.manageUsers: (context) => const ManageUsersScreen(),
        AppRoutes.managePromotions: (context) => const ManagePromotionsScreen(),
        AppRoutes.manageStores: (context) => const ManageStoresScreen(),
        AppRoutes.manageNotifications: (context) => const ManageNotificationsScreen(),
        
        AppRoutes.addPromotions: (context) => const AddPromotionsScreen(),
        AppRoutes.addPromotions2: (context) => const AddPromotionsScreen2(),
        AppRoutes.addPromotions3: (context) => const AddPromotionsScreen3(),
        AppRoutes.addPromotions4: (context) => const AddPromotionsScreen4(),
        AppRoutes.addPromotions5: (context) => const AddPromotionsScreen5(),
        */
      },
    );
  }
}


