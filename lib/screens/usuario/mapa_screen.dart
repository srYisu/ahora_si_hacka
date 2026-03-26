import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primaryTeal, borderRadius: BorderRadius.circular(6)),
          child: const Text('MONITOR GEOGRÁFICO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textWhite, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 10),
        Text('Mapa de Zonas\nMonitoreadas', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)),
        const SizedBox(height: 6),
        Text('Visualización en tiempo real de zonas de monitoreo ambiental.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),

        // Map placeholder
        Expanded(child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.bgMint, AppColors.bgMint.withValues(alpha: 0.5), AppColors.bgLight]))),
              CustomPaint(size: Size.infinite, painter: _GridPainter()),
              Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)]),
                  child: const Icon(Icons.location_on, color: AppColors.textWhite, size: 24),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)]),
                  child: const Text('Mapa interactivo - Próximamente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
              ])),
              // GPS badge
              Positioned(top: 12, right: 12, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.textWhite, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  const Text('GPS ACTIVO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                ]),
              )),
              // Zone markers
              Positioned(top: 50, left: 30, child: _ZoneMarker('Zona Norte', AppColors.success)),
              Positioned(top: 100, right: 40, child: _ZoneMarker('Zona Este', AppColors.warning)),
              Positioned(bottom: 80, left: 60, child: _ZoneMarker('Zona Sur', AppColors.primaryGreen)),
            ]),
          ),
        )),
      ]),
    );
  }
}

class _ZoneMarker extends StatelessWidget {
  final String label; final Color color;
  const _ZoneMarker(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: color, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primaryTeal.withValues(alpha: 0.06)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
