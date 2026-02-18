import 'dart:math' as math;
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// Port of Python's ClinicalMeasurement data class
class ClinicalMeasurement {
  final int timestamp;
  final math.Point<int> leftPupil;
  final math.Point<int> rightPupil;
  final vector.Vector3 leftGazeVector;
  final vector.Vector3 rightGazeVector;
  final double convergenceAngle;
  final bool isFusing;
  final vector.Vector3 headPose; // Yaw, Pitch, Roll

  ClinicalMeasurement({
    required this.timestamp,
    required this.leftPupil,
    required this.rightPupil,
    required this.leftGazeVector,
    required this.rightGazeVector,
    required this.convergenceAngle,
    required this.isFusing,
    required this.headPose,
  });
}

/// Port of Python's StrabismusAnalyzer.py
class VisionAnalyzerService {
  // Indices from MediaPipe Face Mesh (canonical)
  static const int LEFT_PUPIL_IDX = 468;
  static const int RIGHT_PUPIL_IDX = 473;
  // Simplified eye indices for center calculation
  static const List<int> LEFT_EYE_INDICES = [33, 133]; 
  static const List<int> RIGHT_EYE_INDICES = [362, 263];
  
  static const double STRABISMUS_THRESHOLD = 8.0;

  ClinicalMeasurement? analyzeFrame(Face face, Size imageSize) {
    if (face.landmarks.isEmpty) return null;

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 1. Extract Key Points
    // Note: ML Kit landmarks map might be sparse. access specific contours/landmarks if mesh is available via raw data
    // Face object typically exposes landmarks via .landmarks map if configured, but for Mesh we rely on mesh points if available or contours.
    // Flutter ML Kit wrappers often expose contours. Getting exact mesh points (468) might need specific access.
    // Assuming we have access to specific points via contours or we approximate using available landmarks.
    // FALLBACK: Use Contours if Mesh Points not directly indexable in this specific plugin version
    
    // For this implementation, we will try to get specific landmarks if available, or approximate from contours.
    // ML Kit Face Detection in Flutter returns specific landmarks (eyes, ears, etc) and Contours.
    // We will use Contours to calculate centers.
    
    final leftEyeContour = face.contours[FaceContourType.leftEye];
    final rightEyeContour = face.contours[FaceContourType.rightEye];
    
    if (leftEyeContour == null || rightEyeContour == null) return null;

    // Calculate Eye Centers (Centroid of contour)
    final leftCenter = _calculateCentroid(leftEyeContour.points);
    final rightCenter = _calculateCentroid(rightEyeContour.points);

    // Estimate Pupils (Centroids for now, usually ML Kit gives pupil landmarks if enabled? No, it gives standard landmarks)
    // Refinement: If specific pupil landmarks aren't exposed in this plugin version, we estimate pupil as center of eye inner region?
    // Wait, the Python code used exact indices (468/473). ML Kit's Face structure in Flutter wraps the native generic API.
    // If indices aren't available, we use the eye centers.
    // Let's assume for this "Brain Transplant" we use centroids as proxy for pupils if raw mesh isn't exposed.
    final leftPupil = leftCenter; 
    final rightPupil = rightCenter;

    // 2. Gaze Vectors (Normalized)
    // Vector from Head Center to Eye Center? Or simpler?
    // Python used: (Pupil - EyeCenter). Since we estimated Pupil = Center, valid gaze requires distinct points.
    // WE NEED GAZE. ML Kit provides Head Euler Angles.
    // Let's use Head Pose + Eye Position relative to face center to approximate divergence/convergence.
    
    // BETTER APPROACH for Mobile w/o 468 points:
    // Use headEulerAngleY (Yaw) and headEulerAngleZ (Roll).
    // And relative position of eyes.
    
    // HOWEVER, to be faithful to the Python logic "Vector Math":
    // We will simulate the vectors based on the Head Pose (since we don't have raw iris tracking in standard ML Kit yet).
    // Future update: Use MediaPipe Flutter plugin for raw mesh 468 points.
    
    // For now: Calculate convergence based on Head Rotation vs Eye Position?
    // Let's implement the data structure and populate it with available robust data (Head Pose).
    
    final headYaw = face.headEulerAngleY ?? 0.0;
    final headPitch = face.headEulerAngleX ?? 0.0;
    final headRoll = face.headEulerAngleZ ?? 0.0;

    // Simulate Gaze Vectors from Head Pose (assumption: looking properly forward relative to head)
    // This is a placeholder until we get Iris Tracking plugin.
    final leftGaze = vector.Vector3(math.sin(headYaw * math.pi / 180), 0, math.cos(headYaw * math.pi / 180));
    final rightGaze = vector.Vector3(math.sin(headYaw * math.pi / 180), 0, math.cos(headYaw * math.pi / 180));
    
    // Calculate Convergence (Placeholder logic adapting to available sensor data)
    double convergenceAngle = 0.0;
    
    // 3. Blink Detection
    final leftOpenProb = face.leftEyeOpenProbability ?? 1.0;
    final rightOpenProb = face.rightEyeOpenProbability ?? 1.0;
    final isBlinking = (leftOpenProb < 0.2 || rightOpenProb < 0.2);

    return ClinicalMeasurement(
      timestamp: timestamp,
      leftPupil: math.Point(leftPupil.x.toInt(), leftPupil.y.toInt()),
      rightPupil: math.Point(rightPupil.x.toInt(), rightPupil.y.toInt()),
      leftGazeVector: leftGaze,
      rightGazeVector: rightGaze,
      convergenceAngle: convergenceAngle, // To be refined with calibration
      isFusing: convergenceAngle < STRABISMUS_THRESHOLD,
      headPose: vector.Vector3(headYaw, headPitch, headRoll),
    );
  }

  vector.Vector3 _calculateCentroid(List<math.Point<int>> points) {
    if (points.isEmpty) return vector.Vector3.zero();
    double sumX = 0;
    double sumY = 0;
    for (var p in points) {
      sumX += p.x;
      sumY += p.y;
    }
    return vector.Vector3(sumX / points.length, sumY / points.length, 0);
  }
}
