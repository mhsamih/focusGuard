import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../services/lock_service.dart';
import '../services/foreground_service.dart';
import '../widgets/session_ring.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIntention());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session  = context.read<SessionProvider>();
      final settings = context.read<SettingsProvider>();

      if (session.state == SessionState.active) {
        session.tickSession();
        final limitSec = settings.sessionLimitMinutes * 60;
        final dailySec = settings.dailyLimitMinutes  * 60;
        if (session.sessionSeconds >= limitSec ||
            session.dailyTotalSeconds >= dailySec) {
          _triggerLock();
        }
      } else if (session.state == SessionState.cooldown) {
        session.tickCooldown();
        if (session.cooldownSeconds <= 0) {
          session.endCooldown();
        }
      } else if (session.state == SessionState.focusMode) {
        session.tickFocus();
      }
    });
  }

  Future<void> _triggerLock() async {
    final session  = context.read<SessionProvider>();
    final settings = context.read<SettingsProvider>();
    final stats    = context.read<StatsProvider>();
    stats.addRecord(SessionRecord(
      date: DateTime.now(),
      durationSeconds: session.sessionSeconds,
      hitLimit: true,
    ));
    session.startCooldown(settings.cooldownMinutes);
    await LockService.lockScreen();
    if (mounted) context.go('/lock');
  }

  void _checkIntention() {
    final stats = context.read<StatsProvider>();
    if (stats.todayIntention.isEmpty) {
      context.go('/intention');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session  = context.watch<SessionProvider>();
    final settings = context.watch<SettingsProvider>();
    final stats    = context.watch<StatsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('FocusGuard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart, color: Colors.white70),
            onPressed: () => context.go('/stats')),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => context.go('/settings')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Intention banner
            if (stats.todayIntention.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text("Today: \${stats.todayIntention}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13))),
                ]),
              ),

            // Session Ring
            SessionRing(
              session: session,
              limitMinutes: settings.sessionLimitMinutes,
            ),
            const SizedBox(height: 30),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (session.state == SessionState.idle) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      session.startSession();
                      ForegroundTimerService.start();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5EAA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ] else if (session.state == SessionState.active) ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final s = context.read<StatsProvider>();
                      final sp = context.read<SessionProvider>();
                      s.addRecord(SessionRecord(
                        date: DateTime.now(),
                        durationSeconds: sp.sessionSeconds,
                        hitLimit: false,
                      ));
                      sp.endCooldown();
                      await ForegroundTimerService.stop();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('End Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Focus Mode button
            if (session.state == SessionState.idle)
              TextButton.icon(
                onPressed: () => context.go('/focus'),
                icon: const Icon(Icons.self_improvement, color: Color(0xFF64B5F6)),
                label: const Text('Start Focus Session',
                  style: TextStyle(color: Color(0xFF64B5F6))),
              ),

            const SizedBox(height: 28),
            DailySummaryCard(session: session, settings: settings),
            const SizedBox(height: 16),
            StreakCard(stats: stats),
          ],
        ),
      ),
    );
  }
}
