import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 1.0)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildIconWithBackground(Icons.folder_outlined, 0),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithBackground(Icons.list, 1),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithBackground(Icons.add_location_alt, 2),
            label: 'New Entry',
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithBackground(IconData icon, int index) {
    final isSelected = currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E4C0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(icon, color: isSelected ? Colors.black : Colors.black54),
    );
  }
}
