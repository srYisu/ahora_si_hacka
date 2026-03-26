import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';
import 'entidades/entidades_shell.dart';
import 'dashboard_shell.dart';
import 'trabajador_shell.dart';
import 'RegistroUsuarios.dart';
import 'RegistroOrganizacion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bhceqzmvnlepsynaxcqx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoY2Vxem12bmxlcHN5bmF4Y3F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NjAwMzQsImV4cCI6MjA5MDAzNjAzNH0.U_D2N9fXWTR1EDbmhbkEkyrKxlf1xsCE4FHota6ZrqU',
  );
  runApp(const MiAppTecnica());
}

class MiAppTecnica extends StatelessWidget {
  const MiAppTecnica({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoAlert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const InicioSesion2(),
    );
  }
}

class InicioSesion2 extends StatefulWidget {
  const InicioSesion2({super.key});

  @override
  State<InicioSesion2> createState() => _InicioSesion2State();
}

class _InicioSesion2State extends State<InicioSesion2> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _msg(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _msg('Ingrese sus credenciales', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase.auth.signInWithPassword(email: email, password: password);

      if (res.session != null && res.user != null) {
        final userId = res.user!.id;

        // 1. ¿Es una organización/entidad?
        final orgData = await supabase.from('organizaciones').select('id').eq('auth_user_id', userId).maybeSingle();
        if (!mounted) return;
        if (orgData != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const EntidadesShell()));
          return;
        }

        // 2. ¿Es un ayudante/trabajador (persona de apoyo)?
        final ayudanteData = await supabase.from('personas_apoyo').select('id').eq('id', userId).maybeSingle();
        if (!mounted) return;
        if (ayudanteData != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TrabajadorShell()));
          return;
        }

        // 3. Usuario común
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardShell()));
      }
    } on AuthException catch (e) {
      _msg('Denegado: ${e.message}', AppColors.danger);
    } catch (e) {
      _msg('Error de conexión: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF00695C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.eco_rounded, size: 80, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  const Text('ECOALERT', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  const Text('SISTEMA DE MONITOREO AMBIENTAL', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  const SizedBox(height: 48),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Iniciar Sesión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                          const SizedBox(height: 6),
                          const Text('Acceda a su terminal operativa', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                          const SizedBox(height: 32),
                          _field(Icons.alternate_email_rounded, 'CORREO ELECTRÓNICO', _emailCtrl),
                          const SizedBox(height: 20),
                          _field(Icons.lock_outline_rounded, 'CONTRASEÑA', _passwordCtrl, obscure: true),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity, height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ENTRAR AL SISTEMA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroUsuarios())),
                            child: const Text('¿No tienes cuenta? Regístrate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          )),
                          Center(child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroOrganizacion())),
                            child: const Text('Registrar Institución / Organización', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(IconData icon, String label, TextEditingController ctrl, {bool obscure = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl, obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true, fillColor: AppColors.bgMint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    ],
  );
}
