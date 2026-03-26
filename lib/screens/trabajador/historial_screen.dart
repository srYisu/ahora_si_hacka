import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(31.3172, -113.5312);

  int _totalTareas = 0;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _initLocation();
  }

  Future<void> _loadStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    final tareas = await _supabase.from('tareas').select('id').eq('asignado_a', userId);
    if (mounted) setState(() => _totalTareas = (tareas as List).length);
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (mounted) setState(() => _currentLocation = LatLng(pos.latitude, pos.longitude));
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
            const Text('RESUMEN OPERATIVO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 4),
            const Text('Historial', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
            const SizedBox(height: 24),
            _statsCards(),
            const SizedBox(height: 32),
            const Text('Contexto Geográfico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
            const SizedBox(height: 12),
            _mapArea(),
            const SizedBox(height: 32),
            const Text('Tareas Asignadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
            const SizedBox(height: 16),
            _emptyTasks(),
          ],
        ),
      ),
    );
  }

  Widget _statsCards() => Row(
    children: [
      Expanded(child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 28),
            const SizedBox(height: 14),
            Text('$_totalTareas', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            Text('ASIGNACIONES', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ],
        ),
      )),
      const SizedBox(width: 12),
      Expanded(child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.eco, color: AppColors.primary, size: 28),
            const SizedBox(height: 14),
            const Text('--', style: TextStyle(color: AppColors.primaryDark, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('IMPACTO', style: TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ],
        ),
      )),
    ],
  );

  Widget _mapArea() => Container(
    height: 180,
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
                    point: _currentLocation!, width: 40, height: 40,
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
              ]),
            ],
          ),
          Positioned(
            bottom: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Text('Puerto Peñasco, Sonora', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyTasks() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 48),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
    child: Column(
      children: [
        Icon(Icons.history_rounded, size: 48, color: AppColors.primary.withOpacity(0.15)),
        const SizedBox(height: 12),
        const Text('No hay tareas asignadas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textLight)),
        const SizedBox(height: 4),
        const Text('El historial se llenará conforme completes tareas.', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
      ],
    ),
  );
}
