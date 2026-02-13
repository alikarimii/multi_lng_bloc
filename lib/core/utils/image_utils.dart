import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../constants/app_constants.dart';

class ImageUtils {
  const ImageUtils._();

  /// Resizes an image to fit within max dimensions while preserving aspect ratio.
  static Uint8List resizeForUpload(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    if (image.width <= AppConstants.maxImageWidth &&
        image.height <= AppConstants.maxImageHeight) {
      return bytes;
    }

    final resized = img.copyResize(
      image,
      width: image.width > AppConstants.maxImageWidth
          ? AppConstants.maxImageWidth
          : null,
      height: image.height > AppConstants.maxImageHeight
          ? AppConstants.maxImageHeight
          : null,
      maintainAspect: true,
    );

    return Uint8List.fromList(
      img.encodeJpg(resized, quality: AppConstants.imageQuality),
    );
  }

  /// Converts image to grayscale for preprocessing.
  static Uint8List toGrayscale(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    final grayscale = img.grayscale(image);
    return Uint8List.fromList(img.encodePng(grayscale));
  }
}
