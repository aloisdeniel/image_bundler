import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:image_bundler/src/png/canvas.dart';
import 'package:image_bundler/src/spritesheet.dart';

class SpritesheetPngRenderer {
  const SpritesheetPngRenderer();
  Future<Uint8List> render(
    Spritesheet s, {
    void Function(Sprite sprite)? onStartSprite,
  }) async {
    final renderer = Canvas.create(s.width, s.height);
    for (var sprite in s.sprites) {
      final destination = sprite.rect;
      onStartSprite?.call(sprite);
      switch (sprite) {
        case VectorSprite():
          await renderer.paintSvg(
            sprite.svg,
            sprite.instructions,
            destination.left,
            destination.top,
            destination.width,
            destination.height,
          );

          break;
        case RasterizedSprite():
          // We control downsampling algorithm here
          final resized = copyResize(
            sprite.image,
            interpolation: Interpolation.cubic,
            width: destination.width.floor(),
            maintainAspect: true,
          );
          await renderer.paintImage(
            resized,
            destination.left,
            destination.top,
            destination.width,
            destination.height,
          );
          break;
      }
    }
    return await renderer.toImage();
  }
}
