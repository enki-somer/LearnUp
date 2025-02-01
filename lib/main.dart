import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'edit_profile_page.dart';
import 'news_page.dart';
import 'theme_provider.dart';
import 'register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDnTT3dr-h6w7GgL9qaPPrkDZ9mGP_4zsI",
        authDomain: "eduflut.firebaseapp.com",
        projectId: "eduflut",
        storageBucket: "eduflut.firebasestorage.app",
        messagingSenderId: "804589797275",
        appId: "1:804589797275:web:70a116f83bb8be20e36b3e",
        measurementId: "G-VJLG3ZSVG4"),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Grad App',
          theme: themeProvider.theme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomePage(),
            '/settings': (context) => const SettingsPage(),
            '/edit_profile': (context) => const EditProfilePage(),
            '/news': (context) => const NewsPage(),
            '/register': (context) => const RegisterPage(),
          },
        );
      },
    );
  }
}
