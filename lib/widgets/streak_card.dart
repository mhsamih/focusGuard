import 'package:flutter/material.dart';
import '../providers/stats_provider.dart';

class StreakCard extends StatelessWidget {
  final StatsProvider stats;
  const StreakCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2E5EAA)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${stats.currentStreak}-day streak!',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Best: ${stats.longestStreak} days',
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
        const Spacer(),
        if (stats.currentStreak >= 3)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
      ]),
    );
  }
}
