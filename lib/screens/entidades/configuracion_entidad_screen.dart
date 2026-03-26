import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../InicioSesion2.dart';

const Color _kSidebarDark = Color(0xFF0A3A32);
const Color _kPrimaryGreen = Color(0xFF1B5E55);
const Color _kTextDark = Color(0xFF1A1A1A);
const Color _kTextGrey = Color(0xFF757575);

class ConfiguracionEntidadScreen extends StatefulWidget {
  const ConfiguracionEntidadScreen({super.key});

  @override
  State<ConfiguracionEntidadScreen> createState() => _ConfiguracionEntidadScreenState();
}

class _ConfiguracionEntidadScreenState extends State<ConfiguracionEntidadScreen> {
  // Profile controllers
  final _nombreOrgController = TextEditingController();
  final _nitController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _nombreRespController = TextEditingController();
  final _cargoController = TextEditingController();

  // Security
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Preferences
  String _language = 'Español';
  String _timezone = 'America/Bogota (UTC-5)';

  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizacionData();
  }

  Future<void> _loadOrganizacionData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('organizaciones')
          .select()
          .eq('auth_user_id', userId)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _nombreOrgController.text = data['razon_social'] ?? '';
          _nitController.text = data['nit'] ?? '';
          _emailController.text = Supabase.instance.client.auth.currentUser?.email ?? '';
          _telefonoController.text = data['telefono'] ?? '';
          _direccionController.text = data['direccion'] ?? '';
          _ciudadController.text = data['ciudad'] ?? '';
          _nombreRespController.text = data['nombre_responsable'] ?? '';
          _cargoController.text = data['cargo'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _saveOrganizacionData() async {
    setState(() => _savingProfile = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('organizaciones')
          .update({
            'razon_social': _nombreOrgController.text.trim(),
            'nit': _nitController.text.trim(),
            'telefono': _telefonoController.text.trim(),
            'direccion': _direccionController.text.trim(),
            'ciudad': _ciudadController.text.trim(),
            'nombre_responsable': _nombreRespController.text.trim(),
            'cargo': _cargoController.text.trim(),
          })
          .eq('auth_user_id', userId);

      _showMessage('✅ Datos actualizados correctamente', Colors.green);
    } catch (e) {
      _showMessage('Error al guardar: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showMessage('Completa ambos campos de contraseña', Colors.orange);
      return;
    }
    if (newPass != confirmPass) {
      _showMessage('Las contraseñas no coinciden', Colors.redAccent);
      return;
    }

    setState(() => _changingPassword = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );
      _showMessage('✅ Contraseña actualizada correctamente', Colors.green);
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
    } catch (e) {
      _showMessage('Error al cambiar contraseña: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  void dispose() {
    _nombreOrgController.dispose();
    _nitController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _nombreRespController.dispose();
    _cargoController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (_loadingProfile) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _kPrimaryGreen),
            SizedBox(height: 16),
            Text('Cargando datos de la organización...', style: TextStyle(color: _kTextGrey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuración',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _kTextDark)),
          const SizedBox(height: 8),
          const Text('Administra el perfil de tu organización, seguridad y preferencias del sistema.',
              style: TextStyle(fontSize: 14, color: _kTextGrey)),
          const SizedBox(height: 32),

          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildLeftColumn()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildRightColumn()),
              ],
            )
          else
            Column(
              children: [
                _buildLeftColumn(),
                const SizedBox(height: 24),
                _buildRightColumn(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildProfileSection(),
        const SizedBox(height: 24),
        _buildSecuritySection(),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildPreferencesSection(),
        const SizedBox(height: 24),
        _buildDangerZone(),
      ],
    );
  }

  // ==========================================
  // PERFIL DE ORGANIZACIÓN
  // ==========================================

  Widget _buildProfileSection() {
    return _buildSectionCard(
      icon: Icons.business,
      title: 'Perfil de Organización',
      subtitle: 'Datos de tu entidad cargados desde la base de datos',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kPrimaryGreen.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.domain, size: 40, color: _kPrimaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Logo de la Organización',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _kTextDark)),
                    const SizedBox(height: 4),
                    const Text('PNG, JPG hasta 2MB', style: TextStyle(fontSize: 12, color: _kTextGrey)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload, size: 16),
                      label: const Text('Cambiar logo', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kPrimaryGreen,
                        side: const BorderSide(color: _kPrimaryGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInput('NOMBRE DE LA ORGANIZACIÓN', _nombreOrgController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('NIT / ID FISCAL', _nitController)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInput('NOMBRE RESPONSABLE', _nombreRespController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('CARGO', _cargoController)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInput('EMAIL DE CONTACTO', _emailController, enabled: false)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('TELÉFONO', _telefonoController)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInput('DIRECCIÓN', _direccionController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('CIUDAD', _ciudadController)),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _savingProfile ? null : _saveOrganizacionData,
              icon: _savingProfile
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save, size: 16, color: Colors.white),
              label: Text(
                _savingProfile ? 'Guardando...' : 'Guardar Cambios',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SEGURIDAD
  // ==========================================

  Widget _buildSecuritySection() {
    return _buildSectionCard(
      icon: Icons.shield,
      title: 'Seguridad',
      subtitle: 'Cambiar contraseña de acceso',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cambiar Contraseña',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _kTextDark)),
          const SizedBox(height: 12),
          _buildInput('CONTRASEÑA ACTUAL', _currentPassController, obscure: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInput('NUEVA CONTRASEÑA', _newPassController, obscure: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('CONFIRMAR CONTRASEÑA', _confirmPassController, obscure: true)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _changingPassword ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kSidebarDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _changingPassword
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Actualizar Contraseña', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PREFERENCIAS
  // ==========================================

  Widget _buildPreferencesSection() {
    return _buildSectionCard(
      icon: Icons.tune,
      title: 'Preferencias',
      subtitle: 'Personaliza tu experiencia',
      child: Column(
        children: [
          _buildPreferenceRow('Idioma', Icons.language,
              trailing: DropdownButton<String>(
                value: _language,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 13, color: _kTextDark),
                items: ['Español', 'English', 'Português']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _language = v!),
              )),
          const Divider(height: 20),
          _buildPreferenceRow('Zona Horaria', Icons.access_time,
              value: _timezone),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String label, IconData icon, {String? value, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kPrimaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kTextDark)),
                if (value != null)
                  Text(value, style: const TextStyle(fontSize: 11, color: _kTextGrey)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ==========================================
  // ZONA DE PELIGRO
  // ==========================================

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Zona de Peligro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text('¿Estás seguro de que deseas cerrar tu sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const InicioSesion2()),
                      (route) => false,
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showMessage('Contacta soporte para eliminar tu cuenta', Colors.red);
              },
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Eliminar Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: _kPrimaryGreen),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTextDark)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: _kTextGrey)),
                ],
              ),
            ],
          ),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool obscure = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextGrey, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? const Color(0xFFF5F5F5) : const Color(0xFFEEEEEE),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _showMessage(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      ),
    );
  }
}
