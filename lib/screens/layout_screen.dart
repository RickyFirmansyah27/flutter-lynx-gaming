import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lynxgaming/constant/theme.dart';

import 'backup_screen.dart';
import 'vpn_screen.dart';
import 'test_api_screen.dart';


class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BackupScreen(),
    VpnScreen(),
    ApiTestScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lynx Gaming',
          style: TextStyle(
            fontFamily: 'Orbitron-Bold',
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
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
            icon: Icon(CupertinoIcons.folder),
            label: 'BACKUP',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shield),
            label: 'VPN',
          ),
           BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: 'CONFIG',
          ),
        ],
      ),
    );
  }
}
