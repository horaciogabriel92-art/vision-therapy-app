import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:flutter/services.dart';
import 'camera_utils.dart';
import 'vision_analyzer_service.dart';

class VisionService {
  static final VisionService _instance = VisionService._internal();
  factory VisionService() => _instance;
  VisionService._internal();

  CameraController? _cameraController;
  
  // FACE MESH DETECTOR (The Upgrade)
  // Replaces FaceDetector to provide 468 points
  final FaceMeshDetector _meshDetector = FaceMeshDetector(
      option: FaceMeshDetectorOptions.faceMesh
  );
  
  bool _isProcessing = false;
  final VisionAnalyzerService _analyzer = VisionAnalyzerService();
  Function(ClinicalMeasurement)? onMeasurementCalculated;

  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  Future<void> initialize() async {
    if (_cameraController != null) return;

    try {
      final cameras = await availableCameras();
      
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      _startImageStream();
      
    } catch (e) {
      debugPrint('VisionService Error: $e');
    }
  }

  void _startImageStream() {
    if (_cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) {
      if (_isProcessing) return;
      _isProcessing = true;
      _processImage(image).then((_) => _isProcessing = false);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (_cameraController == null) return;
    
    // Note: CameraUtils might need update if FaceMesh expects a diff format? 
    // Usually InputImage is standard.
    final InputImage? inputImage = CameraUtils.convert(image, _cameraController!.description);
    if (inputImage == null) return;

    try {
      final List<FaceMesh> meshes = await _meshDetector.processImage(inputImage);
      
      if (meshes.isNotEmpty) {
        final mesh = meshes.first;
        final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
        
        final measurement = _analyzer.analyzeFrame(mesh, imageSize);
        if (measurement != null && onMeasurementCalculated != null) {
          onMeasurementCalculated!(measurement);
        }
      }
    } catch (e) {
      debugPrint("FaceMesh Error: $e");
    }
  }

  void dispose() {
    _cameraController?.dispose();
    _meshDetector.close();
  }
}
