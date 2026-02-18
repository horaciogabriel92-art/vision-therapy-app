import 'package:flutter/material.dart';
import 'package:vision_therapy_app/core/theme/app_theme.dart';

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final double progress; // 0.0 a 1.0 (animación de flujo de energía)

  PathPainter({required this.points, this.progress = 0});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
        // Curva Bezier simple para conectar suavemente
        final p1 = points[i];
        final p2 = points[i+1];
        
        // Control point (midpoint with offset logic could go here, but simple line for now)
        // path.quadraticBezierTo(...)
        path.lineTo(p2.dx, p2.dy);
    }

    // Dibujar camino base (apagado)
    canvas.drawPath(path, paint);

    // Dibujar camino activo (energía)
    // Esto requeriría lógica más compleja de path metrics, 
    // por ahora dibujamos una línea brillante simple
    final activePaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4); # Glow

    canvas.drawPath(path, activePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
