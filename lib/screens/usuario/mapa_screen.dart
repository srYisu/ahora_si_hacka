import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/app_theme.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Puerto Peñasco, Sonora coordinates
  final LatLng _penascoCenter = const LatLng(31.3172, -113.5312);
  final MapController _mapController = MapController();
  
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _centrarEnPenasco() {
    _mapController.move(_penascoCenter, 13.0);
  }

  void _centrarEnMi() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación no disponible aún'), backgroundColor: Colors.orange),
      );
    }
  }

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Mapa de Zonas\nMonitoreadas', 
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.my_location, color: AppColors.primaryTeal),
                  onPressed: _centrarEnMi,
                  tooltip: 'Mi ubicación',
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: AppColors.primaryTeal),
                  onPressed: _centrarEnPenasco,
                  tooltip: 'Ver Puerto Peñasco',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Visualización en tiempo real de zonas de monitoreo. (Región actual: Puerto Peñasco, Sonora)', 
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Map Box
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgCard, 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _penascoCenter,
                      initialZoom: 13.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ecoalert.app',
                      ),
                      MarkerLayer(
                        markers: [
                          // Zonas de Prueba en Puerto Peñasco
                          Marker(
                            point: const LatLng(31.3142, -113.5683), // Sandy Beach
                            width: 120,
                            height: 40,
                            child: const _MapZoneMarker('Costa Noroeste', AppColors.success),
                          ),
                          Marker(
                            point: const LatLng(31.3039, -113.5518), // Malecon
                            width: 120,
                            height: 40,
                            child: const _MapZoneMarker('Malecón Central', AppColors.warning),
                          ),
                          Marker(
                            point: const LatLng(31.2825, -113.5042), // Las Conchas
                            width: 120,
                            height: 40,
                            child: const _MapZoneMarker('Las Conchas', AppColors.primaryTeal),
                          ),

                          // GPS del usuario
                          if (_currentLocation != null)
                            Marker(
                              point: _currentLocation!,
                              width: 80,
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                    ),
                                    child: const Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 36)
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('TÚ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  
                  // GPS Status badge
                  Positioned(
                    top: 12, 
                    right: 12, 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _currentLocation != null ? AppColors.primaryGreen : Colors.orange, 
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          if (_isLoadingLocation)
                            const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          else
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                          
                          const SizedBox(width: 6),
                          Text(
                            _isLoadingLocation ? 'BUSCANDO GPS...' : (_currentLocation != null ? 'GPS ACTIVO' : 'SIN GPS'), 
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)
                          ),
                        ]
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MapZoneMarker extends StatelessWidget {
  final String label;
  final Color color;
  const _MapZoneMarker(this.label, this.color);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95), 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: color, width: 2), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)]
      ),
      child: Center(
        child: Text(
          label, 
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
