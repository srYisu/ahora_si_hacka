import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MONITOR DE ESTADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text('Actividad Reciente', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Row(children: [
          _tab('TODO', true), const SizedBox(width: 8), _tab('NO LEÍDOS', false),
        ]),
        const SizedBox(height: 20),

        // Notifications list
        ..._notifs.map((n) => _notifCard(n)),

        const SizedBox(height: 20),

        // Resumen semanal
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('RESUMEN SEMANAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryGreen, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            const Text('Has gestionado 12 alertas esta semana.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textWhite)),
            const SizedBox(height: 6),
            Text('Tasa de respuesta: 85%', style: TextStyle(fontSize: 13, color: AppColors.textWhite.withValues(alpha: 0.7))),
          ]),
        ),
      ]),
    );
  }

  static Widget _tab(String label, bool sel) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(color: sel ? AppColors.primaryTeal : Colors.transparent, borderRadius: BorderRadius.circular(8), border: sel ? null : Border.all(color: AppColors.border)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? AppColors.textWhite : AppColors.textSecondary, letterSpacing: 0.5)),
  );

  static Widget _notifCard(_Notif n) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: n.color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(n.icon, color: n.color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          Text(n.time, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ]),
        const SizedBox(height: 5),
        Text.rich(TextSpan(children: n.desc.map((s) => TextSpan(text: s.text, style: TextStyle(fontSize: 12, fontWeight: s.bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textSecondary))).toList())),
        if (n.actions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 12, children: n.actions.map((a) => Text(a, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryTeal, letterSpacing: 0.8))).toList()),
        ],
      ])),
    ]),
  );
}

class _Span { final String text; final bool bold; const _Span(this.text, {this.bold = false}); }
class _Notif {
  final IconData icon; final Color color; final String title, time; final List<_Span> desc; final List<String> actions;
  const _Notif({required this.icon, required this.color, required this.title, required this.time, required this.desc, this.actions = const []});
}

const _notifs = [
  _Notif(icon: Icons.check_circle_outline, color: AppColors.success, title: 'Reporte Finalizado', time: 'HACE 5 MIN',
    desc: [_Span('Tu reporte en '), _Span('Calle 10', bold: true), _Span(' ha sido RESUELTO. El equipo técnico ha verificado la reparación del sensor ambiental.')],
    actions: ['VER DETALLES →']),
  _Notif(icon: Icons.engineering_outlined, color: AppColors.primaryTeal, title: 'Técnico en camino', time: 'HACE 2 HORAS',
    desc: [_Span('Un técnico especializado está atendiendo tu reporte de '), _Span('Calidad de Aire', bold: true), _Span('. Se estima un tiempo de diagnóstico de 45 minutos.')]),
  _Notif(icon: Icons.warning_amber_rounded, color: AppColors.danger, title: 'Alerta de Umbral', time: 'AYER, 18:45',
    desc: [_Span('Se ha detectado una anomalía en la zona de monitoreo '), _Span('Sector Norte', bold: true), _Span('. Los niveles de CO2 superan los límites configurados.')],
    actions: ['REVISAR MAPA', 'DESCARTAR']),
  _Notif(icon: Icons.info_outline, color: AppColors.info, title: 'Actualización de Sistema', time: 'AYER, 09:20',
    desc: [_Span('Hemos optimizado los algoritmos de detección. Tu panel de impacto ahora muestra datos con 15% más de precisión.')]),
];
