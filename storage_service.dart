import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  static const _blocksPrefix = 'blocks_'; // + date
  static const _xpKey = 'xp_total';
  static const _streakKey = 'streak_count';
  static const _lastFullDayKey = 'last_full_day';

  Future<List<TimeBlock>> loadBlocksForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_blocksPrefix$date');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => TimeBlock.fromJson(e)).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  Future<void> saveBlocksForDate(String date, List<TimeBlock> blocks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(blocks.map((b) => b.toJson()).toList());
    await prefs.setString('$_blocksPrefix$date', raw);
  }

  /// Returns all blocks saved in the last [days] days (including today),
  /// keyed by date string, for stats.
  Future<Map<String, List<TimeBlock>>> loadRecentBlocks(
      List<String> dates) async {
    final result = <String, List<TimeBlock>>{};
    for (final d in dates) {
      result[d] = await loadBlocksForDate(d);
    }
    return result;
  }

  Future<int> getXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  Future<void> addXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_xpKey) ?? 0;
    await prefs.setInt(_xpKey, current + amount);
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<String?> getLastFullDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastFullDayKey);
  }

  Future<void> setStreak(int value, String lastFullDay) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, value);
    await prefs.setString(_lastFullDayKey, lastFullDay);
  }

  Future<bool> getReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reminder_enabled') ?? false;
  }

  Future<void> setReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', value);
  }
}
