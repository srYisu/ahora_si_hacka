import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const Color _kSidebarDark = Color(0xFF0A3A32);
const Color _kPrimaryGreen = Color(0xFF1B5E55);
const Color _kTextDark = Color(0xFF1A1A1A);
const Color _kTextGrey = Color(0xFF757575);

class GestionEquiposScreen extends StatefulWidget {
  const GestionEquiposScreen({super.key});

  @override
  State<GestionEquiposScreen> createState() => _GestionEquiposScreenState();
}

class _GestionEquiposScreenState extends State<GestionEquiposScreen> {
  String _departamentoFilter = 'Todos los departamentos';

  final List<_Miembro> _miembrosEquipo = [
    _Miembro('Lucía Mendez', 'Líder de cuadrilla', 'Bio-remediación'),
    _Miembro('Carlos Arturo', 'Técnico de campo', 'Residuos Sólidos'),
  ];

  final List<_Participante> _participantes = [
    _Participante('Jorge Villalobos', 'Logística', 'Disponible'),
    _Participante('Elena Castro', 'Operaciones', 'Asignada'),
    _Participante('Mateo Santos', 'Análisis', 'Disponible'),
    _Participante('Sofía Herrera', 'Campo', 'Asignada'),
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
                Expanded(flex: 2, child: _buildMainContent()),
                const SizedBox(width: 24),
                SizedBox(width: 320, child: _buildParticipantsPanel()),
              ],
            )
          else
            Column(
              children: [
                _buildMainContent(),
                const SizedBox(height: 24),
                _buildParticipantsPanel(),
              ],
            ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildZoneMap()),
                const SizedBox(width: 24),
                Expanded(child: _buildAssignReportCard()),
              ],
            )
          else
            Column(
              children: [
                _buildZoneMap(),
                const SizedBox(height: 24),
                _buildAssignReportCard(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gestión de Equipos',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _kTextDark)),
                  const SizedBox(height: 8),
                  Text(
                    'Coordina las fuerzas operativas en campo, asigna zonas de regeneración y monitorea el impacto colectivo.',
                    style: TextStyle(fontSize: 14, color: _kTextGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add, size: 18, color: Colors.white),
              label: const Text('Crear nuevo usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kSidebarDark,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.groups, size: 18, color: _kPrimaryGreen),
              label: const Text('Crear equipo de limpieza', style: TextStyle(color: _kPrimaryGreen, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kPrimaryGreen, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Featured team card
        _buildFeaturedTeamCard(),
        const SizedBox(height: 20),
        _buildMembersSection(),
      ],
    );
  }

  Widget _buildFeaturedTeamCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('EQUIPO DESTACADO',
                    style: TextStyle(color: _kPrimaryGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const Spacer(),
              // Avatars stack
              SizedBox(
                width: 100, height: 36,
                child: Stack(
                  children: List.generate(3, (i) => Positioned(
                    left: i * 22.0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: _kPrimaryGreen.withOpacity(0.2 + i * 0.15),
                        child: const Icon(Icons.person, size: 16, color: _kPrimaryGreen),
                      ),
                    ),
                  )),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('+8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _kPrimaryGreen)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Guardianes del Río Cali',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kTextDark)),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildStatBadge(Icons.location_on, 'ZONA ASIGNADA', 'Cuenca Alta\n- Sector A'),
              const SizedBox(width: 16),
              _buildStatBadge(Icons.description, 'REPORTES ABIERTOS', '14\nIncidencias'),
              const SizedBox(width: 16),
              _buildStatBadge(Icons.trending_up, 'RENDIMIENTO', '92% Eficacia'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAF8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kPrimaryGreen.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: _kPrimaryGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                          color: _kTextGrey, letterSpacing: 0.5),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kTextDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MIEMBROS DEL EQUIPO',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kTextGrey, letterSpacing: 1)),
          const SizedBox(height: 16),
          ..._miembrosEquipo.map((m) => _buildMemberTile(m)),
        ],
      ),
    );
  }

  Widget _buildMemberTile(_Miembro miembro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _kPrimaryGreen.withOpacity(0.15),
            child: const Icon(Icons.person, color: _kPrimaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(miembro.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _kTextDark)),
                Text(miembro.rol, style: const TextStyle(fontSize: 12, color: _kTextGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FAF8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Text('ESPECIALIDAD', style: TextStyle(fontSize: 9, color: _kTextGrey, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Text(miembro.especialidad,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextDark)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: _kTextGrey),
            itemBuilder: (_) => [
              const PopupMenuItem(child: Text('Ver perfil')),
              const PopupMenuItem(child: Text('Reasignar')),
              const PopupMenuItem(child: Text('Remover')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsPanel() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Participantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kTextDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('124 Total',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _kPrimaryGreen)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _departamentoFilter,
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 13, color: _kTextDark),
              icon: const Icon(Icons.filter_list, size: 18),
              items: ['Todos los departamentos', 'Logística', 'Operaciones', 'Análisis', 'Campo']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _departamentoFilter = v!),
            ),
          ),
          const SizedBox(height: 16),
          ..._participantes.map((p) => _buildParticipantTile(p)),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(_Participante p) {
    final bool isAvailable = p.estado == 'Disponible';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _kPrimaryGreen.withOpacity(0.15),
            child: const Icon(Icons.person, size: 20, color: _kPrimaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kTextDark)),
                Row(
                  children: [
                    Text(p.departamento, style: const TextStyle(fontSize: 11, color: _kTextGrey)),
                    const Text(' • ', style: TextStyle(color: _kTextGrey)),
                    Text(
                      p.estado,
                      style: TextStyle(
                        fontSize: 11,
                        color: isAvailable ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
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

  Widget _buildZoneMap() {
    return Container(
      height: 260,
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
                initialCenter: LatLng(3.4516, -76.5320), // Cali
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
              ],
            ),
            Positioned(
              bottom: 16, left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mapa de Zonas',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('3 equipos asignados en este sector',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignReportCard() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kPrimaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_turned_in, size: 36, color: _kPrimaryGreen),
          ),
          const SizedBox(height: 16),
          const Text('Asignar Reporte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kTextDark)),
          const SizedBox(height: 8),
          const Text(
            'Arrastra reportes críticos directamente a los perfiles de equipo para una respuesta inmediata.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _kTextGrey, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kPrimaryGreen),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ver cola de reportes',
                style: TextStyle(color: _kPrimaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _Miembro {
  final String nombre;
  final String rol;
  final String especialidad;
  const _Miembro(this.nombre, this.rol, this.especialidad);
}

class _Participante {
  final String nombre;
  final String departamento;
  final String estado;
  const _Participante(this.nombre, this.departamento, this.estado);
}
