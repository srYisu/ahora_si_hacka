import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_theme.dart';
import '../../widgets/stat_card.dart';

class ImpactoScreen extends StatelessWidget {
  const ImpactoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'MÉTRICAS DE IMPACTO',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              children: const [
                TextSpan(text: 'Resultados de la\n'),
                TextSpan(
                  text: 'Comunidad',
                  style: TextStyle(color: AppColors.primaryTeal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Este año se generó tal cantidad de residuos lo equivalente a',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Main stat cards - 2 blancas juntas, verde abajo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: StatCard(
                  icon: Icons.delete_outline,
                  value: '450',
                  label: 'BOLSAS DE BASURA',
                  subtitle: '↗ +12% vs mes ant.',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.auto_delete_outlined,
                  value: '890',
                  label: 'PLÁSTICO RETIRADO',
                  subtitle: '🏠 Meta: 1,000kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(
            width: double.infinity,
            height: 195,
            child: StatCard(
              icon: Icons.recycling,
              value: '120',
              label: 'CONTENEDORES DE RECICLAJE',
              subtitle: '✓ Optimización del 94%',
              highlighted: true,
            ),
          ),
          const SizedBox(height: 16),

          // Secondary cards - 2+1 layout
          Row(
            children: const [
              Expanded(
                child: MiniStatCard(
                  icon: Icons.people_outline,
                  label: 'PARTICIPANTES',
                  value: '1,284',
                  progress: 0.75,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MiniStatCard(
                  icon: Icons.location_on_outlined,
                  label: 'ZONAS LIMPIAS',
                  value: '42',
                  progress: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const MiniStatCard(
            icon: Icons.calendar_today_outlined,
            label: 'DÍAS MONITOREO',
            value: '156',
            progress: 0.85,
          ),
          const SizedBox(height: 20),

          // Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tendencia de Recolección',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Volumen mensual del último semestre',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _YearChip(label: '2023', selected: false),
                    const SizedBox(width: 8),
                    _YearChip(label: '2024', selected: true),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(height: 180, child: _buildBarChart()),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Eficiencia Local
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'EFICIENCIA LOCAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: 0.75,
                          strokeWidth: 7,
                          backgroundColor: AppColors.primaryTeal.withValues(
                            alpha: 0.3,
                          ),
                          color: AppColors.primaryGreen,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '75%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          Text(
                            'OBJETIVO',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hemos superado el promedio regional de recolección selectiva por 12 puntos porcentuales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Último Reporte
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ÚLTIMO REPORTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Zona Bosque Central',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'HACE 2 HORAS · 15KG RECUPERADOS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                const m = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN'];
                return value.toInt() < m.length
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          m[value.toInt()],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _g(0, 40, 55),
          _g(1, 50, 65),
          _g(2, 35, 45),
          _g(3, 60, 80),
          _g(4, 55, 70),
          _g(5, 45, 60),
        ],
      ),
    );
  }

  static BarChartGroupData _g(int x, double y1, double y2) => BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y1,
        color: AppColors.bgMint,
        width: 10,
        borderRadius: BorderRadius.circular(3),
      ),
      BarChartRodData(
        toY: y2,
        color: AppColors.primaryTeal,
        width: 10,
        borderRadius: BorderRadius.circular(3),
      ),
    ],
  );
}

class _YearChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _YearChip({required this.label, required this.selected});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: selected ? AppColors.primaryDark : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: selected ? AppColors.primaryDark : AppColors.border,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.textWhite : AppColors.textSecondary,
      ),
    ),
  );
}
