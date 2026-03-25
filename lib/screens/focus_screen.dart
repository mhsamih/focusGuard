import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../services/lock_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});
  @override State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int _selectedMinutes = 25;
  Timer? _timer;
  bool _running = false;

  void _start() {
    context.read<SessionProvider>().startFocusMode(_selectedMinutes);
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final sp = context.read<SessionProvider>();
      sp.tickFocus();
      if (sp.state != SessionState.focusMode) {
        _timer?.cancel();
        setState(() => _running = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Focus session complete! Great work.')),
        );
      }
    });
    LockService.lockScreen();
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SessionProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Focus Session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.self_improvement, color: Color(0xFF64B5F6), size: 72),
              const SizedBox(height: 24),
              const Text('Choose your focus duration',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: [15, 25, 30, 45, 60].map((m) => ChoiceChip(
                  label: Text('$m min'),
                  selected: _selectedMinutes == m,
                  selectedColor: const Color(0xFF2E5EAA),
                  labelStyle: TextStyle(color: _selectedMinutes == m ? Colors.white : Colors.white54),
                  onSelected: (_) => setState(() => _selectedMinutes = m),
                )).toList(),
              ),
              const SizedBox(height: 32),
              if (_running) ...[
                Text(sp.formattedCooldown,
                  style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 56,
                      fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                const Text('Stay focused. You can do this.',
                  style: TextStyle(color: Colors.white54)),
              ] else
                ElevatedButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Start $_selectedMinutes min Focus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5EAA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
