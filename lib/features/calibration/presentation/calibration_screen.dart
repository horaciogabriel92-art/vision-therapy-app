import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vision_therapy_app/core/theme/app_theme.dart';
import 'package:vision_therapy_app/core/vision/vision_service.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'; // REMOVED
import 'package:permission_handler/permission_handler.dart';
import 'package:vision_therapy_app/core/vision/vision_analyzer_service.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_animate/flutter_animate.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> with SingleTickerProviderStateMixin {
  final VisionService _vision = VisionService();
  
  // Calibration State
  final List<String> steps = ["CENTER", "LEFT", "RIGHT", "UP", "DOWN"];
  int currentStepIndex = 0;
  DateTime? stepStartTime;
  bool isCalibrating = false;
  
  // Data Collection
  List<ClinicalMeasurement> _sessionMeasurements = [];
  Map<String, List<ClinicalMeasurement>> _results = {};
  ClinicalMeasurement? _lastMeasurement;
  
  // UI Animation
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: 1.seconds)..repeat(reverse: true);
    _startCamera();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startCamera() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
       if (!mounted) return;
       Navigator.pop(context);
       return;
    }

    await _vision.initialize();
    
    // Subscribe to Clinical Measurements (The "Brain")
    _vision.onMeasurementCalculated = (ClinicalMeasurement measurement) {
      if (!mounted) return;
      setState(() {
        _lastMeasurement = measurement;
        if (isCalibrating) {
            _processCalibrationStep(measurement);
        }
      });
    };
    
    if (mounted) setState(() {});
  }

  void _processCalibrationStep(ClinicalMeasurement measurement) {
      if (stepStartTime == null) {
          stepStartTime = DateTime.now();
          return;
      }
      
      final elapsed = DateTime.now().difference(stepStartTime!).inSeconds;
      final currentStep = steps[currentStepIndex];
      
      // Save data
      if (!_results.containsKey(currentStep)) _results[currentStep] = [];
      _results[currentStep]!.add(measurement);
      
      // Advance step after 5 seconds
      if (elapsed >= 5) {
          if (currentStepIndex < steps.length - 1) {
              currentStepIndex++;
              stepStartTime = DateTime.now();
          } else {
              _finishCalibration();
          }
      }
  }

  void _finishCalibration() {
      isCalibrating = false;
      // Calculate Diagnosis (Simple averaged convergence for now, mirroring Python logic)
      double avgConv = 0;
      if (_results.containsKey("CENTER")) {
          final centerData = _results["CENTER"]!;
          if (centerData.isNotEmpty) {
              avgConv = centerData.map((m) => m.convergenceAngle).reduce((a, b) => a + b) / centerData.length;
          }
      }
      
      String diagnosis = "ALIGNED";
      if (avgConv > 10) diagnosis = "ESOTROPIA DETECTED"; // Crossed
      if (avgConv < -5) diagnosis = "EXOTROPIA DETECTED"; // Divergent
      
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.surfaceGlass,
              title: const Text("DIAGNOSTIC REPORT", style: TextStyle(color: AppTheme.accent)),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Text("Baseline Convergence: ${avgConv.toStringAsFixed(1)}°", style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      Text(diagnosis, style: TextStyle(
                          color: diagnosis == "ALIGNED" ? AppTheme.accent : AppTheme.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )),
                  ],
              ),
              actions: [
                  TextButton(
                      onPressed: () {
                          Navigator.pop(ctx); // Close dialog
                          Navigator.pop(context); // Back to Map
                      }, 
                      child: const Text("SAVE PROFILE")
                  )
              ],
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    if (!_vision.isInitialized || _vision.cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // UI Layout based on state
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
            fit: StackFit.expand,
            children: [
                // 1. Camera Feed (Dimmed)
                Opacity(
                    opacity: 0.3,
                    child: CameraPreview(_vision.cameraController!),
                ),
                
                // 2. Target System
                if (!isCalibrating) 
                    _buildIntroUI()
                else 
                    _buildCalibrationTarget(),
                
                // 3. HUD Data
                Positioned(
                    bottom: 20,
                    left: 20,
                    child: _lastMeasurement != null ? Text(
                        "CONV: ${_lastMeasurement!.convergenceAngle.toStringAsFixed(1)}°",
                        style: const TextStyle(color: Colors.white54, fontFamily: 'Courier')
                    ) : const SizedBox()
                )
            ],
        )
    );
  }
  
  Widget _buildIntroUI() {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  const Icon(Icons.remove_red_eye, color: AppTheme.accent, size: 80),
                  const SizedBox(height: 20),
                  const Text("BIOMETRIC SCAN", style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  const Text("Mantenga la cabeza quieta\ny siga el punto con la mirada.", 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70)
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("INICIAR ESCANEO"),
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                      onPressed: () {
                          setState(() {
                              isCalibrating = true;
                              stepStartTime = DateTime.now();
                          });
                      },
                  )
              ],
          ),
      );
  }
  
  Widget _buildCalibrationTarget() {
      final currentStep = steps[currentStepIndex];
      // Map step to Alignment
      Alignment align = Alignment.center;
      switch(currentStep) {
          case "LEFT": align = const Alignment(-0.8, 0); break;
          case "RIGHT": align = const Alignment(0.8, 0); break;
          case "UP": align = const Alignment(0, -0.8); break;
          case "DOWN": align = const Alignment(0, 0.8); break;
      }
      
      return Align(
          alignment: align,
          child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                  return Container(
                      width: 60 + (_pulseController.value * 20),
                      height: 60 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.danger, width: 4),
                          boxShadow: [
                              BoxShadow(color: AppTheme.danger.withOpacity(0.5), blurRadius: 20)
                          ]
                      ),
                      child: Center(
                          child: Container(
                              width: 10, height: 10, 
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)
                          ),
                      ),
                  );
              }
          )
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
