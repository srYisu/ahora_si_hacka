import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:async'; // Necesario para el Timer
import 'package:http/http.dart' as http;

const Color kPrimaryColor = Color(0xFF004D40);
const Color kAccentColor = Color(0xFF00897B);
const Color kBgColor = Color(0xFFE0F2F1);
const Color kInputColor = Color(0xFFE8F5E9);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bhceqzmvnlepsynaxcqx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoY2Vxem12bmxlcHN5bmF4Y3F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NjAwMzQsImV4cCI6MjA5MDAzNjAzNH0.U_D2N9fXWTR1EDbmhbkEkyrKxlf1xsCE4FHota6ZrqU',
  );
  runApp(
    const MaterialApp(
      home: RegistroOrganizacion(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class RegistroOrganizacion extends StatefulWidget {
  const RegistroOrganizacion({super.key});
  @override
  State<RegistroOrganizacion> createState() => _RegistroOrganizacionState();
}

class _RegistroOrganizacionState extends State<RegistroOrganizacion> {
  // --- CONTROLADORES ---
  final TextEditingController _razonSocialController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController(
    text: 'Manufactura Pesada',
  );
  final TextEditingController _dir1Controller = TextEditingController();
  final TextEditingController _dir2Controller = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  // ... otros controladores
  final TextEditingController _latController = TextEditingController(
    text: "19.4326", //(México)
  );
  final TextEditingController _lngController = TextEditingController(
    text: "-99.1332", //(México)
  );

  final TextEditingController _nombreRespController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Controladores de Contraseña
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // --- NUEVAS VARIABLES PARA EL MAPA ---
  final MapController _mapController = MapController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en Dirección y Colonia
    _dir1Controller.addListener(_onAddressChanged);
    _dir2Controller.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _dir1Controller.removeListener(_onAddressChanged);
    _dir2Controller.removeListener(_onAddressChanged);
    _debounce?.cancel();
    super.dispose();
  }

  // Detecta cuando el usuario deja de escribir
  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _searchFromAddress();
    });
  }

  // --- LÓGICA DE BÚSQUEDA (Texto -> Mapa) ---
  Future<void> _searchFromAddress() async {
    final query =
        "${_dir1Controller.text} ${_dir2Controller.text} ${_ciudadController.text}"
            .trim();
    if (query.length < 5) return;

    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'EcoMonitorApp'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final newPos = LatLng(lat, lon);

          // Movemos el mapa a la nueva ubicación
          _mapController.move(newPos, 16);

          setState(() {
            _latController.text = lat.toStringAsFixed(6);
            _lngController.text = lon.toStringAsFixed(6);
          });
        }
      }
    } catch (e) {
      debugPrint("Error buscando dirección: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // --- LÓGICA DE REVERSA (Mapa -> Texto) ---
  Future<void> _updateAddressFromMap(LatLng position) async {
    setState(() {
      _isSearching = true;
      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'EcoMonitorApp'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addr = data['address'] ?? {};

        // Removemos temporalmente los listeners para evitar bucles infinitos
        _dir1Controller.removeListener(_onAddressChanged);
        _dir2Controller.removeListener(_onAddressChanged);

        setState(() {
          _dir1Controller.text =
              "${addr['road'] ?? ''} ${addr['house_number'] ?? ''}".trim();
          _dir2Controller.text =
              addr['neighbourhood'] ?? addr['suburb'] ?? addr['county'] ?? '';
          _ciudadController.text =
              addr['city'] ?? addr['town'] ?? addr['village'] ?? '';
        });

        // Re-activamos los listeners
        _dir1Controller.addListener(_onAddressChanged);
        _dir2Controller.addListener(_onAddressChanged);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? width * 0.05 : 20,
            vertical: 30,
          ),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildSidebar()),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _buildFormContent(isDesktop)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildSidebar(),
                    const SizedBox(height: 30),
                    _buildFormContent(isDesktop),
                  ],
                ),
              const SizedBox(height: 50),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(bool isDesktop) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Perfil',
          icon: Icons.business,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      'NOMBRE DE LA ORGANIZACIÓN/ENTIDAD',
                      'Ej: Industria S.A.',
                      controller: _razonSocialController,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildInput(
                      'NIT / ID FISCAL',
                      '900.000.000-1',
                      controller: _nitController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Ubicación',
          icon: Icons.location_on,
          child: Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- COLUMNA DE INPUTS ---
              Flexible(
                flex: isDesktop
                    ? 1
                    : 0, // Cambiamos a 1 para que ocupe el 50% del ancho
                child: Column(
                  children: [
                    _buildInput(
                      'DIRECCIÓN',
                      'Calle y número',
                      controller: _dir1Controller,
                    ),
                    const SizedBox(height: 15),
                    _buildInput(
                      'COLONIA',
                      'Apto/Barrio',
                      controller: _dir2Controller,
                    ),
                    const SizedBox(height: 15),
                    _buildInput('CIUDAD', '', controller: _ciudadController),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            'LATITUD',
                            '',
                            controller: _latController,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildInput(
                            'LONGITUD',
                            '',
                            controller: _lngController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- ESPACIADO DINÁMICO ---
              if (isDesktop)
                const SizedBox(width: 30)
              else
                const SizedBox(height: 20),

              // --- CONTENEDOR DEL MAPA (CON MARCO) ---
              Flexible(
                flex: isDesktop ? 1 : 0,
                child: Container(
                  height: isDesktop ? 400 : 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      14,
                    ), // Un poco más curvo por fuera
                    border: Border.all(
                      color:
                          kPrimaryColor, // Quitamos la transparencia para que resalte más
                      width: 5, // <-- AUMENTAMOS EL GROSOR AQUÍ (antes era 2)
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      9,
                    ), // Ajustado para que encaje perfecto dentro del nuevo marco
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: const LatLng(19.4326, -99.1332),
                            initialZoom: 14,
                            onMapEvent: (event) {
                              if (event is MapEventMoveEnd &&
                                  event.source != MapEventSource.custom) {
                                _updateAddressFromMap(event.camera.center);
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                              subdomains: const ['a', 'b', 'c', 'd'],
                            ),
                          ],
                        ),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 35),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                        if (_isSearching)
                          const Positioned(
                            top: 10,
                            right: 10,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Contacto',
          icon: Icons.contact_mail,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      'NOMBRE RESPONSABLE',
                      'Ej: Ing. Carlos',
                      controller: _nombreRespController,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildInput(
                      'CARGO',
                      'Director Técnico',
                      controller: _cargoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      'EMAIL',
                      'correo@empresa.com',
                      controller: _emailController,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildInput(
                      'TELÉFONO',
                      '+57 300...',
                      controller: _telefonoController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- NUEVO CARD DE SEGURIDAD ---
        _buildSectionCard(
          title: 'Seguridad',
          icon: Icons.lock,
          child: Row(
            children: [
              Expanded(
                child: _buildInput(
                  'CONTRASEÑA',
                  'Mínimo 8 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildInput(
                  'CONFIRMAR CONTRASEÑA',
                  'Repita la contraseña',
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        _buildSubmitButton(),
      ],
    );
  }

  // --- MÉTODOS HELPER ---
  void _showFloatingMessage(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hint, {
    bool isDropdown = false,
    bool obscureText = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: isDropdown,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
            filled: true,
            fillColor: kInputColor,
            suffixIcon: isDropdown
                ? const Icon(Icons.keyboard_arrow_down)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: kPrimaryColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () async {
          final password = _passwordController.text.trim();
          final confirm = _confirmPasswordController.text.trim();
          final email = _emailController.text.trim();

          if (email.isEmpty ||
              password.isEmpty ||
              _razonSocialController.text.trim().isEmpty) {
            _showFloatingMessage(
              'Revisa que los datos requeridos no estén vacíos.',
              Colors.orange,
            );
            return;
          }

          if (password != confirm) {
            _showFloatingMessage(
              'Las contraseñas no coinciden.',
              Colors.redAccent,
            );
            return;
          }

          try {
            _showFloatingMessage('Creando cuenta...', Colors.blueGrey);

            // 1. Crear la cuenta en Auth de Supabase
            final AuthResponse res = await Supabase.instance.client.auth.signUp(
              email: email,
              password: password,
            );

            if (res.user != null) {
              _showFloatingMessage(
                'Guardando perfil de la organización...',
                Colors.blueGrey,
              );

              // 2. Insertar los datos adicionales en tu tabla PÚBLICA (organizaciones)
              await Supabase.instance.client.from('organizaciones').insert({
                'auth_user_id':
                    res.user!.id, // Enlazamos el usuario a la base de datos
                'razon_social': _razonSocialController.text.trim(),
                'nit': _nitController.text.trim(),
                'direccion': _dir1Controller.text.trim(),
                'colonia': _dir2Controller.text.trim(),
                'ciudad': _ciudadController.text.trim(),
                'latitud': _latController.text.trim(),
                'longitud': _lngController.text.trim(),
                'nombre_responsable': _nombreRespController.text.trim(),
                'cargo': _cargoController.text.trim(),
                'telefono': _telefonoController.text.trim(),
              });

              _showFloatingMessage(
                '¡Registro exitoso! Cuenta lista.',
                const Color(0xFF004D40),
              );
              // TODO: Redirigir a ventana principal aquí, si gustas.
            }
          } on AuthException catch (e) {
            _showFloatingMessage(
              'Error al crear perfil de seguridad: ${e.message}',
              Colors.redAccent,
            );
          } catch (e) {
            _showFloatingMessage(
              'Error al guardar datos de la entidad: $e',
              Colors.redAccent,
            );
          }
        },
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: const Text(
          'FINALIZAR REGISTRO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.white,
    elevation: 1,
    title: const Text(
      'RILU',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    actions: [
      const Icon(Icons.notifications_none, color: Colors.black54),
      const SizedBox(width: 15),
      const CircleAvatar(
        radius: 15,
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.person, size: 18, color: Colors.white),
      ),
      const SizedBox(width: 15),
    ],
  );

  Widget _buildSidebar() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Registro de\nOrganización/Entidad',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
          height: 1.1,
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'Ingrese los datos técnicos y operativos para iniciar el monitoreo ambiental.',
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
      const SizedBox(height: 50),

      // --- NUEVO SÍMBOLO DE ORGANIZACIÓN ---
      Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: kAccentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.domain, // Icono de edificio/corporativo
            size: 120,
            color: kPrimaryColor,
          ),
        ),
      ),
    ],
  );

  Widget _buildInfoCard(IconData icon, String title, String subtitle) =>
      Container();

  Widget _buildFooter() => const Column(
    children: [
      Divider(),
      SizedBox(height: 20),
      Text(
        '© 2026 PRECISION CONSERVATOR ECOSYSTEMS. ALL RIGHTS RESERVED.',
        style: TextStyle(fontSize: 10, color: Colors.black38),
      ),
    ],
  );
}
