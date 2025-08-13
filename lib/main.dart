import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/business.dart';
import 'screens/dashboard.dart';
import 'screens/investment.dart';
import 'screens/real_estate.dart';
import 'screens/personal_purchases.dart';
import 'screens/settings.dart';
import 'screens/business_selection_screen.dart';
import 'screens/business_tier_selection_screen.dart';
import 'screens/business_detail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp(appName: "Business World"));
}

class MyApp extends StatelessWidget {
  final String appName;

  const MyApp({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const MainDashboard(),
        '/business_selection': (context) => const BusinessSelectionScreen(),
        '/business': (context) => const BusinessScreen(),
        '/business_detail': (context) {
          final businessId =
              ModalRoute.of(context)!.settings.arguments as String;
          return BusinessDetailScreen(businessId: businessId);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/business_tier') {
          final businessType = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) =>
                BusinessTierSelectionScreen(businessType: businessType),
          );
        }
        return null; // fallback for undefined routes
      },
    );
  }
}

/// Splash screen checks login state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // show splash briefly
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Business World',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Main app with bottom navigation bar to switch between screens
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  // Non-const to preserve widget state
  final List<Widget> _screens = [
    DashboardScreen(),
    BusinessScreen(),
    InvestmentScreen(),
    RealEstateScreen(),
    PersonalPurchasesScreen(),
    SettingsScreen(),
  ];

  static const List<String> _titles = [
    'Dashboard',
    'Businesses',
    'Investments',
    'Real Estate',
    'Personal Purchases',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Investment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Real Estate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Personal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
