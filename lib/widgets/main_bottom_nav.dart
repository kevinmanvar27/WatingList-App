import 'package:flutter/material.dart';

/// Reusable bottom navigation bar used on Home, Waiting List and Settings screens.
class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isLoggedIn;
  final int showHomePage; // 1 to show home, 0 to hide

  final VoidCallback? onHomeTap;
  final VoidCallback? onWaitingTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onLoginTap;

  const MainBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.isLoggedIn,
    this.showHomePage = 1, // Default to show home
    this.onHomeTap,
    this.onWaitingTap,
    this.onSettingsTap,
    this.onLogoutTap,
    this.onLoginTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: !isLoggedIn ? 0 :60, // Increased height to accommodate all elements properly
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = _buildItems(context);
          final itemWidth = constraints.maxWidth / items.length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              return SizedBox(
                width: itemWidth,
                child: item,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    // When not logged in: Home + Login (like the app bar behavior)
    if (!isLoggedIn) {
      List<Widget> items = [];

      // Add Home item only if showHomePage is 1
      if (showHomePage == 1) {
        items.add(
          _NavItem(
            icon: Icons.home,
            // label: "Home",
            bgColor: currentIndex == 0 ? const Color(0xFFFFF0E6) : Colors.white,
            textColor: currentIndex == 0 ? const Color(0xFFFF6B00) : Colors.black,
            onTap: onHomeTap,
          ),
        );
      }

      // Calculate the actual index for Login based on whether home is shown
      final int loginActualIndex = showHomePage == 1 ? 1 : 0;

      items.add(
        _NavItem(
          icon: Icons.login,
          // label: "Login",
          bgColor: currentIndex == loginActualIndex ? const Color(0xFFFFF0E6) : Colors.white,
          textColor: currentIndex == loginActualIndex ? const Color(0xFFFF6B00) : Colors.green,
          onTap: onLoginTap,
        ),
      );

      return items;
    }

    // Logged in: navigation items
    List<Widget> items = [];
    
    // Add Home item only if showHomePage is 1
    if (showHomePage == 1) {
      items.add(
        _NavItem(
          icon: Icons.home,
          // label: "Home",
          bgColor: currentIndex == 0 ? const Color(0xFFFFF0E6) : Colors.white,
          textColor: currentIndex == 0 ? const Color(0xFFFF6B00) : Colors.black,
          onTap: onHomeTap,
        ),
      );
    }
    
    // Calculate the actual index for Waiting List based on whether home is shown
    final int waitingListActualIndex = showHomePage == 1 ? 1 : 0;
    
    items.add(
      _NavItem(
        icon: Icons.list_alt,
        // label: "Waiting List",
        bgColor: currentIndex == waitingListActualIndex ? const Color(0xFFFFF0E6) : Colors.white,
        textColor: currentIndex == waitingListActualIndex ? const Color(0xFFFF6B00) : Colors.black,
        onTap: onWaitingTap,
      ),
    );
    
    // Calculate the actual index for Settings based on whether home is shown
    final int settingsActualIndex = showHomePage == 1 ? 2 : 1;
    
    items.add(
      _NavItem(
        icon: Icons.settings,
        // label: "Settings",
        bgColor: currentIndex == settingsActualIndex ? const Color(0xFFFFF0E6) : Colors.white,
        textColor: currentIndex == settingsActualIndex ? const Color(0xFFFF6B00) : Colors.black,
        onTap: onSettingsTap,
      ),
    );
    
    items.add(
      _NavItem(
        icon: Icons.logout,
        // label: "Logout",
        bgColor: Colors.white,
        textColor: const Color(0xFFD9534F),
        onTap: onLogoutTap,
      ),
    );
    
    return items;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  // final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    // required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 8,bottom: 8), // Adjusted padding to balance larger icon
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: textColor), // Increased icon size to match the larger text
            const SizedBox(height: 2), // Reduced spacing between icon and text
            /*Text(
              label,
              style: TextStyle(fontSize: 13, color: textColor), // Increased font size for better readability
              textAlign: TextAlign.center,
              softWrap: false,
            ),*/
          ],
        ),
      ),
    );
  }
}


