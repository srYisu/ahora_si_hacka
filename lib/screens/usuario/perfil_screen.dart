import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CONFIGURACIÓN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text('Mi Perfil', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 20),

        // Profile card
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
          child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.15),
              child: const Icon(Icons.person, size: 40, color: AppColors.primaryTeal)),
            const SizedBox(height: 14),
            const Text('Alex Rivero', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('alex.rivero@conservator.mx', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(color: AppColors.primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text('CONSERVADOR NIVEL 4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryTeal, letterSpacing: 1)),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _statBox('Reportes', '47'), const SizedBox(width: 12),
              _statBox('Resueltos', '39'), const SizedBox(width: 12),
              _statBox('Días', '156'),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Info Personal
        _section('Información Personal', [
          _row(Icons.person_outline, 'Nombre', 'Alex Rivero'),
          _row(Icons.email_outlined, 'Email', 'alex.rivero@conservator.mx'),
          _row(Icons.phone_outlined, 'Teléfono', '+52 55 1234 5678'),
          _row(Icons.location_on_outlined, 'Zona', 'Sector Norte - CDMX'),
        ]),
        const SizedBox(height: 12),

        // Preferencias
        _section('Preferencias', [
          _row(Icons.notifications_outlined, 'Notificaciones', 'Activadas'),
          _row(Icons.language, 'Idioma', 'Español'),
          _row(Icons.dark_mode_outlined, 'Tema', 'Claro'),
        ]),
        const SizedBox(height: 20),

        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Cerrar Sesión'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger),
            padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )),
      ]),
    );
  }

  static Widget _statBox(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: AppColors.bgMint, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    ]),
  );

  static Widget _section(String title, List<Widget> items) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 14),
      ...items,
    ]),
  );

  static Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.primaryTeal),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
      Flexible(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.end)),
    ]),
  );
}
