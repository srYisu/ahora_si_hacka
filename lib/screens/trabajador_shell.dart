import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'trabajador/dashboard_trabajador_screen.dart';
import 'trabajador/equipo_screen.dart';
import 'trabajador/historial_screen.dart';
import 'trabajador/perfil_trabajador_screen.dart';

class TrabajadorShell extends StatefulWidget {
  const TrabajadorShell({super.key});

  @override
  State<TrabajadorShell> createState() => _TrabajadorShellState();
}

class _TrabajadorShellState extends State<TrabajadorShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardTrabajadorScreen(),
    EquipoScreen(),
    HistorialScreen(),
    PerfilTrabajadorScreen(),
  ];

  static const List<({IconData icon, String label})> _navItems = [
    (icon: Icons.dashboard_outlined, label: 'TASKS'),
    (icon: Icons.people_outline, label: 'TEAM'),
    (icon: Icons.history_outlined, label: 'HISTORY'),
    (icon: Icons.person_outline, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = i == _selectedIndex;
                
                // Active team & history item icons change to filled versions for selected state? The designs say "TASKS, TEAM, HISTORY, PROFILE"
                // In image 1, TASKS is filled and background is dark teal for the tab.
                // Wait, based on the image, the active tab has a solid dark green background.
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: selected ? AppColors.textWhite : AppColors.textLight,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                              letterSpacing: 0.5,
                              color: selected ? AppColors.textWhite : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
