import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

// --- PUNTO DE ENTRADA PARA EJECUTAR LA PANTALLA ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Supabase con tus credenciales
  await Supabase.initialize(
    url: 'https://bhceqzmvnlepsynaxcqx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoY2Vxem12bmxlcHN5bmF4Y3F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NjAwMzQsImV4cCI6MjA5MDAzNjAzNH0.U_D2N9fXWTR1EDbmhbkEkyrKxlf1xsCE4FHota6ZrqU',
  );

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegistroUsuarios(),
    ),
  );
}

class RegistroUsuarios extends StatefulWidget {
  const RegistroUsuarios({super.key});

  @override
  State<RegistroUsuarios> createState() => _RegistroUsuariosState();
}

class _RegistroUsuariosState extends State<RegistroUsuarios> {
  // --- CONTROLADORES PARA EL REGISTRO ---
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1D3E3B),
              Color(0xFF2D5A56),
              Color(0xFF5A8F89),
              Color(0xFF3B6B66),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- CABECERA ---
                  const Text(
                    'NUEVO USUARIO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(
                    'REGISTRO DE USUARIOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- TARJETA RESPONSIVA ---
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(),
                          const SizedBox(height: 30),

                          // NOMBRE COMPLETO
                          _buildLabel("NOMBRE COMPLETO"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            Icons.person_outline,
                            "Ej. Jesus Del Angel",
                            controller: _nombreController,
                          ),
                          const SizedBox(height: 20),

                          // CORREO ELECTRÓNICO
                          _buildLabel("CORREO ELECTRÓNICO"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            Icons.mail_outline,
                            "correo@gmail.com",
                            controller: _emailController,
                          ),
                          const SizedBox(height: 20),

                          // CONTRASEÑA
                          _buildLabel("CONTRASEÑA"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            Icons.lock_outline,
                            "Mínimo 8 caracteres",
                            obscure: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 20),

                          // CONFIRMAR CONTRASEÑA
                          _buildLabel("CONFIRMAR CONTRASEÑA"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            Icons.shield_outlined,
                            "Repita su contraseña",
                            obscure: true,
                            controller: _confirmPasswordController,
                          ),
                          const SizedBox(height: 35),

                          // BOTÓN DE REGISTRO
                          _buildRegisterButton(context),
                          const SizedBox(height: 25),

                          // ENLACE A LOGIN
                          _buildFooterLink(
                            "¿Ya tienes acceso?",
                            "Iniciar Sesión",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  _buildSystemStatus(),
                  const SizedBox(height: 20),
                  _buildBottomLegal(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Nuevo Registro',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool obscure = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  void _showFloatingMessage(BuildContext context, String text, Color color) {
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
        elevation: 10,
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          final nombre = _nombreController.text.trim();
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          final confirmPassword = _confirmPasswordController.text.trim();

          // 1. Validar campos vacíos
          if (nombre.isEmpty ||
              email.isEmpty ||
              password.isEmpty ||
              confirmPassword.isEmpty) {
            _showFloatingMessage(
              context,
              'Por favor, complete todos los campos',
              Colors.redAccent,
            );
            return;
          }

          // 2. Validar que las contraseñas coincidan
          if (password != confirmPassword) {
            _showFloatingMessage(
              context,
              'Las contraseñas no coinciden',
              Colors.orange,
            );
            return;
          }

          // 3. Validar longitud de contraseña
          if (password.length < 6) {
            _showFloatingMessage(
              context,
              'La contraseña debe tener al menos 6 caracteres',
              Colors.orange,
            );
            return;
          }

          // 4. Obtener ubicación GPS actual
          double lat = 0.0;
          double lng = 0.0;

          try {
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              _showFloatingMessage(context, 'Por favor activa el GPS de tu dispositivo', Colors.orange);
              return;
            }

            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              // --- PANTALLA VISUAL / POP-UP DEL HACKATHON ---
              bool? allowLocation = await showDialog<bool>(
                context: context,
                barrierDismissible: false, // Obliga a tocar un botón
                builder: (BuildContext dContext) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFF004D40), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ubicación Requerida',
                            style: TextStyle(
                              color: Color(0xFF004D40),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'EcoAlert necesita formar un mapa inteligente contigo. Para completarlo, asignaremos tu registro a tu punto de origen en el campo de acción.\n\nPor favor, en la siguiente pantalla autoriza al sistema para usar tu GPS.',
                      style: TextStyle(height: 1.4, color: Colors.black87),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dContext, false),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004D40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('¡Entendido!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );

              if (allowLocation != true) {
                _showFloatingMessage(context, 'Registro cancelado: El mapa es requerido', Colors.orange);
                return;
              }
              // --- FIN PANTALLA VISUAL ---

              // Ahora sí, llamamos al permiso nativo, feo y gris de Android:
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied) {
                _showFloatingMessage(context, 'Permiso de ubicación denegado', Colors.redAccent);
                return;
              }
            }

            if (permission == LocationPermission.deniedForever) {
              _showFloatingMessage(context, 'Permisos denegados permanentemente', Colors.redAccent);
              return;
            }

            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
            );
            lat = position.latitude;
            lng = position.longitude;
          } catch (e) {
            _showFloatingMessage(context, 'Error al obtener ubicación', Colors.redAccent);
            return;
          }

          // 5. Intentar crear cuenta con Supabase
          try {
            _showFloatingMessage(
              context,
              'Ubicación lista. Procesando registro...',
              Colors.blueGrey,
            );

            final res = await Supabase.instance.client.auth.signUp(
              email: email,
              password: password,
              data: {
                'full_name': nombre,
              }, // Guardamos el nombre en los metadatos
            );

            if (res.user != null) {
              // 6. Guardar el perfil con coordenadas en tu propia tabla de base de datos
              await Supabase.instance.client.from('usuarios_comunes').insert({
                'id': res.user!.id,
                'nombre': nombre,
                'latitud': lat,
                'longitud': lng,
              });

              _showFloatingMessage(
                context,
                '¡Cuenta creada exitosamente y guardada en la base de datos!',
                const Color(0xFF004D40),
              );
              // Si pruebas la navegación, descomenta la siguiente línea:
              // Navigator.pop(context);
            }
          } on AuthException catch (e) {
            _showFloatingMessage(
              context,
              'Error al registrar: ${e.message}',
              Colors.redAccent,
            );
          } catch (e) {
            _showFloatingMessage(
              context,
              'Error en el sistema: $e',
              Colors.redAccent,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004D40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Registrar Usuario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.how_to_reg, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String normalText, String boldText) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Si lo estás corriendo aislado, Navigator.pop podría tirar un error porque no hay pantalla previa.
          // Por ahora solo mostraremos un mensaje en consola.
          print("Navegar al login");
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: RichText(
          text: TextSpan(
            text: '$normalText ',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            children: [
              TextSpan(
                text: boldText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sensors, size: 14, color: Colors.white54),
        SizedBox(width: 5),
        Text(
          'EOS-17 ESTABLE',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 25),
        Icon(Icons.dns, size: 14, color: Colors.white54),
        SizedBox(width: 5),
        Text(
          'NODO: LDN-04',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLegal() {
    return Column(
      children: [
        const Text(
          '© 2026 ADMINISTRACIÓN TÉCNICA. MONITOREO AMBIENTAL DE PRECISIÓN.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legalText('POLÍTICA DE PRIVACIDAD'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('•', style: TextStyle(color: Colors.white38)),
            ),
            _legalText('TÉRMINOS DE SERVICIO'),
          ],
        ),
      ],
    );
  }

  Widget _legalText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
