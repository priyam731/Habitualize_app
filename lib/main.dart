import 'package:flutter/material.dart';
import 'package:habitualize/page/Rootpage/rootpage.dart';
import 'package:habitualize/page/homepage/home_screen.dart';
import 'package:habitualize/page/auth/signup_page.dart';
import 'package:habitualize/page/splash_screen.dart';
import 'package:habitualize/page/profile/profile_page.dart';
import 'package:habitualize/providers/profile_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profileProvider = ProfileProvider();
  await profileProvider.loadProfileData();

  runApp(
    ChangeNotifierProvider(
      create: (_) => profileProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const RootPage(),
        '/home': (context) => const HabitualizeHome(),
        '/signup': (context) => const SignupPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
