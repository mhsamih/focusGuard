import 'package:flutter/material.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';

class DailySummaryCard extends StatelessWidget {
  final SessionProvider session;
  final SettingsProvider settings;
  const DailySummaryCard({super.key, required this.session, required this.settings});

  @override
  Widget build(BuildContext context) {
    final pct = (session.dailyTotalSeconds / (settings.dailyLimitMinutes * 60)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Today', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _Stat('Total Time', session.formattedDaily),
          _Stat('Unlocks', '${session.todayUnlockCount}x'),
          _Stat('Limit Hits', '${session.todayLimitHitCount}x'),
        ]),
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation(pct > 0.85 ? Colors.redAccent : const Color(0xFF2E5EAA)),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 6),
        Text('${(pct * 100).round()}% of daily ${settings.dailyLimitMinutes}m limit',
          style: const TextStyle(color: Colors.white30, fontSize: 11)),
      ]),
    );
  }

  Widget _Stat(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
  ]);
}
