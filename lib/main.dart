import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Reemplaza con tus credenciales de Supabase
  await Supabase.initialize(
    url: 'AQUI_VA_TU_SUPABASE_URL',
    anonKey: 'AQUI_VA_TU_ANON_KEY',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Supabase configurado (Falta poner las claves)'),
        ),
      ),
    );
  }
}
