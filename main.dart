import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const NovaPlanApp());
}

class NovaPlanApp extends StatelessWidget {
  const NovaPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaPlan',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('fa'),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    StatsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'امروز'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'آمار'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'تنظیمات'),
        ],
      ),
    );
  }
}
