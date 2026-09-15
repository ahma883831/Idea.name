import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'storage_service.dart';
import 'theme.dart';
import 'widgets/neon_card.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _storage = StorageService();
  bool _loading = true;
  Map<BlockCategory, double> _hoursByCategory = {};
  double _totalPlanned = 0;
  double _totalCompleted = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: i));
      return DateFormat('yyyy-MM-dd').format(d);
    });
    final recent = await _storage.loadRecentBlocks(dates);

    final hoursByCategory = <BlockCategory, double>{
      for (final c in BlockCategory.values) c: 0,
    };
    double totalPlanned = 0;
    double totalCompleted = 0;

    for (final blocks in recent.values) {
      for (final b in blocks) {
        hoursByCategory[b.category] = (hoursByCategory[b.category] ?? 0) + b.hours;
        totalPlanned += b.hours;
        if (b.completed) totalCompleted += b.hours;
      }
    }

    setState(() {
      _hoursByCategory = hoursByCategory;
      _totalPlanned = totalPlanned;
      _totalCompleted = totalCompleted;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
    }

    final maxHours = _hoursByCategory.values.isEmpty
        ? 1.0
        : _hoursByCategory.values.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);

    return Scaffold(
      appBar: AppBar(title: const Text('آمار ۷ روز اخیر')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NeonCard(
            glowColor: AppColors.neonCyan,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn('برنامه‌ریزی‌شده', '${_totalPlanned.toStringAsFixed(1)} ساعت'),
                _statColumn('تکمیل‌شده', '${_totalCompleted.toStringAsFixed(1)} ساعت'),
                _statColumn(
                  'درصد',
                  _totalPlanned == 0
                      ? '—'
                      : '${((_totalCompleted / _totalPlanned) * 100).toStringAsFixed(0)}٪',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('ساعت به تفکیک دسته', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ..._hoursByCategory.entries.map((entry) {
            final ratio = entry.value / maxHours;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key.label} · ${entry.value.toStringAsFixed(1)} ساعت',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(height: 14, color: AppColors.surface),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: 14,
                              width: constraints.maxWidth * ratio.clamp(0.0, 1.0),
                              decoration: BoxDecoration(
                                color: entry.key.color,
                                boxShadow: [
                                  BoxShadow(
                                    color: entry.key.color.withOpacity(0.6),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
