import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/information_provider.dart';

import 'screens/splash/splashUI.dart';
import 'screens/Login/login_screen.dart';
import 'screens/SignUp/signup_screen.dart';
import 'screens/Home/home_screen.dart';
import 'screens/information_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/auth_guard.dart';
import 'theme.dart';

// Konstanta untuk mode debug.
const bool isDebugMode = true; // Set ke false untuk production

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');
    
    // Initialize Firebase first
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize App Check after Firebase
    print('Initializing Firebase App Check...');
    await FirebaseAppCheck.instance.activate(
      // Gunakan debug provider untuk development
      androidProvider: isDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
    
    print('Firebase initialized successfully');
    
    // Then get SharedPreferences instance
    print('Getting SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    print('SharedPreferences initialized');
    
    runApp(MyApp(prefs: prefs));
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false, // Initialize immediately
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => InformationProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FeryGogo',
            themeMode: themeProvider.themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              // Add logging for route navigation
              print('Navigating to ${settings.name}');
              
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/signup':
                  return MaterialPageRoute(builder: (_) => const SignUpScreen());
                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const AuthGuard(child: MainLayout()),
                  );
                case '/profile':
                  return MaterialPageRoute(
                    builder: (_) => const AuthGuard(child: ProfileScreen()),
                  );
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
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

class _MainLayoutState extends State<MainLayout> with AutomaticKeepAliveClientMixin {  final List<Widget> _screens = [
    const HomeScreen(),
    const InformationScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        return WillPopScope(
          onWillPop: () async {
            if (navigationProvider.currentIndex != 0) {
              navigationProvider.setIndex(0);
              return false;
            }
            return true;
          },
          child: Scaffold(
            body: Stack(
              children: [
                // Top gradient background
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F52BA), Color(0xFF3B7DE9)],
                      ),
                    ),
                  ),
                ),
                // Main content with safe area
                SafeArea(
                  child: IndexedStack(
                    index: navigationProvider.currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navigationProvider.currentIndex,
              onTap: navigationProvider.setIndex,
              selectedItemColor: const Color(0xFF0F52BA),
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              elevation: 8,              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
                BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Informasi'),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
              ],
            ),
          ),
        );
      },
    );
  }
}