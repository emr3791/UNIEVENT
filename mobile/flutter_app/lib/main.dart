import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/wallet_provider.dart';
import 'features/main/presentation/pages/main_page.dart';

import 'screens/onboarding_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widgets/reusable_banner.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/theme_preview_screen.dart';
import 'screens/payment_screen.dart';
import 'models/event.dart';
import 'providers/social_provider.dart';
import 'providers/event_chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('tr_TR');
  } catch (e) {
    debugPrint('Locale init failed: $e');
  }
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('Flutter Error caught: ${details.exception}\n${details.stack}');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ReusableBanner(
        icon: Icons.error_outline,
        title: 'Bir hata oluştu',
        subtitle:
            'Bir hata algılandı. Lütfen sayfayı yenileyin veya bize yazın: example@gmail.com',
        actionLabel: 'Yenile',
        onAction: () => {},
      ),
    );
  };
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError.onError: ${details.exception}');
  };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => AchievementProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => WalletProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => SocialProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => EventChatProvider(), lazy: true),
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
        final lightTheme = AppTheme.getUniversityTheme(
          code: themeProvider.universityCode,
          isDark: false,
        );
        final darkTheme = AppTheme.getUniversityTheme(
          code: themeProvider.universityCode,
          isDark: true,
        );
        return MaterialApp(
          title: 'UniEvent AI',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistrationScreen(),
            '/home': (context) => const MainPage(),
            '/personal_info': (context) => const PersonalInfoScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/preview_gold': (context) => const ThemePreviewScreen(),
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
