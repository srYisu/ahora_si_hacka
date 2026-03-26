import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';

class DashboardTrabajadorScreen extends StatefulWidget {
  const DashboardTrabajadorScreen({super.key});

  @override
  State<DashboardTrabajadorScreen> createState() => _DashboardTrabajadorScreenState();
}

class _DashboardTrabajadorScreenState extends State<DashboardTrabajadorScreen> {
  final _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(31.3172, -113.5312);

  String _nombre = '';
  String _rol = '';
  int _tareasCount = 0;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initLocation();
  }

  Future<void> _loadData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final persona = await _supabase.from('personas_apoyo').select().eq('id', userId).maybeSingle();
    final tareas = await _supabase.from('tareas').select('id').eq('asignado_a', userId);

    if (mounted && persona != null) {
      setState(() {
        _nombre = persona['nombre'] ?? 'Ayudante';
        _rol = persona['rol'] ?? 'Técnico';
        _tareasCount = (tareas as List).length;
      });
    }
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (mounted) {
        setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 24),
            _statsRow(),
            const SizedBox(height: 24),
            _mapSection(),
            const SizedBox(height: 32),
            _tareasSection(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('PANEL DE CAMPO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 2)),
      const SizedBox(height: 4),
      Text('Hola, $_nombre', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
      const SizedBox(height: 2),
      Text('Rol: $_rol', style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
    ],
  );

  Widget _statsRow() => Row(
    children: [
      Expanded(child: _statCard('TAREAS', _tareasCount.toString(), Icons.assignment_outlined, AppColors.primary)),
      const SizedBox(width: 12),
      Expanded(child: _statCard('ESTADO', 'ACTIVO', Icons.check_circle_outline, AppColors.success)),
    ],
  );

  Widget _statCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 14),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1)),
      ],
    ),
  );

  Widget _mapSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Mapa de Incidencias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
      const SizedBox(height: 12),
      Container(
        height: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight, width: 2)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: _defaultCenter, initialZoom: 13),
                children: [
                  TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', subdomains: const ['a', 'b', 'c', 'd']),
                  MarkerLayer(markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 40, height: 40,
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                  ]),
                ],
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed, size: 12, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(_currentLocation != null ? 'GPS ACTIVO' : 'SIN GPS', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _tareasSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Tareas Asignadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
        child: Column(
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.primary.withOpacity(0.15)),
            const SizedBox(height: 12),
            const Text('No hay tareas asignadas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textLight)),
            const SizedBox(height: 4),
            const Text('Las tareas aparecerán aquí cuando sean asignadas.', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      ),
    ],
  );
}
