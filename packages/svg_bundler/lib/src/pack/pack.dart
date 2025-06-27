import 'package:svg_bundler/src/geometry.dart';
import 'package:svg_bundler/src/pack/max_rects.dart' hide Rect;

/// A class that manages a packing of rectangles into a bin of a given size.
class Pack {
  /// Creates a new instance of [Pack] with the specified width, height, and optional margin.
  Pack({required this.width, required this.height, this.margin = 1});

  /// Width of the bin to pack rectangles into.
  final int width;

  /// Width of the bin to pack rectangles into.
  final int height;

  /// Margin around each rectangle.
  final int margin;
  late final _bin = MaxRectsBinPack(width, height, allowRotations: false);

  /// Adds a rectangle of the given size to the pack.
  Rect add(Size size) {
    final result = _bin.insert(
      size.width.ceil() + margin * 2,
      size.height.ceil() + margin * 2,
      FreeRectChoiceHeuristic.bestAreaFit,
    );
    return Rect.fromLTWH(
      result.x.toDouble() + margin,
      result.y.toDouble() + margin,
      result.width.toDouble() - 2 * margin,
      result.height.toDouble() - 2 * margin,
    );
  }
}
