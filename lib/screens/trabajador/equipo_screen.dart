import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';

class EquipoScreen extends StatefulWidget {
  const EquipoScreen({super.key});

  @override
  State<EquipoScreen> createState() => _EquipoScreenState();
}

class _EquipoScreenState extends State<EquipoScreen> {
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
      // Get my org
      final persona = await _supabase.from('personas_apoyo').select('organizacion_id').eq('id', userId).maybeSingle();
      if (persona == null || persona['organizacion_id'] == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final orgId = persona['organizacion_id'];

      // Get all team members from same org
      final members = await _supabase.from('personas_apoyo').select().eq('organizacion_id', orgId);

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
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BRIGADA AMBIENTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mi Equipo', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('${_miembros.length} MIEMBROS', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)))
            else if (_miembros.isEmpty)
              _emptyState()
            else
              ..._miembros.map((m) => _memberCard(m)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 48),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
    child: Column(
      children: [
        Icon(Icons.groups_outlined, size: 48, color: AppColors.primary.withOpacity(0.15)),
        const SizedBox(height: 12),
        const Text('Sin miembros registrados', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textLight)),
      ],
    ),
  );

  Widget _memberCard(Map<String, dynamic> m) {
    final String name = m['nombre'] ?? 'Sin nombre';
    final String rol = m['rol'] ?? 'Técnico';
    final String estado = m['estado'] ?? 'ACTIVO';
    final bool isActive = estado == 'ACTIVO';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.bgMint,
            child: Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              Text(rol, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: isActive ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(estado, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isActive ? AppColors.success : Colors.grey)),
          ),
        ],
      ),
    );
  }
}
