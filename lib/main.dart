import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/session_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/intention_screen.dart';
import 'services/foreground_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ForegroundTimerService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()..load()),
      ],
      child: const FocusGuardApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',        builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/stats',   builder: (_, __) => const StatsScreen()),
    GoRoute(path: '/settings',builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/focus',   builder: (_, __) => const FocusScreen()),
    GoRoute(path: '/lock',    builder: (_, __) => const LockScreen()),
    GoRoute(path: '/intention',builder: (_, __) => const IntentionScreen()),
  ],
);

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FocusGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E5EAA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      routerConfig: _router,
    );
  }
}
