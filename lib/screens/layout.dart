import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lynxgaming/constant/theme.dart';
import 'package:get/get.dart';
import 'package:lynxgaming/store/auth_store.dart';

import 'arena_screen.dart';
import 'vpn_screen.dart';
import 'skin_screen.dart';


class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ArenaUnlockerScreen(),
    SkinUnlockerScreen(),
    VpnScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthStore>();
    final nickname = authController.user['nickname'] ?? 'Guest';
    return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 9, 23),
        title: Text(
          'Welcome, $nickname',
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundDark,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Rajdhani-Medium',
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Rajdhani-Medium',
          fontSize: 12,
        ),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.perspective),
            label: 'ARENA',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.flame),
            label: 'SKIN',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shield),
            label: 'VPN',
          ),
        ],
      ),
    );
  }
}
