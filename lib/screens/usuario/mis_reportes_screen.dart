import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';

class MisReportesScreen extends StatefulWidget {
  const MisReportesScreen({super.key});

  @override
  State<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends State<MisReportesScreen> {
  final _supabase = Supabase.instance.client;
  String _filter = 'TODOS';

  @override
  Widget build(BuildContext context) {
    final userId = _supabase.auth.currentUser?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MONITOR DE USUARIO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mis Reportes',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gestión y seguimiento de incidencias ambientales detectadas.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('TODOS'),
                const SizedBox(width: 8),
                _filterChip('PENDIENTE'),
                const SizedBox(width: 8),
                _filterChip('VALIDADO'),
                const SizedBox(width: 8),
                _filterChip('RECHAZADO'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // StreamBuilder for real-time reports
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase
                .from('reportes')
                .stream(primaryKey: ['id'])
                .eq('usuario_id', userId ?? '')
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primaryTeal),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error al cargar reportes: ${snapshot.error}'),
                );
              }

              final allReports = snapshot.data ?? [];
              final filteredReports = _filter == 'TODOS'
                  ? allReports
                  : allReports.where((r) => r['estado'] == _filter).toList();

              if (filteredReports.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 48, color: AppColors.textLight.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay reportes que coincidan.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: filteredReports.map((r) => _reportCard(r)).toList(),
              );
            },
          ),

          const SizedBox(height: 24),
          // Statistics section (Keep static as high-level indicators)
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primaryTeal : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> r) {
    final String id = r['id'].toString().substring(0, 8).toUpperCase();
    final String type = r['tipo_residuo'] ?? 'DESCONOCIDO';
    final String status = r['estado'] ?? 'PENDIENTE';
    final String dateStr = r['created_at'] != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(r['created_at']))
        : '---';
    final String priority = r['prioridad'] ?? 'MEDIA';

    Color statusColor;
    switch (status) {
      case 'VALIDADO':
        statusColor = AppColors.success;
        break;
      case 'RECHAZADO':
        statusColor = AppColors.danger;
        break;
      default:
        statusColor = AppColors.warning;
    }

    Color priorityColor;
    switch (priority) {
      case 'ALTA':
        priorityColor = AppColors.danger;
        break;
      case 'BAJA':
        priorityColor = AppColors.primaryTeal;
        break;
      default:
        priorityColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: AppColors.bgLight,
              child: r['imagen_url'] != null
                  ? Image.network(
                      r['imagen_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 24, color: AppColors.textLight),
                    )
                  : const Icon(Icons.image, size: 24, color: AppColors.textLight),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#$id',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgMint,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      priority,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: priorityColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r['descripcion'] ?? 'Sin descripción',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 10, color: AppColors.textLight),
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

  Widget _buildStatsSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tasa de Resolución', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
              const SizedBox(height: 6),
              Text('Contribución a la limpieza ambiental basada en reportes validados.', style: TextStyle(fontSize: 11, color: AppColors.textWhite.withValues(alpha: 0.7))),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('92.1', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, height: 1)),
                  SizedBox(width: 4),
                  Padding(padding: EdgeInsets.only(bottom: 6), child: Text('%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryGreen))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
