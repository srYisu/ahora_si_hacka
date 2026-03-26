import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _miembros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Get my org ID
      final org = await _supabase
          .from('organizaciones')
          .select('id')
          .eq('auth_user_id', userId)
          .maybeSingle();

      if (org == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final orgId = org['id'];

      // Get all personas_apoyo from that org
      final members = await _supabase
          .from('personas_apoyo')
          .select()
          .eq('organizacion_id', orgId);

      if (mounted) {
        setState(() {
          _miembros = List<Map<String, dynamic>>.from(members);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          _buildMembersSection(),
          const SizedBox(height: 24),
          _buildZoneMap(),
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
                  const Text(
                    'Gestión de Equipos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coordina las fuerzas operativas en campo y monitorea el impacto colectivo.',
                    style: TextStyle(fontSize: 14, color: _kTextGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _kPrimaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_miembros.length} MIEMBROS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _kPrimaryGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            'MIEMBROS DEL EQUIPO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _kTextGrey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: _kPrimaryGreen),
              ),
            )
          else if (_miembros.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.groups_outlined, size: 48, color: _kPrimaryGreen.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  const Text(
                    'Sin miembros registrados',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextGrey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Los ayudantes aparecerán aquí cuando se registren con el código de tu organización.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: _kTextGrey),
                  ),
                ],
              ),
            )
          else
            ..._miembros.map((m) => _buildMemberTile(m)),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> m) {
    final String nombre = m['nombre'] ?? 'Sin nombre';
    final String rol = m['rol'] ?? 'Técnico';
    final String estado = m['estado'] ?? 'ACTIVO';
    final String email = m['email'] ?? '';
    final bool isActive = estado == 'ACTIVO';

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
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _kTextDark,
                  ),
                ),
                Text(
                  '$rol • $email',
                  style: const TextStyle(fontSize: 12, color: _kTextGrey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              estado,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.green : Colors.grey,
              ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(31.3172, -113.5312),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mapa de Zonas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_miembros.length} miembros asignados',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
