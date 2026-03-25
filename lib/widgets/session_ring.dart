import 'package:flutter/material.dart';
import '../providers/session_provider.dart';

class SessionRing extends StatelessWidget {
  final SessionProvider session;
  final int limitMinutes;
  const SessionRing({super.key, required this.session, required this.limitMinutes});

  @override
  Widget build(BuildContext context) {
    final limitSec = limitMinutes * 60.0;
    final progress = (session.sessionSeconds / limitSec).clamp(0.0, 1.0);
    final isActive = session.state == SessionState.active;

    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 200, height: 200,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 10,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation(
            progress > 0.8 ? Colors.redAccent : const Color(0xFF2E5EAA)),
        ),
      ),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(isActive ? Icons.timer : Icons.timer_off_outlined,
          color: isActive ? const Color(0xFF64B5F6) : Colors.white30, size: 28),
        const SizedBox(height: 6),
        Text(
          session.state == SessionState.active
            ? session.formattedSession
            : session.state == SessionState.cooldown
              ? '🔒 ${session.formattedCooldown}'
              : '00:00',
          style: TextStyle(
            color: session.state == SessionState.cooldown ? Colors.orange : Colors.white,
            fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          session.state == SessionState.active
            ? 'of ${limitMinutes}m session'
            : session.state == SessionState.cooldown
              ? 'cooldown remaining'
              : 'idle',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ]),
    ]);
  }
}
