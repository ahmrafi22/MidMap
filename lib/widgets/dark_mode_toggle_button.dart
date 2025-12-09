import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class DarkModeToggleButton extends StatelessWidget {
  const DarkModeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SizedBox(
          height: 50,
          width: 50,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              themeProvider.toggleTheme();
            },
            child: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        );
      },
    );
  }
}
