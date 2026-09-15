import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'theme.dart';
import 'widgets/neon_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = StorageService();
  bool _reminderEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _storage.getReminderEnabled();
    setState(() {
      _reminderEnabled = enabled;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            NeonCard(
              glowColor: AppColors.neonPurple,
              glowing: false,
              child: SwitchListTile(
                value: _reminderEnabled,
                activeColor: AppColors.neonPurple,
                title: const Text('یادآوری بلوک‌های امروز', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text(
                  'یک یادآوری ملایم برای شروع بلوک بعدی',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                onChanged: (v) async {
                  setState(() => _reminderEnabled = v);
                  await _storage.setReminderEnabled(v);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'نکته: این نسخه یادآوری رو فقط ذخیره می‌کنه؛ برای نوتیفیکیشن واقعی سیستم می‌تونی بعداً پکیج flutter_local_notifications رو اضافه کنی (نیاز به تنظیم دستی AndroidManifest داره).',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
