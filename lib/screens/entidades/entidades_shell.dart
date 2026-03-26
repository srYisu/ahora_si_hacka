import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_entidades_content.dart';
import 'reportes_entidad_screen.dart';
import 'gestion_equipos_screen.dart';
import 'configuracion_entidad_screen.dart';
import '../InicioSesion2.dart';

// --- COLORES DEL SIDEBAR ---
const Color kSidebarDark = Color(0xFF0A3A32);
const Color kBgColor = Color(0xFFE8F8F5);
const Color kPrimaryGreen = Color(0xFF1B5E55);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextGrey = Color(0xFF757575);

class EntidadesShell extends StatefulWidget {
  const EntidadesShell({super.key});

  @override
  State<EntidadesShell> createState() => _EntidadesShellState();
}

class _EntidadesShellState extends State<EntidadesShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardEntidadesContent(),
    ReportesEntidadScreen(),
    GestionEquiposScreen(),
    ConfiguracionEntidadScreen(),
  ];

  static const List<_SidebarItem> _navItems = [
    _SidebarItem(Icons.dashboard, 'DASHBOARD'),
    _SidebarItem(Icons.insert_chart_outlined, 'REPORTES'),
    _SidebarItem(Icons.people_outline, 'GESTIÓN DE EQUIPO'),
    _SidebarItem(Icons.settings_outlined, 'CONFIGURACIÓN'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: kBgColor,
      drawer: isDesktop ? null : _buildSidebarDrawer(),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDesktop),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarDrawer() {
    return Drawer(child: _buildSidebar());
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: kSidebarDark,
      child: Column(
        children: [
          // Logo
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              children: [
                Icon(Icons.eco, color: Colors.greenAccent, size: 30),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RILU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ENTERPRISE',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nav items
          ...List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            return _buildSidebarNavItem(
              item.icon,
              item.label,
              isSelected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            );
          }),

          const Spacer(),

          // User profile
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Admin Eco',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gestor de Operaciones',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const InicioSesion2(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white54,
                    size: 20,
                  ),
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(
    IconData icon,
    String title, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? Colors.black.withOpacity(0.2) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 22,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: kBgColor,
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: kTextDark),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: _getSearchHint(),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: kTextDark),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          const Icon(Icons.help_outline, color: kTextDark),
          const SizedBox(width: 20),
          const Row(
            children: [
              Text(
                'Admin Eco',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 5),
              Text(
                'GESTOR DE OPERACIONES',
                style: TextStyle(
                  color: kTextGrey,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF0A6847),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  String _getSearchHint() {
    switch (_selectedIndex) {
      case 0:
        return 'Buscar reportes o zonas...';
      case 1:
        return 'Buscar reportes...';
      case 2:
        return 'Buscar usuarios o equipos...';
      case 3:
        return 'Buscar configuración...';
      default:
        return 'Buscar...';
    }
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem(this.icon, this.label);
}
