import 'dart:io';

import 'dart:convert';

import 'package:recase/recase.dart';
import 'package:svg_bundler/src/dart/generator.dart';
import 'package:svg_bundler/src/options.dart';
import 'package:svg_bundler/src/pack/pack.dart';

import 'geometry.dart';
import 'package:path/path.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart'
    hide Rect;
import 'package:svg_bundler/src/spritesheet.dart';

class SvgBundle {
  const SvgBundle({
    required this.options,
    required this.code,
    required this.spritesheets,
  });
  final SvgBundlerOptions options;
  final List<Spritesheet> spritesheets;
  final String code;
}

class SvgBundler {
  Future<SvgBundle> bundle(SvgBundlerOptions options) async {
    final spritesheets = <Spritesheet>[];

    for (var sizeVariant in options.sizeVariants) {
      for (var pixelRatio in options.pixelRatios) {
        final spritesheet = await createSpritesheet(
          files: options.inputSvgs,
          spriteWidth: sizeVariant,
          pixelRatio: pixelRatio,
        );
        spritesheets.add(spritesheet);
      }
    }

    final dartGenerator = SpritesheetDartGenerator();
    final code = dartGenerator.generate(spritesheets, options);
    return SvgBundle(options: options, spritesheets: spritesheets, code: code);
  }

  Future<Spritesheet> createSpritesheet({
    required List<File> files,
    required int spriteWidth,
    required double pixelRatio,
    int? maxWidth,
  }) async {
    final effectiveMaxWidth = switch (pixelRatio) {
      >= 2.0 => 4096,
      _ => 2048,
    };
    final packer = Pack(width: effectiveMaxWidth, height: effectiveMaxWidth);
    final sprites = <String, Sprite>{};
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final name = ReCase(basenameWithoutExtension(file.path)).camelCase;
      final bytes = await file.readAsBytes();
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
        pixelRatio * spriteWidth * (instructions.height.toDouble() / instructions.width),
      );
      final destination = packer.add(size);

      sprites[name] = Sprite(
        name: name,
        index: sprites.length,
        vectorGraphics: VectorSprite(
          bytes: vec,
          svg: svgContent,
          instructions: instructions,
          source: file,
        ),
        rect: destination,
      );
    }

    return Spritesheet(
      sprites: sprites.values.toList(),
      spriteWidth: spriteWidth,
      width: effectiveMaxWidth,
      height: effectiveMaxWidth,
      pixelRatio: pixelRatio,
    );
  }
}
