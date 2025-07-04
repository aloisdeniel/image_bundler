/// Fits the source image to the output size, maintaining aspect ratio.
({int width, int height}) fitSize(
  double sourceWidth,
  double sourceHeight,
  int outputWidth,
  int outputHeight,
) {
  if (outputWidth / outputHeight > sourceWidth / sourceHeight) {
    return (
      width: (sourceWidth * outputHeight / sourceHeight).toInt(),
      height: outputHeight,
    );
  }
  return (
    width: outputWidth,
    height: (sourceHeight * outputWidth / sourceWidth).toInt(),
  );
}

/// Parses the SVG size from the viewBox attribute.
({double width, double height}) parseSvgSize(String svg) {
  final viewBox = RegExp(r'viewBox="([^"]+)"').firstMatch(svg);
  if (viewBox != null) {
    final values = viewBox.group(1)!;
    final splits = values.split(' ');
    if (splits.length >= 4) {
      try {
        final width = double.parse(splits[2]);
        final height = double.parse(splits[3]);
        return (width: width, height: height);
      } catch (e) {
        throw FormatException('Invalid viewBox dimensions: $values');
      }
    }
  }
  final height = RegExp(r'height="([^"]+)"').firstMatch(svg);
  final width = RegExp(r'width="([^"]+)"').firstMatch(svg);

  if (width != null && height != null) {
    try {
      return (
        width: double.parse(width.group(1)!),
        height: double.parse(height.group(1)!),
      );
    } catch (e) {
      throw FormatException('Invalid width or height in SVG: $svg');
    }
  }

  throw ArgumentError(
    'SVG should have a valid viewBox attribute.\n\nInvalid SVG: $svg',
  );
}
