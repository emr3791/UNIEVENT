import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/achievement_provider.dart';
import 'features/main/presentation/pages/main_page.dart';

import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/payment_screen.dart';
import 'models/event.dart';
import 'providers/social_provider.dart';
import 'providers/event_chat_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => EventChatProvider()),
      ],
      child: const UniEventApp(),
    ),
  );
}

class UniEventApp extends StatelessWidget {
  const UniEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'UniEvent AI',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.getUniversityTheme(
            code: themeProvider.universityCode,
            isDark: false,
          ),
          darkTheme: AppTheme.getUniversityTheme(
            code: themeProvider.universityCode,
            isDark: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistrationScreen(),
            '/home': (context) => const MainPage(),
            '/personal_info': (context) => const PersonalInfoScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/payment') {
              final args = settings.arguments as Event;
              return MaterialPageRoute(
                builder: (context) => PaymentScreen(event: args),
              );
            }
            return null; // Let Routes handle other unknown configs
          },
        );
      },
    );
  }
}
