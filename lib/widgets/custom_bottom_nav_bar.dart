import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
            border: Border(
              top: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.grey[800]!
                    : Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.map_sharp, 'Overview', 0, themeProvider),
                  _buildNavItem(Icons.list_sharp, 'Records', 1, themeProvider),
                  _buildNavItem(
                    Icons.add_location_alt_sharp,
                    'New Entry',
                    2,
                    themeProvider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    ThemeProvider themeProvider,
  ) {
    final isSelected = widget.currentIndex == index;
    final bgColor = isSelected ? const Color(0xFFE6E4C0) : Colors.transparent;
    final iconColor = isSelected
        ? Colors.black
        : (themeProvider.isDarkMode ? Colors.white54 : Colors.black54);

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 12.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isSelected ? const Color(0xFFE6E4C0) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 26.0),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
