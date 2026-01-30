import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_colors.dart';
import 'core/providers/habit_provider.dart';
import 'core/services/notification_service.dart';
import 'features/home/presentation/screens/main_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.backgroundLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: HabitlyApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class HabitlyApp extends ConsumerWidget {
  final bool showOnboarding;
  const HabitlyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Habitly',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryOrange,
          secondary: AppColors.secondaryPurple,
          surface: AppColors.backgroundLightCard,
          surfaceContainerHighest: AppColors.backgroundLight,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryOrange,
          secondary: AppColors.secondaryPurple,
          surface: AppColors.backgroundDarkCard,
          surfaceContainerHighest: AppColors.backgroundDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
      ),
      home: showOnboarding ? const OnboardingScreen() : const MainScreen(),
    );
  }
}
