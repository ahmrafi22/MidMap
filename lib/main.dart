import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/overview_screen.dart';
import 'screens/records_screen.dart';
import 'screens/new_entry_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MidMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.publicSansTextTheme(Theme.of(context).textTheme)
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
              ),
              headlineMedium: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              headlineSmall: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              // Body text uses Public Sans
              bodyLarge: GoogleFonts.publicSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              bodyMedium: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              bodySmall: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              // Labels use Public Sans
              labelLarge: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              labelMedium: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              labelSmall: GoogleFonts.publicSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
      home: const MainScreen(),
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
