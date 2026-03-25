import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _unlocked = false;

  Future<bool> _checkPin(SettingsProvider s) async {
    if (s.protectedPin.isEmpty) return true;
    if (_unlocked) return true;
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        title: const Text('Enter PIN', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '4-digit PIN',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text == s.protectedPin),
              child: const Text('Unlock')),
        ],
      ),
    );
    if (ok == true) setState(() => _unlocked = true);
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (!_unlocked && s.protectedPin.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.lock, color: Colors.orange),
              onPressed: () async => await _checkPin(s),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader('⏱ Timer Settings'),
          _SliderTile(label: 'Session Limit', value: s.sessionLimitMinutes.toDouble(),
            min: 1, max: 60, unit: 'min',
            onChanged: (v) async { if (!await _checkPin(s)) return; s.update(sessionLimit: v.round()); }),
          _SliderTile(label: 'Cooldown Duration', value: s.cooldownMinutes.toDouble(),
            min: 5, max: 120, unit: 'min',
            onChanged: (v) async { if (!await _checkPin(s)) return; s.update(cooldown: v.round()); }),
          _SliderTile(label: 'Daily Total Limit', value: s.dailyLimitMinutes.toDouble(),
            min: 10, max: 360, unit: 'min',
            onChanged: (v) async { if (!await _checkPin(s)) return; s.update(dailyLimit: v.round()); }),
          const SizedBox(height: 20),
          _SectionHeader('🔒 Lock Mode'),
          SwitchListTile(
            title: const Text('Hard Mode', style: TextStyle(color: Colors.white)),
            subtitle: const Text('No override possible.', style: TextStyle(color: Colors.white38, fontSize: 12)),
            value: s.hardMode, activeColor: Colors.redAccent,
            onChanged: (v) async { if (!await _checkPin(s)) return; s.update(hard: v); },
          ),
          SwitchListTile(
            title: const Text('Unlock Pause Screen', style: TextStyle(color: Colors.white)),
            subtitle: const Text('5-sec mindful pause before phone opens',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
            value: s.unlockPauseEnabled, activeColor: const Color(0xFF2E5EAA),
            onChanged: (v) => s.update(unlockPause: v),
          ),
          const SizedBox(height: 20),
          _SectionHeader('🌙 Bedtime Mode'),
          SwitchListTile(
            title: const Text('Enable Bedtime Lock', style: TextStyle(color: Colors.white)),
            subtitle: Text('${s.bedtimeStart.format(context)} – ${s.bedtimeEnd.format(context)}',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
            value: s.bedtimeEnabled, activeColor: const Color(0xFF2E5EAA),
            onChanged: (v) => s.update(bedtime: v),
          ),
          if (s.bedtimeEnabled) ...[
            ListTile(
              title: const Text('Bedtime Start', style: TextStyle(color: Colors.white70)),
              trailing: Text(s.bedtimeStart.format(context),
                style: const TextStyle(color: Color(0xFF64B5F6))),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: s.bedtimeStart);
                if (t != null) s.update(bedStart: t);
              },
            ),
            ListTile(
              title: const Text('Bedtime End', style: TextStyle(color: Colors.white70)),
              trailing: Text(s.bedtimeEnd.format(context),
                style: const TextStyle(color: Color(0xFF64B5F6))),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: s.bedtimeEnd);
                if (t != null) s.update(bedEnd: t);
              },
            ),
          ],
          const SizedBox(height: 20),
          _SectionHeader('🔑 Protection PIN'),
          ListTile(
            leading: const Icon(Icons.pin, color: Colors.white70),
            title: const Text('Set / Change PIN', style: TextStyle(color: Colors.white)),
            subtitle: Text(s.protectedPin.isEmpty ? 'No PIN set' : 'PIN is set',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
            onTap: () async {
              final ctrl = TextEditingController();
              final pin = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1E3A5F),
                  title: const Text('Set PIN', style: TextStyle(color: Colors.white)),
                  content: TextField(controller: ctrl, obscureText: true,
                    keyboardType: TextInputType.number, maxLength: 4,
                    style: const TextStyle(color: Colors.white)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Save')),
                  ],
                ),
              );
              if (pin != null && pin.length == 4) s.update(pin: pin);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13,
        fontWeight: FontWeight.w600, letterSpacing: 0.8)),
  );
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value, min, max;
  final String unit;
  final ValueChanged<double> onChanged;
  const _SliderTile({required this.label, required this.value,
    required this.min, required this.max, required this.unit, required this.onChanged});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text('${value.round()} $unit',
            style: const TextStyle(color: Color(0xFF64B5F6), fontWeight: FontWeight.bold)),
        ]),
      ),
      Slider(value: value, min: min, max: max,
        activeColor: const Color(0xFF2E5EAA), inactiveColor: Colors.white12,
        onChanged: onChanged),
    ],
  );
}
