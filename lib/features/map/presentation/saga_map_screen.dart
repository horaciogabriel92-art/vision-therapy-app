import 'package:flutter/material.dart';
import 'package:vision_therapy_app/core/theme/app_theme.dart';
import 'package:vision_therapy_app/features/map/widgets/level_node.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vision_therapy_app/features/calibration/presentation/calibration_screen.dart';

class SagaMapScreen extends StatefulWidget {
  const SagaMapScreen({super.key});

  @override
  State<SagaMapScreen> createState() => _SagaMapScreenState();
}

class _SagaMapScreenState extends State<SagaMapScreen> {
  final ScrollController _scrollController = ScrollController();

  // Mock Data: Niveles y Posiciones
  // En producción esto vendría de una BBDD y un algoritmo de layout
  final List<Map<String, dynamic>> levels = [
    {'level': 1, 'status': NodeStatus.completed, 'icon': Icons.remove_red_eye, 'pos': const Offset(0.5, 0.9)},
    {'level': 2, 'status': NodeStatus.active, 'icon': Icons.bolt, 'pos': const Offset(0.2, 0.75)},
    {'level': 3, 'status': NodeStatus.unlocked, 'icon': Icons.api, 'pos': const Offset(0.8, 0.6)},
    {'level': 4, 'status': NodeStatus.locked, 'icon': Icons.link, 'pos': const Offset(0.5, 0.45)},
    {'level': 5, 'status': NodeStatus.locked, 'icon': Icons.speed, 'pos': const Offset(0.2, 0.3)},
    {'level': 6, 'status': NodeStatus.locked, 'icon': Icons.rocket_launch, 'pos': const Offset(0.8, 0.15)},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll al nivel activo después de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos altura total basada en "sectores"
    const double mapHeight = 1500; 
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("NEURO-VOYAGE"),
        backgroundColor: AppTheme.surfaceGlass,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/star_field_bg.png"), // Placeholder
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(AppTheme.background, BlendMode.darken)
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, AppTheme.background]
          )
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            height: mapHeight,
            child: Stack(
              children: [
                // 1. Path Line (Connections)
                CustomPaint(
                  size: const Size(double.infinity, mapHeight),
                  painter: _MapLinePainter(levels: levels, height: mapHeight),
                ),
                
                // 2. Nodes
                ...levels.map((lvl) {
                  return Positioned(
                    left: MediaQuery.of(context).size.width * (lvl['pos'] as Offset).dx - 40,
                    top: mapHeight * (lvl['pos'] as Offset).dy - 40,
                    child: LevelNode(
                      level: lvl['level'],
                      status: lvl['status'],
                      icon: lvl['icon'],
                      onTap: () {
                        if (lvl['level'] == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CalibrationScreen()),
                          );
                        } else {
                          // TODO: Implementar lógica de desbloqueo
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Nivel Bloqueado: Completa la calibración primero.")),
                          );
                        }
                      },
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                  );
                }),
                
                // 3. Floating Particles (Decoración)
                // TODO: Agregar partículas flotantes con Flame si da el tiempo
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Pintor simple para conectar nodos
class _MapLinePainter extends CustomPainter {
  final List<Map<String, dynamic>> levels;
  final double height;

  _MapLinePainter({required this.levels, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.primary.withColorOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Ordenar niveles por Y (Inverso porque dibujamos de abajo a arriba visualmente?)
    // En realidad 'levels' ya está ordenado por lógica 1..6
    
    // Conectar 1 -> 2 -> 3 ...
    for (int i = 0; i < levels.length - 1; i++) {
        final Offset p1 = levels[i]['pos'];
        final Offset p2 = levels[i+1]['pos'];
        
        final x1 = size.width * p1.dx;
        final y1 = height * p1.dy;
        final x2 = size.width * p2.dx;
        final y2 = height * p2.dy;
        
        if (i == 0) path.moveTo(x1, y1);
        path.lineTo(x2, y2);
    }

    canvas.drawPath(path, paint);
    
    // Glow Effect
    final glowPaint = Paint()
      ..color = AppTheme.primary.withColorOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension ColorOpacity on Color {
    Color withColorOpacity(double opacity) => withOpacity(opacity);
}
