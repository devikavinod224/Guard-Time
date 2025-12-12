import 'package:flutter/material.dart';
import 'package:guard_time/pages/HomeScreen/homescreen.dart';
import 'package:guard_time/pages/ProfileScreen/profile_screen.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; // 0 for HomeScreen, 1 for ProfileScreen
  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr,
          ),
        ],
        onTap: onTabTapped,
      ),
    );
  }
}
