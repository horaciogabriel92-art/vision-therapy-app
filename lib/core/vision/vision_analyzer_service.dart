import 'dart:math' as math;
import 'dart:ui';
import 'package:google_mlkit_face_mesh/google_mlkit_face_mesh.dart';
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

class VisionAnalyzerService {
  // Canonical Face Mesh Indices
  static const int LEFT_IRIS_CENTER = 468;
  static const int RIGHT_IRIS_CENTER = 473;
  static const double STRABISMUS_THRESHOLD = 8.0;

  ClinicalMeasurement? analyzeFrame(FaceMesh mesh, Size imageSize) {
    // 1. Validate Mesh
    // We expect 468 points minimum.
    // In google_mlkit_face_mesh ^0.0.2+, the property is 'points'.
    // We access it directly. 
    
    // Note: If the plugin version is very new, it might use specific getters.
    // Based on standard usage:
    List<FaceMeshPoint> points = mesh.points;
    
    // Fallback/Safety
    if (points.isEmpty) return null;

    // 2. Extract Key Landmarks
    // Left Eye (33: Inner, 133: Outer, 468: Iris)
    final p33 = _getPoint(points, 33);
    final p133 = _getPoint(points, 133);
    final pLeftIris = _getPoint(points, 468);
    
    // Right Eye (362: Inner, 263: Outer, 473: Iris)
    final p362 = _getPoint(points, 362);
    final p263 = _getPoint(points, 263);
    final pRightIris = _getPoint(points, 473);

    // If we miss any crucial point (e.g. occlusion), abort
    if (p33 == null || p133 == null || pLeftIris == null || 
        p362 == null || p263 == null || pRightIris == null) {
      return null;
    }

    // 3. Coordinate Conversion
    // We use raw coordinates for vector calculation relative to eye center.
    final leftCenter = _midPoint(p33, p133);
    final rightCenter = _midPoint(p362, p263);
    
    // 4. Calculate Gaze Vectors (Iris relative to Eye Center)
    // Vector = Iris - Center
    final leftGazeRaw = vector.Vector3(
      (pLeftIris.x - leftCenter.x).toDouble(),
      (pLeftIris.y - leftCenter.y).toDouble(),
      0 
    );
    
    final rightGazeRaw = vector.Vector3(
      (pRightIris.x - rightCenter.x).toDouble(),
      (pRightIris.y - rightCenter.y).toDouble(),
      0
    );
    
    // Normalize Vectors
    final leftGaze = leftGazeRaw.normalized();
    final rightGaze = rightGazeRaw.normalized();
    
    // 5. Calculate Convergence Angle (Simplified horizontal disparity)
    // Positive = Crossed (Esotropia), Negative = Divergent (Exotropia)
    // Scale factor 100 is empirical to map pixel-disparity to rough degrees.
    // Needs calibration offset in real usage.
    double rawConvergence = (leftGaze.x - rightGaze.x) * 100; 

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return ClinicalMeasurement(
       timestamp: timestamp,
       leftPupil: math.Point(pLeftIris.x.toInt(), pLeftIris.y.toInt()),
       rightPupil: math.Point(pRightIris.x.toInt(), pRightIris.y.toInt()),
       leftGazeVector: leftGaze,
       rightGazeVector: rightGaze,
       convergenceAngle: rawConvergence,
       isFusing: rawConvergence.abs() < STRABISMUS_THRESHOLD,
       headPose: vector.Vector3(0,0,0) // FaceMesh implies head pose but requires PnP solver
    );
  }

  // Helpers
  FaceMeshPoint? _getPoint(List<FaceMeshPoint> points, int index) {
    if (index < points.length && points[index].index == index) {
      return points[index];
    }
    // Search path (safe)
    try {
      return points.firstWhere((p) => p.index == index);
    } catch (e) {
      return null;
    }
  }

  math.Point<double> _midPoint(FaceMeshPoint a, FaceMeshPoint b) {
    return math.Point<double>(
      (a.x + b.x) / 2,
      (a.y + b.y) / 2
    );
  }
}
