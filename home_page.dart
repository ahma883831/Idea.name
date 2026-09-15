import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'storage_service.dart';
import 'streak_service.dart';
import 'theme.dart';
import 'add_edit_block_page.dart';
import 'widgets/neon_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _storage = StorageService();
  late final StreakService _streakService = StreakService(_storage);
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<TimeBlock> _blocks = [];
  int _xp = 0;
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final blocks = await _storage.loadBlocksForDate(_today);
    final xp = await _storage.getXp();
    final streak = await _storage.getStreak();
    setState(() {
      _blocks = blocks;
      _xp = xp;
      _streak = streak;
      _loading = false;
    });
  }

  Future<void> _addBlock() async {
    final result = await Navigator.of(context).push<TimeBlock>(
      MaterialPageRoute(builder: (_) => AddEditBlockPage(date: _today)),
    );
    if (result != null) {
      setState(() => _blocks.add(result));
      _blocks.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
      await _storage.saveBlocksForDate(_today, _blocks);
    }
  }

  Future<void> _editBlock(TimeBlock b) async {
    final result = await Navigator.of(context).push<TimeBlock>(
      MaterialPageRoute(builder: (_) => AddEditBlockPage(date: _today, existing: b)),
    );
    if (result != null) {
      setState(() {
        final idx = _blocks.indexWhere((x) => x.id == b.id);
        _blocks[idx] = result;
        _blocks.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
      });
      await _storage.saveBlocksForDate(_today, _blocks);
    }
  }

  Future<void> _deleteBlock(TimeBlock b) async {
    setState(() => _blocks.removeWhere((x) => x.id == b.id));
    await _storage.saveBlocksForDate(_today, _blocks);
  }

  Future<void> _toggleComplete(TimeBlock b) async {
    setState(() => b.completed = !b.completed);
    await _storage.saveBlocksForDate(_today, _blocks);
    final result = await _streakService.onBlockToggled(_today, _blocks, b.completed);
    setState(() {
      _xp += result.xpGained;
      _streak = result.newStreak;
    });
    if (result.streakIncreased && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔥 امروز رو کامل کردی! استریک: ${result.newStreak} روز')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('امروز'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: AppColors.neonPink, size: 20),
                const SizedBox(width: 4),
                Text('$_streak', style: const TextStyle(color: AppColors.textPrimary)),
                const SizedBox(width: 16),
                const Icon(Icons.bolt, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 4),
                Text('$_xp XP', style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBlock,
        child: const Icon(Icons.add),
      ),
      body: _blocks.isEmpty
          ? const Center(
              child: Text(
                'هنوز بلوکی اضافه نکردی.\nروی + بزن و برنامه‌ی امروزت رو بساز.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _blocks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final b = _blocks[i];
                return NeonCard(
                  glowColor: b.category.color,
                  glowing: !b.completed,
                  onTap: () => _toggleComplete(b),
                  child: Row(
                    children: [
                      Icon(
                        b.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: b.category.color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                decoration: b.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${b.timeRangeLabel} · ${b.category.label}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        color: AppColors.surface,
                        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                        onSelected: (v) {
                          if (v == 'edit') _editBlock(b);
                          if (v == 'delete') _deleteBlock(b);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                          PopupMenuItem(value: 'delete', child: Text('حذف')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
