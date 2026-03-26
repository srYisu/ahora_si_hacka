import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// --- COLORES BASADOS EN EL DISEÑO ---
const Color kSidebarDark = Color(0xFF0A3A32);
const Color kBgColor = Color(0xFFE8F8F5);
const Color kPrimaryGreen = Color(0xFF1B5E55);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextGrey = Color(0xFF757575);

// --- PUNTO DE ENTRADA PARA EJECUTAR LA PANTALLA ---
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardEntidades(),
    ),
  );
}

class DashboardEntidades extends StatefulWidget {
  const DashboardEntidades({super.key});

  @override
  State<DashboardEntidades> createState() => _DashboardEntidadesState();
}

class _DashboardEntidadesState extends State<DashboardEntidades> {
  final MapController _mapController = MapController();
  final LatLng _centerLocation = const LatLng(
    19.4326,
    -99.1332,
  ); // CDMX por defecto

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: kBgColor,
      body: Row(
        children: [
          // SIDEBAR (Fijo a la izquierda en Desktop)
          if (isDesktop) _buildSidebar(),

          // CONTENIDO PRINCIPAL
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        // SECCIÓN MEDIA: MAPA Y GRÁFICO
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildMapSection()),
                              const SizedBox(width: 24),
                              Expanded(flex: 1, child: _buildChartSection()),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildMapSection(),
                              const SizedBox(height: 24),
                              _buildChartSection(),
                            ],
                          ),
                        const SizedBox(height: 24),
                        _buildReportsTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGETS DEL LAYOUT PRINCIPAL
  // ==========================================

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: kSidebarDark,
      child: Column(
        children: [
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
                      'EcoAlert',
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
          _buildSidebarItem(Icons.dashboard, 'DASHBOARD', isSelected: true),
          _buildSidebarItem(Icons.insert_chart_outlined, 'REPORTES'),
          _buildSidebarItem(Icons.people_outline, 'GESTIÓN DE EQUIPO'),
          _buildSidebarItem(Icons.settings_outlined, 'CONFIGURACIÓN'),
          const Spacer(),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Alex Rivera',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Supervisor Senior',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title, {
    bool isSelected = false,
  }) {
    return Container(
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
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: kBgColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar reportes o zonas...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_none, color: kTextDark),
          const SizedBox(width: 15),
          const Icon(Icons.help_outline, color: kTextDark),
          const SizedBox(width: 20),
          const Text(
            'ECOALERT ENTERPRISE',
            style: TextStyle(fontWeight: FontWeight.bold, color: kTextDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VISIÓN GENERAL',
          style: TextStyle(color: kTextGrey, fontSize: 12, letterSpacing: 1.2),
        ),
        SizedBox(height: 5),
        Text(
          'Estado de la Red Sanitaria',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kTextDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'PENDIENTES',
            '24',
            '+12% vs ayer',
            Icons.warning_amber_rounded,
            Colors.red,
            'CRÍTICO',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildMetricCard(
            'EN PROCESO',
            '18',
            'Estable',
            Icons.pending_actions,
            Colors.blueGrey,
            'EN CURSO',
            isStable: true,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildMetricCard(
            'RESUELTOS',
            '142',
            '+8% semanal',
            Icons.check_circle_outline,
            Colors.green,
            'OPTIMIZADO',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 140, // <-- AUMENTADO A 140
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSidebarDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.groups, color: Colors.white54),
                Text(
                  '09',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    String badgeText, {
    bool isStable = false,
  }) {
    return Container(
      height: 140, // <-- AUMENTADO A 140
      padding: const EdgeInsets.all(
        16,
      ), // Un poco menos de padding para dar respiro al texto
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: kTextGrey, fontSize: 12),
              ),
              const SizedBox(height: 4), // Separación extra de seguridad
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Envolvemos el subtítulo en Expanded para evitar desbordes horizontales
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isStable ? kTextGrey : color,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Si no cabe, pone "..."
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAPA Y GRÁFICO
  // ==========================================

  Widget _buildMapSection() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.map, color: kTextDark),
                    SizedBox(width: 10),
                    Text(
                      'Mapa de Incidencias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLegendItem('Pendiente', Colors.red),
                    _buildLegendItem('En Proceso', Colors.blueGrey),
                    _buildLegendItem('Resuelto', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _centerLocation,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  MarkerLayer(
                    markers: [
                      // Marcadores simulados
                      Marker(
                        point: const LatLng(19.4326, -99.1332),
                        width: 15,
                        height: 15,
                        child: _buildDot(Colors.red),
                      ),
                      Marker(
                        point: const LatLng(19.4400, -99.1400),
                        width: 15,
                        height: 15,
                        child: _buildDot(Colors.blueGrey),
                      ),
                      Marker(
                        point: const LatLng(19.4200, -99.1200),
                        width: 15,
                        height: 15,
                        child: _buildDot(Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: kTextDark),
              SizedBox(width: 10),
              Text(
                'Composición de\nResiduos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Distribución porcentual por categoría',
            style: TextStyle(fontSize: 12, color: kTextGrey),
          ),
          const SizedBox(height: 20),

          // Gráfico Circular Custom (Simulado)
          Expanded(
            child: Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(painter: MockPieChartPainter()),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Leyendas de la gráfica
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLegend('PLÁSTICOS', '45%', const Color(0xFF1B5E55)),
              _buildChartLegend('PAPEL', '25%', const Color(0xFF679E94)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLegend('ORGÁNICOS', '20%', const Color(0xFF4DB6AC)),
              _buildChartLegend('METALES', '10%', const Color(0xFFB2DFDB)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text(
                'DESCARGAR ANÁLISIS DETALLADO',
                style: TextStyle(color: kTextDark, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, String value, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: kTextDark,
          ),
        ),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontSize: 10, color: kTextGrey)),
      ],
    );
  }

  // ==========================================
  // TABLA DE REPORTES
  // ==========================================

  Widget _buildReportsTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos Reportes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16, color: kTextDark),
                label: const Text(
                  'Descargar CSV',
                  style: TextStyle(color: kTextDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Encabezado de la tabla
          const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'VISUAL',
                  style: TextStyle(
                    fontSize: 10,
                    color: kTextGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'TIPO DE RESIDUO',
                  style: TextStyle(
                    fontSize: 10,
                    color: kTextGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'UBICACIÓN',
                  style: TextStyle(
                    fontSize: 10,
                    color: kTextGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'FECHA',
                  style: TextStyle(
                    fontSize: 10,
                    color: kTextGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'ESTADO',
                  style: TextStyle(
                    fontSize: 10,
                    color: kTextGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ACCIÓN',
                    style: TextStyle(
                      fontSize: 10,
                      color: kTextGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          // Filas simuladas
          _buildTableRow(
            Colors.grey[300]!,
            'Plásticos/Vidrio',
            'Volumen: Grande',
            'Calle Reforma #452, Col. Centro',
            'Hoy, 08:45 AM',
            'Pendiente',
            Colors.red,
          ),
          const Divider(height: 30),
          _buildTableRow(
            Colors.green[200]!,
            'Residuos Orgánicos',
            'Volumen: Medio',
            'Av. Chapultepec #12, Sur',
            'Ayer, 04:20 PM',
            'En Proceso',
            Colors.blueGrey,
          ),
          const Divider(height: 30),
          _buildTableRow(
            Colors.brown[200]!,
            'Papel/Cartón',
            'Volumen: Masivo',
            'Zona Industrial, Andén 4',
            '12 Oct, 11:30 AM',
            'Resuelto',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    Color imageColor,
    String title,
    String subtitle,
    String location,
    String date,
    String status,
    Color statusColor,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 40,
            width: 40,
            alignment: Alignment.centerLeft,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: imageColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: kTextGrey),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            location,
            style: const TextStyle(color: kTextGrey, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            date,
            style: const TextStyle(color: kTextGrey, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kSidebarDark,
                minimumSize: const Size(80, 30),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Ver Detalles',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// PINTOR PARA EL GRÁFICO CIRCULAR (SIN DEPENDENCIAS)
// ==========================================
class MockPieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()..style = PaintingStyle.fill;

    // Plásticos (45%)
    paint.color = const Color(0xFF1B5E55);
    canvas.drawArc(rect, -1.57, 2.8, true, paint); // -90 grados de inicio

    // Papel (25%)
    paint.color = const Color(0xFF679E94);
    canvas.drawArc(rect, 1.23, 1.57, true, paint);

    // Orgánicos (20%)
    paint.color = const Color(0xFF4DB6AC);
    canvas.drawArc(rect, 2.8, 1.25, true, paint);

    // Metales (10%)
    paint.color = const Color(0xFFB2DFDB);
    canvas.drawArc(rect, 4.05, 0.66, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
