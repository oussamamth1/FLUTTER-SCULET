import 'dart:typed_data';
import 'package:image/image.dart' as img;

Future<Uint8List> _circleCrop(Uint8List imageBytes, {int size = 200}) async {
  // Decode the image
  img.Image? original = img.decodeImage(imageBytes);
  if (original == null) throw Exception("Failed to decode image");

  // Resize to a square
  img.Image resized = img.copyResizeCropSquare(original, size: size);

  // Create a new transparent canvas
  final circleImage = img.Image(width: size, height: size);
  circleImage.clear(img.ColorUint8(0)); // transparent background

  final centerX = size ~/ 2;
  final centerY = size ~/ 2;
  final radius = size ~/ 2;

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      if (dx * dx + dy * dy <= radius * radius) {
        // keep pixel
        circleImage.setPixel(x, y, resized.getPixel(x, y));
      } else {
        // transparent
        circleImage.setPixel(x, y, img.ColorUint8(0));
      }
    }
  }

  // Encode to PNG (keeps transparency)
  return Uint8List.fromList(img.encodePng(circleImage));
}
