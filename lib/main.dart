import 'package:flutter/material.dart';
import 'Core/Routes/app_routes.dart';

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
      initialRoute: AppRoutes.onboarding,
      routes: {
        /*AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.onboarding2: (context) => const OnboardingScreen2(),
        AppRoutes.onboarding3: (context) => const OnboardingScreen3(),
        AppRoutes.onboarding4: (context) => const OnboardingScreen4(),
        AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
        AppRoutes.manageUsers: (context) => const ManageUsersScreen(),
        AppRoutes.managePromotions: (context) => const ManagePromotionsScreen(),
        AppRoutes.manageStores: (context) => const ManageStoresScreen(),
        AppRoutes.manageNotifications: (context) => const ManageNotificationsScreen(),
        AppRoutes.userHome: (context) => const UserHomeScreen(),
        AppRoutes.userProfile: (context) => const UserProfileScreen(),
        AppRoutes.userFavorites: (context) => const UserFavoritesScreen(),
        AppRoutes.userEdit: (context) => const UserEditScreen(),
        AppRoutes.explore: (context) => const ExploreScreen(),
        AppRoutes.promotionDetails: (context) => const PromotionDetailsScreen(),
        AppRoutes.addPromotions: (context) => const AddPromotionsScreen(),
        AppRoutes.addPromotions2: (context) => const AddPromotionsScreen2(),
        AppRoutes.addPromotions3: (context) => const AddPromotionsScreen3(),
        AppRoutes.addPromotions4: (context) => const AddPromotionsScreen4(),
        AppRoutes.addPromotions5: (context) => const AddPromotionsScreen5(),
        AppRoutes.termsService: (context) => const TermsServiceScreen(),
        AppRoutes.privacyPolicy: (context) => const PrivacyPolicyScreen(),
        AppRoutes.aboutUs: (context) => const AboutUsScreen(),
        AppRoutes.helpCenter: (context) => const HelpCenterScreen(),
        */
      },
    );
  }
}


