import 'package:flutter/material.dart';
import 'package:houzy/repository/screens/help/helpscreen.dart';
import 'package:houzy/repository/screens/home/homescreen.dart';
import 'package:houzy/repository/screens/account/accountscreen.dart';

class BottomNavScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late int currentIndex;

  /// Asset names (make sure these PNGs exist in assets/images/)
  final List<String> icons = [
    "house.png",
    "user.png",
    "circle-help.png",
  ];

  final List<String> labels = [
    "Home",
    "Account",
    "Help",
  ];

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    /// Clamp initialIndex just in case
    currentIndex =
        widget.initialIndex.clamp(0, icons.length - 1); // keeps it in range

    pages = const [
      HomeScreen(),
      AccountScreen(),
      HelpScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Main content
          IndexedStack(
            index: currentIndex,
            children: pages,
          ),

          /// Floating nav bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: const Color(0XFFF54A00),
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                  onTap: (index) {
                    setState(() => currentIndex = index);
                  },
                  items: List.generate(icons.length, (index) {
                    final isSelected = index == currentIndex;
                    final imagePath = 'assets/images/${icons[index]}';

                    return BottomNavigationBarItem(
                      icon: Image.asset(
                        imagePath,
                        width: isSelected ? 28 : 24,
                        height: isSelected ? 28 : 24,
                        color: isSelected
                            ? const Color(0XFFF54A00)
                            : Colors.grey,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.error, color: Colors.red),
                      ),
                      label: labels[index],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
