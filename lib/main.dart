import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front_end_mobile/providers/book_provider.dart';
import 'package:front_end_mobile/screens/auth/login_buku.dart';
import 'package:front_end_mobile/screens/home_screen.dart';

void main() {
  // ignore: avoid_print
  print('Starting app');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
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
      title: 'Book App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}