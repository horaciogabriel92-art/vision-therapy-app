import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/foundation.dart';

// Utilidades oficiales de Google ML Kit para convertir CameraImage
// Actualizado para google_mlkit_face_detection ^0.10.0 (InputImageMetadata)
class CameraUtils {
  static InputImage? convert(CameraImage image, CameraDescription camera) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation imageRotation = _rotationIntToImageRotation(camera.sensorOrientation);
    final InputImageFormat inputImageFormat = _inputImageFormat(image.format.group);

    // FIX: InputImageData -> InputImageMetadata
    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow, // Metadata simplificada en nuevas versiones
    );

    return InputImage.fromBytes(
      bytes: bytes, 
      metadata: inputImageMetadata, // FIX: parameter renamed from inputImageData
    );
  }

  static InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90: return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default: return InputImageRotation.rotation0deg;
    }
  }

  static InputImageFormat _inputImageFormat(ImageFormatGroup formatGroup) {
    switch (formatGroup) {
      case ImageFormatGroup.yuv420: return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888: return InputImageFormat.bgra8888;
      // Default fallback
      default: return InputImageFormat.yuv420;
    }
  }
}
