import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';

class RegistroUsuarios extends StatefulWidget {
  const RegistroUsuarios({super.key});

  @override
  State<RegistroUsuarios> createState() => _RegistroUsuariosState();
}

class _RegistroUsuariosState extends State<RegistroUsuarios> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  void _msg(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _register() async {
    final nombre = _nombreCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    final codigo = _codigoCtrl.text.trim();

    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _msg('Complete todos los campos obligatorios', Colors.orange);
      return;
    }
    if (password != confirm) {
      _msg('Las contraseñas no coinciden', Colors.orange);
      return;
    }
    if (password.length < 6) {
      _msg('La contraseña debe tener al menos 6 caracteres', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      // --- Si tiene código, buscar la organización por codigo_generado ---
      String? organizacionId;
      if (codigo.isNotEmpty) {
        final codigoInt = int.tryParse(codigo);
        if (codigoInt == null) {
          _msg('El código debe ser numérico', Colors.orange);
          setState(() => _isLoading = false);
          return;
        }

        final orgData = await supabase
            .from('organizaciones')
            .select('id')
            .eq('codigo_generado', codigoInt)
            .maybeSingle();

        if (orgData == null) {
          _msg('El código de asociación no existe', Colors.orange);
          setState(() => _isLoading = false);
          return;
        }
        organizacionId = orgData['id'];
      }

      // --- Crear cuenta en Auth ---
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': nombre},
      );

      if (res.user == null) {
        _msg('No se pudo crear la cuenta', AppColors.danger);
        setState(() => _isLoading = false);
        return;
      }

      final userId = res.user!.id;

      // --- Decidir tabla de destino ---
      if (organizacionId != null) {
        // Ayudante → insertar en personas_apoyo
        await supabase.from('personas_apoyo').insert({
          'id': userId,
          'nombre': nombre,
          'email': email,
          'organizacion_id': organizacionId,
          'rol': 'Técnico',
          'estado': 'ACTIVO',
        });
        _msg('¡Registrado como ayudante!', AppColors.primary);
      } else {
        // Usuario común → insertar en usuarios_comunes
        await supabase.from('usuarios_comunes').insert({
          'id': userId,
          'nombre': nombre,
        });
        _msg('¡Cuenta creada exitosamente!', AppColors.primary);
      }

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _msg('Error: ${e.message}', AppColors.danger);
    } catch (e) {
      _msg('Error del sistema: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF00695C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.person_add_rounded, size: 56, color: AppColors.secondary),
                  const SizedBox(height: 12),
                  const Text('REGISTRO', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const Text('NUEVA CUENTA DE USUARIO', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  const SizedBox(height: 40),
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
                          const Text('Crear Cuenta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                          const SizedBox(height: 6),
                          const Text('Complete los datos para registrarse', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                          const SizedBox(height: 28),
                          _field(Icons.person_outline, 'NOMBRE COMPLETO', _nombreCtrl, 'Ej. María López'),
                          const SizedBox(height: 18),
                          _field(Icons.alternate_email_rounded, 'CORREO ELECTRÓNICO', _emailCtrl, 'correo@ejemplo.com'),
                          const SizedBox(height: 18),
                          _field(Icons.lock_outline_rounded, 'CONTRASEÑA', _passwordCtrl, 'Mínimo 6 caracteres', obscure: true),
                          const SizedBox(height: 18),
                          _field(Icons.lock_rounded, 'CONFIRMAR CONTRASEÑA', _confirmCtrl, 'Repita su contraseña', obscure: true),
                          const SizedBox(height: 18),
                          _codeField(),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('CREAR CUENTA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                              child: const Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ),
                          ),
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

  Widget _field(IconData icon, String label, TextEditingController ctrl, String hint, {bool obscure = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
          filled: true,
          fillColor: AppColors.bgMint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ],
  );

  Widget _codeField() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.03),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.groups_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('CÓDIGO DE ASOCIACIÓN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: const Text('OPCIONAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codigoCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 20),
            hintText: 'Ej. 1234',
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Si una organización te proporcionó un código, ingrésalo para registrarte como ayudante ambiental.',
          style: TextStyle(fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic),
        ),
      ],
    ),
  );
}