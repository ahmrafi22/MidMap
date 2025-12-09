import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/overview_screen.dart';
import 'screens/records_screen.dart';
import 'screens/new_entry_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.publicSansTextTheme(ThemeData.light().textTheme)
          .copyWith(
            // Titles use Poppins with higher weight
            titleLarge: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            titleMedium: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            titleSmall: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            // Headlines use Poppins
            headlineLarge: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            headlineMedium: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            headlineSmall: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            // Body text uses Public Sans
            bodyLarge: GoogleFonts.publicSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            bodyMedium: GoogleFonts.publicSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            bodySmall: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            // Labels use Public Sans
            labelLarge: GoogleFonts.publicSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            labelMedium: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            labelSmall: GoogleFonts.publicSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black87,
      textTheme: GoogleFonts.publicSansTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            // Titles use Poppins with higher weight
            titleLarge: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            titleMedium: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleSmall: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            // Headlines use Poppins
            headlineLarge: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            headlineMedium: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineSmall: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            // Body text uses Public Sans
            bodyLarge: GoogleFonts.publicSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            bodyMedium: GoogleFonts.publicSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            bodySmall: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            // Labels use Public Sans
            labelLarge: GoogleFonts.publicSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            labelMedium: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            labelSmall: GoogleFonts.publicSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MidMap',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OverviewScreen(),
    RecordsScreen(),
    NewEntryScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
