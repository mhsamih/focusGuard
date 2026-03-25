import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_provider.dart';
import '../providers/settings_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats    = context.watch<StatsProvider>();
    final settings = context.watch<SettingsProvider>();
    final weekly   = stats.weeklyData();
    final limitMin = settings.dailyLimitMinutes.toDouble();

    final bars = weekly.asMap().entries.map((e) {
      final val = (e.value['seconds'] as int) / 60.0;
      final day = e.value['day'] as DateTime;
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: val,
          color: val >= limitMin ? Colors.redAccent : const Color(0xFF2E5EAA),
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ]);
    }).toList();

    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Your Stats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _StatTile('Current Streak', '${stats.currentStreak} days 🔥'),
              const SizedBox(width: 12),
              _StatTile('Best Streak', '${stats.longestStreak} days 🏆'),
            ]),
            const SizedBox(height: 24),
            const Text('Last 7 Days (minutes)',
              style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(BarChartData(
                barGroups: bars,
                gridData: FlGridData(
                  getDrawingHorizontalLine: (_) =>
                    const FlLine(color: Colors.white12, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(days[v.toInt() % 7],
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  )),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}m',
                      style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  )),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                maxY: (limitMin * 1.5).ceilToDouble(),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: limitMin,
                    color: Colors.orange.withOpacity(0.6),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) => 'Limit',
                      style: const TextStyle(color: Colors.orange, fontSize: 10),
                    )),
                ]),
              )),
            ),
            const SizedBox(height: 24),
            const Text('All Sessions',
              style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...stats.records.reversed.take(20).map((r) {
              final mins = r.durationSeconds ~/ 60;
              final secs = r.durationSeconds % 60;
              return ListTile(
                leading: Icon(
                  r.hitLimit ? Icons.warning_amber : Icons.check_circle_outline,
                  color: r.hitLimit ? Colors.orange : Colors.greenAccent,
                ),
                title: Text('${mins}m ${secs}s', style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${r.date.day}/${r.date.month}/${r.date.year} '
                  '${r.date.hour}:${r.date.minute.toString().padLeft(2,"0")}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: r.hitLimit
                  ? const Text('Limit hit', style: TextStyle(color: Colors.orange, fontSize: 11))
                  : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _StatTile(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}
