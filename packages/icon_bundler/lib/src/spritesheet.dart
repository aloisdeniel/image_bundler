import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:icon_bundler/src/naming.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';

sealed class Sprite {
  const Sprite({required this.name, required this.bytes, required this.source});
  final String name;
  final File source;
  final Uint8List bytes;
}

/// A sprite generated from a vector image, such as an SVG.
class VectorSprite extends Sprite {
  const VectorSprite({
    required super.name,
    required super.source,
    required super.bytes,
    required this.svg,
  });
  final String svg;
}

/// A sprite generated from a raster image, such as a PNG or JPEG.
class RasterizedSprite extends Sprite {
  const RasterizedSprite({
    required super.name,
    required super.source,
    required super.bytes,
    required this.image,
  });
  final Image image;
}

class PositionedSprite {
  const PositionedSprite({
    required this.index,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.sprite,
  });
  final int index;
  final Sprite sprite;
  final int left;
  final int top;
  final int width;
  final int height;
}

class Spritesheet {
  Spritesheet({
    required this.sprites,
    required this.spriteSize,
    required this.width,
    required this.height,
    required this.cols,
  });

  factory Spritesheet.fromSprites({
    required List<Sprite> sprites,
    required int spriteWidth,
  }) {
    sprites = sprites.toList()..sort((x, y) => x.name.compareTo(y.name));
    const margin = 1;
    final effectiveWidth = spriteWidth + 2 * margin;
    final cols = sqrt(sprites.length).ceil();
    final width = cols * effectiveWidth;
    return Spritesheet(
      sprites: [
        for (var i = 0; i < sprites.length; i++)
          PositionedSprite(
            index: i,
            left: (i % cols) * effectiveWidth + margin,
            top: (i ~/ cols) * effectiveWidth + margin,
            width: spriteWidth,
            height: spriteWidth,
            sprite: sprites[i],
          ),
      ],
      spriteSize: spriteWidth,
      width: width,
      height: (sprites.length / cols).ceil() * effectiveWidth,
      cols: cols,
    );
  }

  static Future<Spritesheet> fromFiles({
    required List<File> files,
    required int spriteSize,
  }) async {
    final sprites = <String, Sprite>{};

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = extension(file.path).toLowerCase();
      final name = Naming.fieldName(basenameWithoutExtension(file.path));
      final bytes = await file.readAsBytes();
      if (ext.toLowerCase() == '.svg') {
        sprites[name] = VectorSprite(
          name: name,
          bytes: bytes,
          svg: utf8.decode(bytes),
          source: file,
        );
      } else if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
        final decoded = decodePng(bytes);
        if (decoded == null) {
          throw FormatException('Failed to decode PNG: ${file.path}');
        }

        sprites[name] = RasterizedSprite(
          name: name,
          image: decoded,
          bytes: bytes,
          source: file,
        );
      } else {
        throw UnsupportedError('Unsupported file type: $ext');
      }
    }

    return Spritesheet.fromSprites(
      sprites: sprites.values.toList(),
      spriteWidth: spriteSize,
    );
  }

  final List<PositionedSprite> sprites;
  final int spriteSize;
  final int width;
  final int height;
  final int cols;
}
