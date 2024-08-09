import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Dashboard.dart';
import 'HomePage.dart';
import 'RegisterPage.dart';
import 'SignInPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: 'https://xggmukhccukaupbwhvaq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnZ211a2hjY3VrYXVwYndodmFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI5MzAwNTMsImV4cCI6MjAzODUwNjA1M30.EiTdfW-g6G1AzN0C0bRY03pk-WQ6oc8moQo7Gwcpmwk');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SignInPage(),
        '/register': (context) => RegisterPage(), // Implementasi halaman register
        '/dashboard': (context) => Dashboard(),
        '/home': (context) => HomePage(), // Implementasi halaman home setelah login
      },
    );
  }
}