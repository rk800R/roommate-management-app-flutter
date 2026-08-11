import 'package:flutter/material.dart';
import '../theme/themedata.dart';
import 'HomeScreen.dart';
import 'ChoreBoardScreen.dart';
import 'ExpenseSplitterScreen.dart';
import 'NoticeBoardScreen.dart';
import 'ProfileScreen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
      const ChoreBoardScreen(),
      const ExpenseSplitterScreen(),
      const NoticeBoardScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist_rounded), label: 'Chores'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}