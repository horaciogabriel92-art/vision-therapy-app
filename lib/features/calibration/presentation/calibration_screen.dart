import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vision_therapy_app/core/theme/app_theme.dart';
import 'package:vision_therapy_app/core/vision/vision_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final VisionService _vision = VisionService();
  String _statusMessage = "Alinea tu rostro en el centro";
  
  // Datos de calibración
  Face? _currentFace;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  void _startCamera() async {
    // Solicitar permisos en tiempo real (Crucial para Android 6.0+)
    var status = await Permission.camera.request();
    
    if (status.isPermanentlyDenied) {
        if (!mounted) return;
        // Si el usuario dijo "No volver a preguntar", lo mandamos a settings
        openAppSettings();
        return;
    }

    if (!status.isGranted) {
        if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Se necesita cámara para la terapia.")),
         );
         return;
    }

    await _vision.initialize();
    _vision.onFaceDetected = (Face face) {
      if (!mounted) return;
      setState(() {
        _currentFace = face;
        _evaluateCalibration(face);
      });
    };
    if (mounted) setState(() {});
  }

  void _evaluateCalibration(Face face) {
    // Verificar si el rostro está centrado (BoundingBox)
    // Coordenadas vienen del ML Kit (relativas a la imagen)
    // Por simplicidad, solo mostramos "Detectado" si existe.
    _statusMessage = "Rostro Detectado. Mantén la posición.";
  }

  @override
  Widget build(BuildContext context) {
    if (!_vision.isInitialized || _vision.cameraController == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_vision.cameraController!),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.6, 1.0],
                center: Alignment.center,
              ),
            ),
          ),
          CustomPaint(
            painter: FaceGuidePainter(
              faceDetected: _currentFace != null,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  _statusMessage.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _currentFace != null ? AppTheme.accent : AppTheme.danger,
                    shadows: [
                      Shadow(color: _currentFace != null ? AppTheme.accent : AppTheme.danger, blurRadius: 10)
                    ]
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_currentFace != null)
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CONFIRMAR CALIBRACIÓN"),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceGuidePainter extends CustomPainter {
  final bool faceDetected;

  FaceGuidePainter({required this.faceDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = faceDetected ? AppTheme.accent.withOpacity(0.5) : AppTheme.danger.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: 250, height: 350);
    canvas.drawOval(rect, paint);
    
    final eyeLevel = center.dy - 30;
    canvas.drawLine(
      Offset(center.dx - 100, eyeLevel), 
      Offset(center.dx + 100, eyeLevel), 
      paint..strokeWidth = 1
    );
  }

  @override
  bool shouldRepaint(covariant FaceGuidePainter oldDelegate) => oldDelegate.faceDetected != faceDetected;
}
