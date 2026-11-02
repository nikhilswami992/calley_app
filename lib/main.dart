import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/services/api_client.dart';
import 'data/services/calley_repository.dart';
import 'data/services/local_mock_calley_data_source.dart';
import 'data/services/remote_calley_data_source.dart';
import 'providers/app_provider.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/language_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final repository = CalleyRepository(
    remote: RemoteCalleyDataSource(ApiClient()),
    local: LocalMockCalleyDataSource(prefs),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(prefs: prefs, repository: repository),
      child: const CalleyApp(),
    ),
  );
}

class CalleyApp extends StatelessWidget {
  const CalleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calley',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _InitialRouter(),
    );
  }
}

class _InitialRouter extends StatelessWidget {
  const _InitialRouter();

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    if (!app.hasSelectedLanguage) {
      return const LanguageScreen();
    }
    if (app.user == null) {
      return const RegisterScreen();
    }
    if (!app.hasSeenIntro) {
      return const OnboardingScreen();
    }
    return const DashboardScreen();
  }
}
