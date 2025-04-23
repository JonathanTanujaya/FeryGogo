import 'package:ferry_ticket_app/providers/auth_provider.dart';
import 'package:ferry_ticket_app/providers/schedule_provider.dart';
import 'package:ferry_ticket_app/providers/weather_provider.dart';
import 'package:ferry_ticket_app/screens/booking_screen.dart';
import 'package:ferry_ticket_app/screens/history_screen.dart';
import 'package:ferry_ticket_app/screens/home_screen.dart';
import 'package:ferry_ticket_app/screens/profile_screen.dart';
import 'package:ferry_ticket_app/screens/splash_screen.dart';
import 'package:ferry_ticket_app/utils/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:ferry_ticket_app/screens/Login/login_screen.dart';
import 'package:ferry_ticket_app/screens/SignUp/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:ferry_ticket_app/providers/booking_provider.dart';
import 'package:ferry_ticket_app/providers/history_provider.dart';
import 'package:ferry_ticket_app/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FeryGogo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0F52BA),
                primary: const Color(0xFF0F52BA),
              ),
            ),
            // home: const HomeScreen(),
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/home': (context) => const AuthGuard(child: MainLayout()),
            },
          );
        },
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;

  // Using const constructor for better performance
  final List<Widget> _screens = const [
    HomeScreen(),
    BookingScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          // Using IndexedStack to preserve state of all screens
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: const Color(0xFF0F52BA),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Pesan'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
          ],
        ),
      ),
    );
  }
}