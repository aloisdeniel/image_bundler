import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:icon_bundler/src/spritesheet.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';

class SpritesheetRenderer {
  const SpritesheetRenderer();
  Future<Uint8List> render(
    Spritesheet s, {
    void Function(PositionedSprite sprite)? onStartSprite,
  }) async {
    final renderer = Canvas(s.width, s.height);
    for (var sprite in s.sprites) {
      onStartSprite?.call(sprite);
      switch (sprite.sprite) {
        case VectorSprite(svg: final String svg):
          await renderer.paintSvg(
            svg,
            sprite.left,
            sprite.top,
            sprite.width,
            sprite.height,
          );

          break;
        case RasterizedSprite(image: final Image image):
          // We control downsampling algorithm here
          final resized = copyResize(
            image,
            interpolation: Interpolation.cubic,
            width: sprite.width,
            height: sprite.height,
          );
          await renderer.paintImage(
            resized,
            sprite.left,
            sprite.top,
            sprite.width,
            sprite.height,
          );
          break;
      }
    }
    return await renderer.toImage();
  }
}

class Canvas {
  Canvas(this.width, this.height);
  final int width;
  final int height;

  Image? image;

  /// Paints the given SVG image at the given coordinates.
  Future<void> paintSvg(
    String svgContent,
    int x,
    int y,
    int width,
    int height,
  ) async {
    final process = await Process.start('resvg', [
      '-',
      '-c',
      '-w',
      width.toInt().toString(),
      '-h',
      height.toInt().toString(),
      '--resources-dir',
      current,
    ]);
    final completer = Completer<Uint8List>();
    final output = <int>[];
    process.stdout.listen(
      (chunk) {
        output.addAll(chunk);
      },
      onError: (e) {
        completer.completeError(e);
      },
      onDone: () {
        completer.complete(Uint8List.fromList(output));
      },
    );
    process.stderr.listen((data) {
      print('Error: ${utf8.decode(data)}');
      completer.completeError(data);
      process.kill();
    });
    process.stdin.writeln(svgContent.replaceAll('\n', ''));
    await process.stdin.close();

    // Adding to sheet
    final result = await completer.future;
    final decoded = decodePng(Uint8List.fromList(result));
    paintImage(decoded!, x, y, width, height);
  }

  /// Paints the given Png image at the given coordinates.
  Future<void> paintImage(
    Image image,
    int x,
    int y,
    int width,
    int height,
  ) async {
    if (this.image == null) {
      this.image = Image(
        width: this.width,
        height: this.height,
        format: image.format,
        numChannels: image.numChannels,
      );
    }
    this.image = compositeImage(
      this.image!,
      image,
      dstX: x.toInt(),
      dstY: y.toInt(),
      dstW: width.toInt(),
      dstH: height.toInt(),
      blend: BlendMode.direct,
      linearBlend: true,
    );
  }

  Future<Uint8List> toImage() async {
    return encodePng(image!);
  }
}
