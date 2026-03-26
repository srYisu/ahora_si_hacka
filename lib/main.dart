import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/InicioSesion2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bhceqzmvnlepsynaxcqx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoY2Vxem12bmxlcHN5bmF4Y3F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NjAwMzQsImV4cCI6MjA5MDAzNjAzNH0.U_D2N9fXWTR1EDbmhbkEkyrKxlf1xsCE4FHota6ZrqU',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InicioSesion2(),
    );
  }
}
