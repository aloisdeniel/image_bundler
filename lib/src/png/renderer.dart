import 'dart:typed_data';

import 'package:svg_bundler/src/png/canvas.dart';
import 'package:svg_bundler/src/spritesheet.dart';

class SpritesheetPngRenderer {
  const SpritesheetPngRenderer();
  Future<Uint8List> render(Spritesheet s) async {
    final renderer = Canvas.create(s.width, s.height);
    for (var sprite in s.sprites) {
      final destination = sprite.rect;
      await renderer.paintSvg(
        sprite.vectorGraphics.svg,
        sprite.vectorGraphics.instructions,
        destination.left,
        destination.top,
        destination.width,
        destination.height,
        sprite.vectorGraphics.instructions.width / destination.width,
        sprite.vectorGraphics.instructions.height / destination.height,
      );
    }
    return await renderer.toImage();
  }
}
