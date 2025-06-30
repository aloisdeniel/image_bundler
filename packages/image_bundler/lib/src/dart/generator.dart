import 'package:image_bundler/src/dart/sprite_data.dart';
import 'package:image_bundler/src/dart/sprites.dart';
import 'package:image_bundler/src/dart/widget.dart';
import 'package:image_bundler/src/options.dart';
import 'package:image_bundler/src/spritesheet.dart';

/// Spritesheet data that is optimized to generate code.
class CompiledSpritesheet {
  const CompiledSpritesheet({
    required this.options,
    required this.fileName,
    required this.fieldNames,
    required this.pixelRatios,
    required this.positions,
    required this.startOffset,
    required this.spriteWidths,
  });

  factory CompiledSpritesheet.fromSpritesheets(
    List<Spritesheet> sheets,
    SvgBundlerOptions options,
  ) {
    sheets.sort((x, y) => x.pixelRatio.compareTo(y.pixelRatio));

    final names = sheets.first.sprites.map((x) => x.name).toList()..sort();
    final positions = <int>[];
    final spriteWidths = <int>{};
    final startOffset = <(int size, double pixelRatio), int>{};
    for (var i = 0; i < sheets.length; i++) {
      final sheet = sheets[i];
      startOffset[(sheet.spriteWidth, sheet.pixelRatio)] = positions.length;
      spriteWidths.add(sheet.spriteWidth);
      for (var name in names) {
        final sprite = sheet.sprites.firstWhere((x) => x.name == name);
        final pos = sprite.rect;
        positions.add(pos.left.toInt());
        positions.add(pos.top.toInt());
        positions.add(pos.width.toInt());
        positions.add(pos.height.toInt());
      }
    }

    return CompiledSpritesheet(
      options: options,
      fileName: names,
      fieldNames: names,
      pixelRatios:
          sheets.map((e) => e.pixelRatio).toSet().toList()
            ..sort((a, b) => a.compareTo(b)),
      positions: positions,
      startOffset: startOffset,
      spriteWidths: spriteWidths,
    );
  }
  final SvgBundlerOptions options;
  final Map<(int size, double pixelRatio), int> startOffset;
  final List<String> fileName;
  final List<String> fieldNames;
  final List<double> pixelRatios;
  final Set<int> spriteWidths;
  final List<int> positions;
}

class SpritesheetDartGenerator {
  String generate(List<Spritesheet> sheets, SvgBundlerOptions options) {
    final compiled = CompiledSpritesheet.fromSpritesheets(sheets, options);
    final result = StringBuffer();

    result.writeln("import 'package:flutter/material.dart';");
    result.writeln("import 'package:vector_graphics/vector_graphics.dart';");
    result.writeln();
    result.writeln("import 'package:sprite_image/sprite_image.dart' as si;");
    result.writeln();
    result.writeln(buildSpritesClass(compiled));
    result.writeln();
    result.writeln(buildWidgetClass(compiled));
    result.writeln();
    result.writeln(buildSpriteDataClass(compiled));
    return result.toString();
  }
}
