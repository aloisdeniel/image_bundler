import 'package:svg_bundler/src/geometry.dart';
import 'package:svg_bundler/src/pack/max_rects.dart' hide Rect;

/// A class that manages a packing of rectangles into a bin of a given size.
class Pack {
  Pack({required this.width, required this.height});
  final int width;
  final int height;
  late final _bin = MaxRectsBinPack(width, height, allowRotations: false);

  /// Adds a rectangle of the given size to the pack.
  Rect add(Size size) {
    final result = _bin.insert(
      size.width.ceil(),
      size.height.ceil(),
      FreeRectChoiceHeuristic.BestAreaFit,
    );
    return Rect.fromLTWH(
      result.x.toDouble(),
      result.y.toDouble(),
      result.width.toDouble(),
      result.height.toDouble(),
    );
  }
}
