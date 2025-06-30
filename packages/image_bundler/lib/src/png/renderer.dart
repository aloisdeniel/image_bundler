import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:image_bundler/src/png/canvas.dart';
import 'package:image_bundler/src/spritesheet.dart';

class SpritesheetPngRenderer {
  const SpritesheetPngRenderer();
  Future<Uint8List> render(Spritesheet s) async {
    final renderer = Canvas.create(s.width, s.height);
    for (var sprite in s.sprites) {
      final destination = sprite.rect;
      switch (sprite) {
        case VectorSprite():
          await renderer.paintSvg(
            sprite.svg,
            sprite.instructions,
            destination.left,
            destination.top,
            destination.width,
            destination.height,
            sprite.instructions.width / destination.width,
            sprite.instructions.height / destination.height,
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
            1,
            1,
          );
          break;
      }
    }
    return await renderer.toImage();
  }
}
