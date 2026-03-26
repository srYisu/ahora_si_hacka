import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  bool _filterPendiente = true;
  bool _filterEnProceso = true;
  bool _filterResuelto = false;
  String _tipoResiduo = 'Todos los tipos';
  int _currentPage = 1;

  // Mock data
  final List<_ReporteMock> _reportes = [
    _ReporteMock(
      titulo: 'Acumulación de Plásticos en Parque Sur',
      ubicacion: 'Calle Bosques, Sector 4',
      tiempo: 'Hace 2 horas',
      descripcion: 'Se reporta una gran cantidad de botellas PET y envases de comida rápida cerca de la zona de juego...',
      usuario: 'María G.',
      tipo: 'PLÁSTICOS',
      estado: 'PENDIENTE',
      prioridad: 'ALTA',
      equipo: null,
    ),
    _ReporteMock(
      titulo: 'Escombros en Vía Pública',
      ubicacion: 'Av Central con Calle 10',
      tiempo: 'Hace 5 horas',
      descripcion: 'Restos de remodelación abandonados en la banqueta, obstruyendo el paso peatonal...',
      usuario: null,
      tipo: 'ESCOMBROS',
      estado: 'EN PROCESO',
      prioridad: 'MEDIA',
      equipo: 'Equipo Eco-Alpha asignado',
    ),
    _ReporteMock(
      titulo: 'Limpieza de Vertedero Ilegal',
      ubicacion: 'Predio Baldío Norte',
      tiempo: 'Resuelto ayer',
      descripcion: 'La limpieza fue completada exitosamente. Se recolectaron 450kg de residuos mixtos.',
      usuario: null,
      tipo: 'VARIOS',
      estado: 'RESUELTO',
      prioridad: null,
      equipo: 'Finalizado por Eco-Beta',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtros + Mapa lateral
                SizedBox(
                  width: 260,
                  child: Column(
                    children: [
                      _buildFiltersCard(),
                      const SizedBox(height: 20),
                      _buildMiniMap(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Lista de reportes
                Expanded(child: _buildReportesList()),
              ],
            )
          else
            Column(
              children: [
                _buildFiltersCard(),
                const SizedBox(height: 20),
                _buildReportesList(),
                const SizedBox(height: 20),
                _buildMiniMap(),
              ],
            ),
          const SizedBox(height: 24),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                'Gestiona y coordina las alertas ambientales enviadas por los ciudadanos. Prioriza la acción regenerativa.',
                style: TextStyle(
                  fontSize: 14,
                  color: _kTextGrey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Counter badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kPrimaryGreen.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Text('ACTIVOS : ', style: TextStyle(color: _kTextGrey, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('128', style: TextStyle(color: _kPrimaryGreen, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text('Nuevo Reporte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kSidebarDark,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTADO DEL REPORTE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _kTextGrey, letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildCheckbox('Pendiente', _filterPendiente, (v) => setState(() => _filterPendiente = v!)),
          _buildCheckbox('En Proceso', _filterEnProceso, (v) => setState(() => _filterEnProceso = v!)),
          _buildCheckbox('Resuelto', _filterResuelto, (v) => setState(() => _filterResuelto = v!)),
          const SizedBox(height: 20),
          const Text('TIPO DE RESIDUO',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _kTextGrey, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _tipoResiduo,
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 13, color: _kTextDark),
              items: ['Todos los tipos', 'Plásticos', 'Orgánicos', 'Escombros', 'Metales', 'Papel']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _tipoResiduo = v!),
            ),
          ),
          const SizedBox(height: 20),
          const Text('RANGO DE FECHA',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _kTextGrey, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: _kTextGrey),
                SizedBox(width: 8),
                Text('Últimos 7 días', style: TextStyle(fontSize: 13, color: _kTextDark)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _filterPendiente = true;
                  _filterEnProceso = true;
                  _filterResuelto = false;
                  _tipoResiduo = 'Todos los tipos';
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kPrimaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('LIMPIAR FILTROS',
                  style: TextStyle(color: _kPrimaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24, height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: _kPrimaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: _kTextDark)),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(19.4326, -99.1332),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
              ],
            ),
            // Overlay
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('MAPA DE ALERTAS',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSidebarDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Ver Mapa Completo', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportesList() {
    return Column(
      children: _reportes.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildReporteCard(r),
      )).toList(),
    );
  }

  Widget _buildReporteCard(_ReporteMock reporte) {
    final Color estadoColor;
    final Color prioridadColor;
    switch (reporte.estado) {
      case 'PENDIENTE':
        estadoColor = Colors.orange;
        break;
      case 'EN PROCESO':
        estadoColor = const Color(0xFF0097A7);
        break;
      case 'RESUELTO':
        estadoColor = Colors.green;
        break;
      default:
        estadoColor = _kTextGrey;
    }
    switch (reporte.prioridad) {
      case 'ALTA':
        prioridadColor = Colors.red;
        break;
      case 'MEDIA':
        prioridadColor = Colors.orange;
        break;
      default:
        prioridadColor = _kTextGrey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder + priority badge
          Stack(
            children: [
              Container(
                width: 180, height: 160,
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Icon(Icons.image, size: 48, color: _kPrimaryGreen.withOpacity(0.4)),
              ),
              if (reporte.prioridad != null)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: prioridadColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(reporte.prioridad!,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(reporte.titulo,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTextDark)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: estadoColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(reporte.estado,
                            style: TextStyle(color: estadoColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: _kPrimaryGreen),
                      const SizedBox(width: 4),
                      Text('${reporte.ubicacion} • ${reporte.tiempo}',
                          style: const TextStyle(fontSize: 12, color: _kTextGrey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(reporte.descripcion,
                      style: const TextStyle(fontSize: 13, color: _kTextGrey, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (reporte.usuario != null) ...[
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: _kPrimaryGreen.withOpacity(0.2),
                          child: const Icon(Icons.person, size: 14, color: _kPrimaryGreen),
                        ),
                        const SizedBox(width: 6),
                        Text('Enviado por ${reporte.usuario}',
                            style: const TextStyle(fontSize: 11, color: _kTextGrey)),
                      ],
                      if (reporte.equipo != null) ...[
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: _kPrimaryGreen.withOpacity(0.2),
                          child: const Icon(Icons.groups, size: 14, color: _kPrimaryGreen),
                        ),
                        const SizedBox(width: 6),
                        Text(reporte.equipo!, style: const TextStyle(fontSize: 11, color: _kTextGrey)),
                      ],
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kPrimaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(reporte.tipo,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kPrimaryGreen)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _kPrimaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Ver Detalles',
                      style: TextStyle(color: _kPrimaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                if (reporte.estado == 'PENDIENTE')
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _kPrimaryGreen.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Asignar Equipo',
                        style: TextStyle(color: _kPrimaryGreen, fontSize: 12)),
                  ),
                if (reporte.estado == 'EN PROCESO') ...[
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Ver Detalles',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _kPrimaryGreen.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Cambiar Estado',
                        style: TextStyle(color: _kPrimaryGreen, fontSize: 12)),
                  ),
                ],
                if (reporte.estado == 'RESUELTO')
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _kPrimaryGreen.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Ver Reporte',
                        style: TextStyle(color: _kPrimaryGreen, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Mostrando 1-3 de 128 reportes',
            style: TextStyle(fontSize: 13, color: _kTextGrey)),
        Row(
          children: [
            _buildPageButton('<', false, () {}),
            ...List.generate(3, (i) => _buildPageButton('${i + 1}', i + 1 == _currentPage, () {
              setState(() => _currentPage = i + 1);
            })),
            _buildPageButton('>', false, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildPageButton(String label, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36, height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? _kPrimaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? _kPrimaryGreen : const Color(0xFFDDDDDD)),
          ),
          child: Text(label,
              style: TextStyle(
                color: isActive ? Colors.white : _kTextDark,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              )),
        ),
      ),
    );
  }
}

class _ReporteMock {
  final String titulo;
  final String ubicacion;
  final String tiempo;
  final String descripcion;
  final String? usuario;
  final String tipo;
  final String estado;
  final String? prioridad;
  final String? equipo;

  const _ReporteMock({
    required this.titulo,
    required this.ubicacion,
    required this.tiempo,
    required this.descripcion,
    this.usuario,
    required this.tipo,
    required this.estado,
    this.prioridad,
    this.equipo,
  });
}
