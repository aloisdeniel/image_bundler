/// Fits the source image to the output size, maintaining aspect ratio.
({int width, int height}) fitSize(
  int sourceWidth,
  int sourceHeight,
  outputWidth,
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

({int width, int height}) parseSvgSize(String svg) {
  final viewBox = RegExp(r'viewBox="([^"]+)"').firstMatch(svg);
  if (viewBox != null) {
    final values = viewBox.group(1)!;
    final splits = values.split(' ');
    if (splits.length >= 4) {
      try {
        final width = double.parse(splits[2]);
        final height = double.parse(splits[3]);
        return (width: width.toInt(), height: height.toInt());
      } catch (e) {
        throw FormatException('Invalid viewBox dimensions: $values');
      }
    }
  }
  throw ArgumentError(
    'SVG should have a valid viewBox attribute.\n\nInvalid SVG: $svg',
  );
}
