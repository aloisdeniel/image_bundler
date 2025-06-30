import 'dart:io';

import 'dart:convert';

import 'package:image/image.dart';
import 'package:image_bundler/src/utils/naming.dart';
import 'package:image_bundler/src/dart/generator.dart';
import 'package:image_bundler/src/options.dart';
import 'package:image_bundler/src/pack/pack.dart';

import 'geometry.dart';
import 'package:path/path.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart'
    hide Rect;
import 'package:image_bundler/src/spritesheet.dart';

class ImageBundle {
  const ImageBundle({
    required this.options,
    required this.code,
    required this.spritesheets,
  });
  final SvgBundlerOptions options;
  final List<Spritesheet> spritesheets;
  final String code;
}

class ImageBundler {
  Future<ImageBundle> bundle(SvgBundlerOptions options) async {
    final spritesheets = <Spritesheet>[];

    for (var sizeVariant in options.variants) {
      final spritesheet = await createSpritesheet(
        files: options.inputSvgs,
        spriteWidth: sizeVariant.spriteWidth,
        pixelRatio: sizeVariant.pixelRatio,
        sheetSize: sizeVariant.sheetSize,
      );
      spritesheets.add(spritesheet);
    }

    final dartGenerator = SpritesheetDartGenerator();
    final code = dartGenerator.generate(spritesheets, options);
    return ImageBundle(
      options: options,
      spritesheets: spritesheets,
      code: code,
    );
  }

  Future<Spritesheet> createSpritesheet({
    required List<File> files,
    required int spriteWidth,
    required double pixelRatio,
    required Size sheetSize,
    int? maxWidth,
  }) async {
    final packer = Pack(
      width: sheetSize.width.toInt(),
      height: sheetSize.height.toInt(),
    );
    final sprites = <String, Sprite>{};
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = extension(file.path).toLowerCase();
      final name = Naming.fieldName(basenameWithoutExtension(file.path));
      final bytes = await file.readAsBytes();
      if (ext == '.svg') {
        final svgContent = utf8.decode(bytes);
        final instructions = parse(svgContent);
        final vec = encodeSvg(
          xml: svgContent,
          debugName: name,
          enableClippingOptimizer: false,
          enableMaskingOptimizer: false,
          enableOverdrawOptimizer: false,
        );

        final size = Size(
          pixelRatio * spriteWidth.toDouble(),
          pixelRatio *
              spriteWidth *
              (instructions.height.toDouble() / instructions.width),
        );
        final destination = packer.add(size);

        sprites[name] = VectorSprite(
          name: name,
          index: sprites.length,
          bytes: vec,
          svg: svgContent,
          instructions: instructions,
          source: file,
          rect: destination,
        );
      } else if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
        final decoded = decodePng(bytes);
        if (decoded == null) {
          throw FormatException('Failed to decode PNG: ${file.path}');
        }
        final size = Size(
          pixelRatio * spriteWidth.toDouble(),
          pixelRatio *
              spriteWidth *
              (decoded.height.toDouble() / decoded.width),
        );
        final destination = packer.add(size);
        sprites[name] = RasterizedSprite(
          name: name,
          index: sprites.length,
          image: decoded,
          bytes: bytes,
          source: file,
          rect: destination,
        );
      } else {
        throw UnsupportedError('Unsupported file type: $ext');
      }
    }

    return Spritesheet(
      sprites: sprites.values.toList(),
      spriteWidth: spriteWidth,
      width: sheetSize.width.toInt(),
      height: sheetSize.height.toInt(),
      pixelRatio: pixelRatio,
    );
  }
}
