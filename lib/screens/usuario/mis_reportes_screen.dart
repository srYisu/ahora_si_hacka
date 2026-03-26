import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class MisReportesScreen extends StatelessWidget {
  const MisReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MONITOR DE USUARIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text('Mis Reportes', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('Gestión y seguimiento de incidencias ambientales detectadas.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 14),

        // Filters
        Row(children: [
          _filterChip('Recientes'), const SizedBox(width: 8),
          _filterChip('Todos'), const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.tune, size: 14, color: AppColors.textWhite),
              SizedBox(width: 6),
              Text('Filtrar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),

        // Report cards - mobile style
        ..._reportes.map((r) => _mobileReportCard(r)),

        const SizedBox(height: 16),
        Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            Text('Ver reportes anteriores', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(width: 6), Icon(Icons.arrow_forward, size: 16, color: AppColors.textPrimary),
          ]),
        )),
        const SizedBox(height: 20),

        // Tasa de Resolución
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tasa de Resolución Personal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
            const SizedBox(height: 6),
            Text('Has contribuido a la limpieza del 85% de las incidencias reportadas en tu zona este mes.', style: TextStyle(fontSize: 12, color: AppColors.textWhite.withValues(alpha: 0.7))),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: const [
              Text('85.4', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, height: 1)),
              SizedBox(width: 4),
              Padding(padding: EdgeInsets.only(bottom: 6), child: Text('%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryGreen))),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        // Estado General
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
          child: Column(children: [
            const Text('ESTADO GENERAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 90, height: 90, child: CircularProgressIndicator(value: 0.75, strokeWidth: 7, backgroundColor: AppColors.bgMint, color: AppColors.primaryGreen, strokeCap: StrokeCap.round)),
              Column(mainAxisSize: MainAxisSize.min, children: const [
                Text('75%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
                Text('EFICACIA', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1)),
              ]),
            ])),
            const SizedBox(height: 12),
            Text('Actualización en tiempo real basada en reportes validados.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }

  static Widget _filterChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
  );

  static Widget _mobileReportCard(_Report r) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(color: r.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(r.icon, color: r.color, size: 24)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(r.id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: r.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: r.statusColor)),
            child: Text(r.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: r.statusColor)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(r.tipo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Row(children: [
          Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
          const SizedBox(width: 4),
          Expanded(child: Text(r.ubicacion, style: const TextStyle(fontSize: 11, color: AppColors.textLight))),
          Text(r.fecha, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
      ])),
    ]),
  );
}

class _Report {
  final IconData icon; final Color color; final String id, tipo, ubicacion, fecha, status; final Color statusColor;
  const _Report({required this.icon, required this.color, required this.id, required this.tipo, required this.ubicacion, required this.fecha, required this.status, required this.statusColor});
}

const _reportes = [
  _Report(icon: Icons.shopping_bag_outlined, color: AppColors.warning, id: '#ENV-2023-9021', tipo: 'Plásticos/PET', ubicacion: 'Sector Norte, Cuenc...', fecha: '12 Oct 2023', status: 'RESUELTO', statusColor: AppColors.success),
  _Report(icon: Icons.build_outlined, color: AppColors.warning, id: '#ENV-2023-9045', tipo: 'Chatarra Metálica', ubicacion: 'Perímetro Forestal E...', fecha: '15 Oct 2023', status: 'EN PROGRESO', statusColor: AppColors.warning),
  _Report(icon: Icons.science_outlined, color: AppColors.danger, id: '#ENV-2023-9110', tipo: 'Químicos Peligrosos', ubicacion: 'Zona Industrial Sur', fecha: '18 Oct 2023', status: 'PENDIENTE', statusColor: AppColors.danger),
];
