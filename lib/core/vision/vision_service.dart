import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart';
import 'camera_utils.dart';
import 'vision_analyzer_service.dart';

class VisionService {
  static final VisionService _instance = VisionService._internal();
  factory VisionService() => _instance;
  VisionService._internal();

  CameraController? _cameraController;
  // Face Detection (con Contours/Landmarks activados)
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true, // Para ojos abiertos/cerrados
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  
  bool _isProcessing = false;
  final VisionAnalyzerService _analyzer = VisionAnalyzerService();
  Function(ClinicalMeasurement)? onMeasurementCalculated;

  Future<void> _processImage(CameraImage image) async {
    if (_cameraController == null) return;
    
    final InputImage? inputImage = CameraUtils.convert(image, _cameraController!.description);
    if (inputImage == null) return;

    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isNotEmpty) {
        final face = faces.first;
        final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
        
        final measurement = _analyzer.analyzeFrame(face, imageSize);
        if (measurement != null && onMeasurementCalculated != null) {
          onMeasurementCalculated!(measurement);
        }
      }
    } catch (e) {
      debugPrint("FaceDetection Error: $e");
    }
  }

  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
  }
}
