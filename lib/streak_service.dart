import 'package:intl/intl.dart';
import 'models.dart';
import 'storage_service.dart';

class StreakResult {
  final int xpGained;
  final int newStreak;
  final bool streakIncreased;
  StreakResult(this.xpGained, this.newStreak, this.streakIncreased);
}

class StreakService {
  final StorageService storage;
  StreakService(this.storage);

  static const int xpPerBlock = 10;
  static const int xpFullDayBonus = 30;

  String _yesterday(String today) {
    final d = DateFormat('yyyy-MM-dd').parse(today);
    final y = d.subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(y);
  }

  /// Call after toggling a block's completion for [date] with the full
  /// current list of that day's [blocks]. Awards XP and updates streak
  /// if the whole day's plan is complete.
  Future<StreakResult> onBlockToggled(
      String date, List<TimeBlock> blocks, bool justCompleted) async {
    int xp = 0;
    if (justCompleted) {
      xp += xpPerBlock;
    } else {
      xp -= xpPerBlock;
    }

    bool streakIncreased = false;
    int streak = await storage.getStreak();
    final lastFullDay = await storage.getLastFullDay();

    final allDone = blocks.isNotEmpty && blocks.every((b) => b.completed);

    if (allDone && lastFullDay != date) {
      xp += xpFullDayBonus;
      final expectedPrev = _yesterday(date);
      if (lastFullDay == expectedPrev) {
        streak += 1;
      } else {
        streak = 1;
      }
      await storage.setStreak(streak, date);
      streakIncreased = true;
    } else if (!allDone && lastFullDay == date) {
      // Undid completion on a day that had been marked full; roll back.
      streak = streak > 0 ? streak - 1 : 0;
      await storage.setStreak(streak, _yesterday(date));
    }

    if (xp != 0) {
      await storage.addXp(xp);
    }

    return StreakResult(xp, streak, streakIncreased);
  }
}
