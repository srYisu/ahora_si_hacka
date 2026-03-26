import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../InicioSesion2.dart';

class PerfilTrabajadorScreen extends StatefulWidget {
  const PerfilTrabajadorScreen({super.key});

  @override
  State<PerfilTrabajadorScreen> createState() => _PerfilTrabajadorScreenState();
}

class _PerfilTrabajadorScreenState extends State<PerfilTrabajadorScreen> {
  final _supabase = Supabase.instance.client;
  String _nombre = '';
  String _email = '';
  String _estado = '';
  String _orgNombre = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final persona = await _supabase
          .from('personas_apoyo')
          .select('*, organizaciones(razon_social)')
          .eq('id', userId)
          .maybeSingle();

      if (mounted && persona != null) {
        setState(() {
          _nombre = persona['nombre'] ?? 'Ayudante';
          _email = persona['email'] ?? _supabase.auth.currentUser?.email ?? '';
          _estado = persona['estado'] ?? 'ACTIVO';
          _orgNombre =
              persona['organizaciones']?['razon_social'] ?? 'Sin organización';
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const InicioSesion2()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
        child: Column(
          children: [
            _profileCard(),
            const SizedBox(height: 32),
            _sectionTitle('CONFIGURACIÓN'),
            const SizedBox(height: 16),
            _menuItem(
              Icons.person_outline_rounded,
              'Información Personal',
              'Nombre, correo y rol',
            ),
            _menuItem(
              Icons.notifications_none_rounded,
              'Notificaciones',
              'Alertas y avisos de campo',
            ),
            _menuItem(
              Icons.security_rounded,
              'Seguridad',
              'Cambiar contraseña',
            ),
            const SizedBox(height: 48),
            _logoutButton(),
            const SizedBox(height: 24),
            const Text(
              'ECOALERT AYUDANTE V1.0',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryDark.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: const Icon(
            Icons.person_rounded,
            size: 48,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _nombre,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(height: 20),
        _infoBox('ESTADO', _estado),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.business_rounded,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _orgNombre,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _infoBox(String label, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryDark,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _menuItem(IconData icon, String title, String subtitle) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.bgMint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textLight,
          size: 20,
        ),
      ],
    ),
  );

  Widget _logoutButton() => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton.icon(
      onPressed: _signOut,
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text(
        'CERRAR SESIÓN',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
