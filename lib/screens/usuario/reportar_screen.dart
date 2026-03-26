import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../core/app_theme.dart';

class ReportarScreen extends StatefulWidget {
  const ReportarScreen({super.key});
  @override
  State<ReportarScreen> createState() => _ReportarScreenState();
}

class _ReportarScreenState extends State<ReportarScreen> {
  int _selectedWasteType = -1;
  final _descCtrl = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  String _priority = 'MEDIA';
  
  // ML Kit setup
  late ImageLabeler _labeler;

  // --- MAPA VARIABLES ---
  final MapController _mapController = MapController();
  LatLng _currentPos = const LatLng(19.4326, -99.1332);
  String _currentAddress = 'Ubicando...';
  bool _isSearching = false;
  bool _isLoadingLocation = true;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
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
        final newPos = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPos = newPos;
          _currentLocation = newPos;
          _isLoadingLocation = false;
        });
        _mapController.move(newPos, 14);
        _updateAddressFromMap(newPos);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _updateAddressFromMap(LatLng position) async {
    setState(() {
      _isSearching = true;
      _currentPos = position;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'PrecisionConservatorApp'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addr = data['address'] ?? {};

        if (!mounted) return;
        setState(() {
          final road = addr['road'] ?? '';
          final houseNumber = addr['house_number'] ?? '';
          final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? '';
          _currentAddress = "$road $houseNumber, $city".trim();
          if (_currentAddress == ',' || _currentAddress.isEmpty) {
              _currentAddress = data['display_name'] ?? 'Ubicación desconocida';
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _currentAddress = 'Error al ubicar');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _labeler.close();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => _selectedImage = file);
      _analyzeImageWithAI(file);
    }
  }

  bool _hasMatch(String text, List<String> keywords) {
    for (var k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  Future<void> _analyzeImageWithAI(File image) async {
    final inputImage = InputImage.fromFile(image);
    final labels = await _labeler.processImage(inputImage);
    
    String description = "Detectado: ";
    int suggestedType = -1;

    for (ImageLabel label in labels) {
      final text = label.label.toLowerCase();
      description += "${label.label} (${(label.confidence * 100).toStringAsFixed(0)}%), ";
      
      if (suggestedType == -1) {
        // AI Logic based on ML Kit labels
        if (_hasMatch(text, ['food', 'fruit', 'vegetable', 'plant', 'organism', 'leaf', 'wood', 'grass', 'compost', 'seed'])) {
          suggestedType = 3; // Orgánico
        } else if (_hasMatch(text, ['plastic', 'bottle', 'can', 'waste', 'trash', 'paper', 'metal', 'glass', 'garbage', 'debris', 'tin', 'box', 'aluminum', 'gadget', 'device', 'electronic'])) {
          suggestedType = 0; // Sólido
        } else if (_hasMatch(text, ['liquid', 'water', 'oil', 'fluid', 'beverage', 'gasoline', 'paint', 'cleaning'])) {
          suggestedType = 1; // Líquido
        } else if (_hasMatch(text, ['chemical', 'battery', 'drug', 'hazard', 'toxic', 'poison', 'medicine', 'explosion', 'cell', 'accumulator', 'powerbank', 'nuclear', 'acid'])) {
          suggestedType = 2; // Peligroso
        }
      }
    }

    if (mounted) {
      setState(() {
        if (suggestedType != -1) _selectedWasteType = suggestedType;
        _descCtrl.text = description;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_selectedImage == null || _selectedWasteType == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, agregue una imagen y seleccione el tipo de residuo')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Upload image
      final fileExt = _selectedImage!.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName';

      await supabase.storage.from('reportes').upload(
        filePath,
        _selectedImage!,
      );

      final imageUrl = supabase.storage.from('reportes').getPublicUrl(filePath);

      // 2. Insert record
      final wasteTypes = ['SÓLIDO', 'LÍQUIDO', 'PELIGROSO', 'ORGÁNICO'];
      
      await supabase.from('reportes').insert({
        'usuario_id': userId,
        'imagen_url': imageUrl,
        'tipo_residuo': wasteTypes[_selectedWasteType],
        'descripcion': _descCtrl.text,
        'prioridad': _priority,
        'latitud': _currentPos.latitude,
        'longitud': _currentPos.longitude,
        'estado': 'PENDIENTE',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte enviado con éxito')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error submitting report: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el reporte')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const Text(
                  'Reportar Contaminación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PROTOCOLO ACTIVO',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // FASE 01
          _phaseCard(
            'FASE 01',
            'Subir Evidencia',
            Column(
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: AppColors.primaryTeal,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Agregar Imagen',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG, PNG (Max 10MB)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Abrir Cámara'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // PRIORIDAD
          _phaseCard(
            'EXTRA',
            'Prioridad del Reporte',
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'BAJA', label: Text('Baja'), icon: Icon(Icons.low_priority)),
                  ButtonSegment(value: 'MEDIA', label: Text('Media'), icon: Icon(Icons.priority_high)),
                  ButtonSegment(value: 'ALTA', label: Text('Alta'), icon: Icon(Icons.error_outline)),
                ],
                selected: {_priority},
                onSelectionChanged: (newSelection) {
                  setState(() => _priority = newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primaryTeal,
                  selectedForegroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // FASE 02
          _phaseCard(
            'FASE 02',
            'Tipo de Residuo',
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _wasteChip(0, Icons.recycling, 'Sólido')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _wasteChip(
                          1,
                          Icons.water_drop_outlined,
                          'Líquido',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _wasteChip(
                          2,
                          Icons.warning_amber_rounded,
                          'Peligroso',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _wasteChip(3, Icons.eco_outlined, 'Orgánico'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // FASE 03
          _phaseCard(
            'FASE 03',
            'Geolocalización',
            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryTeal, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentPos,
                            initialZoom: 14,
                            onMapEvent: (event) {
                              if (event is MapEventMoveEnd && event.source != MapEventSource.custom) {
                                _updateAddressFromMap(event.camera.center);
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                              subdomains: const ['a', 'b', 'c', 'd'],
                            ),
                          ],
                        ),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 35),
                            child: Icon(Icons.location_on, color: AppColors.danger, size: 40),
                          ),
                        ),
                        if (_isSearching)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
                              ),
                              child: const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'UBICACIÓN MAPA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentAddress,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Precisión de GPS: Alta',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: _gpsBadgeStatus(),
          ),
          const SizedBox(height: 12),

          // FASE 04
          _phaseCard(
            'FASE 04',
            'Descripción del Reporte',
            Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describa los hallazgos ambientales...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                    filled: true,
                    fillColor: AppColors.bgMint,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryTeal,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: const Text(
                        'Este reporte será validado por el equipo técnico en un plazo máximo de 2 horas.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _submitReport,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(_isUploading ? 'ENVIANDO...' : 'ENVIAR REPORTE AMBIENTAL'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Footer
          Center(
            child: const Text(
              'PRECISION CONSERVATOR V4.2.0',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wasteChip(int index, IconData icon, String label) {
    final sel = index == _selectedWasteType;
    return GestureDetector(
      onTap: () => setState(() => _selectedWasteType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: sel ? AppColors.bgMint : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? AppColors.primaryTeal : AppColors.borderLight,
            width: sel ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.primaryTeal.withValues(alpha: 0.1)
                    : AppColors.bgLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: sel
                    ? AppColors.primaryTeal
                    : (index == 2 ? AppColors.danger : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? AppColors.primaryTeal : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gpsBadgeStatus() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _currentLocation != null ? AppColors.primaryGreen : Colors.orange, 
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
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
  );

  Widget _phaseCard(
    String phase,
    String title,
    Widget child, {
    Widget? trailing,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              phase,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        child,
      ],
    ),
  );
}
