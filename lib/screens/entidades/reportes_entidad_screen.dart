import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color _kSidebarDark = Color(0xFF0A3A32);
const Color _kPrimaryGreen = Color(0xFF1B5E55);
const Color _kTextDark = Color(0xFF1A1A1A);
const Color _kTextGrey = Color(0xFF757575);

class ReportesEntidadScreen extends StatefulWidget {
  const ReportesEntidadScreen({super.key});

  @override
  State<ReportesEntidadScreen> createState() => _ReportesEntidadScreenState();
}

class _ReportesEntidadScreenState extends State<ReportesEntidadScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reportes = [];
  bool _isLoading = true;
  String _filtroEstado = 'todos';

  @override
  void initState() {
    super.initState();
    _loadReportes();
  }

  Future<void> _loadReportes() async {
    try {
      final data = await _supabase
          .from('reportes')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _reportes = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredReportes {
    if (_filtroEstado == 'todos') return _reportes;
    return _reportes.where((r) => r['estado'] == _filtroEstado).toList();
  }

  int _countByEstado(String estado) =>
      _reportes.where((r) => r['estado'] == estado).length;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: _buildFilters()),
                const SizedBox(width: 24),
                Expanded(child: _buildReportesList()),
              ],
            )
          else
            Column(
              children: [
                _buildFilters(),
                const SizedBox(height: 20),
                _buildReportesList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reportes Recibidos',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestiona las alertas ambientales enviadas por los ciudadanos.',
                style: TextStyle(fontSize: 14, color: _kTextGrey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kPrimaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text(
                'TOTAL : ',
                style: TextStyle(
                  color: _kTextGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_reportes.length}',
                style: const TextStyle(
                  color: _kPrimaryGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statChip(
            'PENDIENTES',
            _countByEstado('pendiente'),
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statChip(
            'ASIGNADOS',
            _countByEstado('asignado'),
            const Color(0xFF0097A7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statChip(
            'RESUELTOS',
            _countByEstado('resuelto'),
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kTextGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FILTRAR POR ESTADO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _kTextGrey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _filterBtn('todos', 'Todos'),
          _filterBtn('pendiente', 'Pendiente'),
          _filterBtn('asignado', 'Asignado'),
          _filterBtn('resuelto', 'Resuelto'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadReportes,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('ACTUALIZAR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kPrimaryGreen,
                side: const BorderSide(color: _kPrimaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String value, String label) {
    final isActive = _filtroEstado == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => _filtroEstado = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive
                ? _kPrimaryGreen.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
              color: isActive ? _kPrimaryGreen : _kTextDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportesList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: _kPrimaryGreen),
        ),
      );
    }

    final list = _filteredReportes;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: _kPrimaryGreen.withOpacity(0.2)),
            const SizedBox(height: 12),
            const Text(
              'No hay reportes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextGrey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: list
          .map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildReporteCard(r),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReporteCard(Map<String, dynamic> r) {
    final String estado = r['estado'] ?? 'pendiente';
    final String tipo = r['tipo_residuo'] ?? 'otro';
    final String? prioridad = r['prioridad'];
    final String desc = r['descripcion'] ?? 'Sin descripción';
    final double? lat = r['latitud'];
    final double? lng = r['longitud'];
    final String createdAt = r['created_at'] != null
        ? _formatTime(r['created_at'])
        : '';

    Color estadoColor;
    switch (estado) {
      case 'pendiente':
        estadoColor = Colors.orange;
        break;
      case 'asignado':
        estadoColor = const Color(0xFF0097A7);
        break;
      case 'resuelto':
        estadoColor = Colors.green;
        break;
      default:
        estadoColor = _kTextGrey;
    }

    Color prioridadColor;
    switch (prioridad) {
      case 'ALTA':
      case 'CRITICA':
        prioridadColor = Colors.red;
        break;
      case 'MEDIA':
        prioridadColor = Colors.orange;
        break;
      default:
        prioridadColor = _kTextGrey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: type + estado + priority
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tipo.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _kPrimaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (prioridad != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: prioridadColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    prioridad,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: prioridadColor,
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  estado.toUpperCase(),
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            desc,
            style: const TextStyle(fontSize: 14, color: _kTextDark, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Bottom row: location + time
          Row(
            children: [
              if (lat != null && lng != null) ...[
                const Icon(Icons.location_on, size: 14, color: _kPrimaryGreen),
                const SizedBox(width: 4),
                Text(
                  '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 11, color: _kTextGrey),
                ),
                const SizedBox(width: 16),
              ],
              const Icon(Icons.access_time, size: 14, color: _kTextGrey),
              const SizedBox(width: 4),
              Text(
                createdAt,
                style: const TextStyle(fontSize: 11, color: _kTextGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
      return 'Hace ${diff.inDays} días';
    } catch (_) {
      return '';
    }
  }
}
