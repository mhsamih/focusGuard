import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../services/lock_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  Timer? _timer;
  String _quote = '';

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _startWatchdog();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _loadQuote() async {
    final raw = await rootBundle.loadString('assets/quotes.json');
    final list = List<String>.from(jsonDecode(raw));
    list.shuffle();
    setState(() => _quote = list.first);
  }

  void _startWatchdog() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = context.read<SessionProvider>();
      session.tickCooldown();
      if (session.cooldownSeconds <= 0) {
        session.endCooldown();
        _timer?.cancel();
        context.go('/');
      }
    });
  }

  Future<void> _useEmergency() async {
    final settings = context.read<SettingsProvider>();
    if (settings.emergencyUsedToday >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency override already used today.')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        title: const Text('Emergency Override', style: TextStyle(color: Colors.white)),
        content: const Text('You have 1 emergency override per day. Use it now?',
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, unlock 5 min', style: TextStyle(color: Colors.orange))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      settings.update();
      settings.emergencyUsedToday = 1;
      await settings.save();
      _timer?.cancel();
      context.read<SessionProvider>().startSession();
      context.go('/');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session  = context.watch<SessionProvider>();
    final settings = context.watch<SettingsProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF64B5F6), size: 80),
                  const SizedBox(height: 24),
                  const Text('Cooldown Active',
                    style: TextStyle(color: Colors.white, fontSize: 28,
                        fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Phone unlocks in',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                  const SizedBox(height: 20),
                  Text(session.formattedCooldown,
                    style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 64,
                        fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const SizedBox(height: 12),
                  Text('Daily limit: ${settings.dailyLimitMinutes} min  |  '
                      'Cooldown: ${settings.cooldownMinutes} min',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  const SizedBox(height: 40),
                  if (_quote.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('"$_quote"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70,
                            fontSize: 15, fontStyle: FontStyle.italic)),
                    ),
                  const SizedBox(height: 32),
                  if (settings.emergencyUsedToday == 0)
                    TextButton(
                      onPressed: _useEmergency,
                      child: const Text('Emergency Override (1/day)',
                        style: TextStyle(color: Colors.orange70)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
