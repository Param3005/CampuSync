import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

bool get isMobileWeb {
  if (!kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// Shows a dialog to pick image from camera or gallery.
/// Returns the picked file bytes, or null if cancelled.
Future<Uint8List?> pickFacePhoto(BuildContext context) async {
  final picker = ImagePicker();

  if (kIsWeb) {
    final XFile? picked = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capture Photo'),
        content: const Text('Select how you want to add your photo'),
        actions: [
          if (isMobileWeb)
            TextButton(
              onPressed: () async {
                final result = await picker.pickImage(
                  source: ImageSource.camera,
                  preferredCameraDevice: CameraDevice.front,
                );
                if (context.mounted) Navigator.pop(context, result);
              },
              child: const Text('Camera'),
            ),
          TextButton(
            onPressed: () async {
              final result = await picker.pickImage(source: ImageSource.gallery);
              if (context.mounted) Navigator.pop(context, result);
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  } else {
    // Native mobile — show bottom sheet
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    final picked = await picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  }
}

/// Compress and resize image for storage (max 512x512, JPEG 85%).
/// Returns compressed bytes. Falls back to original bytes on error.
Uint8List compressFacePhoto(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    // Resize if larger than 512x512
    img.Image resized;
    if (decoded.width > 512 || decoded.height > 512) {
      resized = img.copyResize(decoded, width: 512);
    } else {
      resized = decoded;
    }

    // Encode as JPEG at 85% quality
    final compressed = img.encodeJpg(resized, quality: 85);
    return Uint8List.fromList(compressed);
  } catch (e) {
    debugPrint('Image compression error: $e');
    return bytes;
  }
}

/// Data class for isolate computation.
class _CompareData {
  final Uint8List refBytes;
  final Uint8List newBytes;
  _CompareData(this.refBytes, this.newBytes);
}

/// Compute similarity in a background isolate.
double _compareInIsolate(_CompareData data) {
  try {
    final refImg = img.decodeImage(data.refBytes);
    final newImg = img.decodeImage(data.newBytes);

    if (refImg == null || newImg == null) {
      return 0.0;
    }

    // Resize to 64x64 for comparison
    final r1 = img.copyResize(refImg, width: 64, height: 64);
    final r2 = img.copyResize(newImg, width: 64, height: 64);

    // Convert to grayscale
    final g1 = img.grayscale(r1);
    final g2 = img.grayscale(r2);

    // Normal comparison
    final normalSim = _imageSimilarity(g1, g2);

    // Mirror-flipped comparison — create a copy first!
    final flippedG2 = img.copyResize(g2, width: 64, height: 64);
    img.flipHorizontal(flippedG2);
    final flippedSim = _imageSimilarity(g1, flippedG2);

    // Return the best match
    return normalSim > flippedSim ? normalSim : flippedSim;
  } catch (e) {
    debugPrint('Face compare error in isolate: $e');
    return 0.0;
  }
}

/// Compute similarity between two grayscale images (0-100).
double _imageSimilarity(img.Image a, img.Image b) {
  double totalDiff = 0;
  final pixelCount = a.width * a.height;

  for (int y = 0; y < a.height; y++) {
    for (int x = 0; x < a.width; x++) {
      totalDiff += (a.getPixel(x, y).r - b.getPixel(x, y).r).abs();
    }
  }

  final avgDiff = totalDiff / pixelCount;
  return ((1 - (avgDiff / 255)) * 100).clamp(0.0, 100.0);
}

/// Compare two images and return similarity percentage (0-100).
/// Also compares with the new image mirror-flipped, since front-facing
/// cameras produce mirrored selfies.
Future<double> compareFacePhotos(Uint8List refBytes, Uint8List newBytes) async {
  try {
    // Run heavy image processing in a background isolate
    return await compute(_compareInIsolate, _CompareData(refBytes, newBytes));
  } catch (e) {
    debugPrint('Face compare error: $e');
    return 0.0;
  }
}

/// Convert image bytes to base64 string.
String bytesToBase64(Uint8List bytes) => base64Encode(bytes);

/// Convert base64 string to image bytes.
Uint8List base64ToBytes(String base64Str) => base64Decode(base64Str);
