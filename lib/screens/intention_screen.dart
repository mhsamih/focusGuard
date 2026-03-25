import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/stats_provider.dart';

class IntentionScreen extends StatefulWidget {
  const IntentionScreen({super.key});
  @override State<IntentionScreen> createState() => _IntentionScreenState();
}

class _IntentionScreenState extends State<IntentionScreen> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌅', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              const Text('Good morning, Mohamed!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('What is your main focus today?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 30),
              TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white),
                maxLength: 80,
                decoration: InputDecoration(
                  hintText: 'e.g. Finish the Flutter app module...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E3A5F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: const TextStyle(color: Colors.white30),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_ctrl.text.trim().isNotEmpty) {
                      context.read<StatsProvider>().setIntention(_ctrl.text.trim());
                    }
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5EAA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Start My Day', style: TextStyle(fontSize: 16)),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Skip for now', style: TextStyle(color: Colors.white30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
