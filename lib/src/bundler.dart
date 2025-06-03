import 'dart:io';

import 'dart:convert';
import 'dart:math' show max;

import 'package:recase/recase.dart';

import 'geometry.dart';
import 'package:path/path.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart'
    hide Rect;
import 'package:svg_bundler/src/spritesheet.dart';

class SvgBundlerOptions {
  const SvgBundlerOptions({
    required this.inputSvgs,
    this.pixelRatios = const [1.0, 2.0, 3.0],
    this.sizeVariants = const [24, 48],
  });
  final List<double> pixelRatios;
  final List<int> sizeVariants;
  final List<File> inputSvgs;
}

class SvgBundle {
  const SvgBundle({required this.options, required this.spritesheets});
  final SvgBundlerOptions options;
  final List<Spritesheet> spritesheets;
}

class SvgBundler {
  Stream<SvgBundle> bundle(SvgBundlerOptions options) async* {
    var result = SvgBundle(options: options, spritesheets: <Spritesheet>[]);

    for (var pixelRatio in options.pixelRatios) {
      final spritesheet = await renderSpritesheet(
        files: options.inputSvgs,
        sizeVariants: options.sizeVariants,
        pixelRatio: pixelRatio,
      );
      result.spritesheets.add(spritesheet);
      yield result;
    }
  }

  Future<Spritesheet> renderSpritesheet({
    required List<File> files,
    required List<int> sizeVariants,
    required double pixelRatio,
    int? maxWidth,
  }) async {
    final effectiveMaxWidth = switch (pixelRatio) {
      >= 2.0 => 4096,
      _ => 2048,
    };
    var offset = Offset(1, 1);
    var sheetsize = Size.zero;
    final sprites = <String, Sprite>{};
    for (var variant in sizeVariants) {
      final size = variant * pixelRatio;
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

        final sizes = applyBoxFit(
          BoxFit.contain,
          Size(instructions.width, instructions.height),
          Size(size.toDouble(), size.toDouble()),
        );
        final destination = Alignment.center.inscribe(
          sizes.destination,
          offset & sizes.destination,
        );

        final byName = sprites.putIfAbsent(
          name,
          () => Sprite(
            name: name,
            index: sprites.length,
            vectorGraphics: VectorSprite(
              bytes: vec,
              svg: svgContent,
              instructions: instructions,
              source: file,
            ),
            rect: {},
          ),
        );
        byName.rect[variant] = destination;

        // If last icon, we force line return
        if (i == files.length - 1) {
          offset += Offset(effectiveMaxWidth.toDouble(), 0);
        } else {
          offset += Offset(size + 1, 0);
        }
        if (offset.dx + size + 1 >= effectiveMaxWidth) {
          offset = Offset(0, offset.dy + size + 1);
        }
        sheetsize = Size(
          max(offset.dx + size + 1, sheetsize.width),
          max(offset.dy + size + 1, sheetsize.height),
        );
      }
    }

    return Spritesheet(
      sprites: sprites.values.toList(),
      sizeVariants: sizeVariants,
      width: effectiveMaxWidth,
      height: effectiveMaxWidth,
      pixelRatio: pixelRatio,
    );
  }
}
