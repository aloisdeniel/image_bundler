import 'package:svg_bundler/src/dart/sprite_data.dart';
import 'package:svg_bundler/src/dart/sprite_widget.dart';
import 'package:svg_bundler/src/dart/sprites.dart';
import 'package:svg_bundler/src/dart/widget.dart';
import 'package:svg_bundler/src/options.dart';
import 'package:svg_bundler/src/spritesheet.dart';

/// Spritesheet data that is optimized to generate code.
class CompiledSpritesheet {
  const CompiledSpritesheet({
    required this.options,
    required this.fileName,
    required this.fieldNames,
    required this.pixelRatios,
    required this.positions,
    required this.startOffset,
  });

  factory CompiledSpritesheet.fromSpritesheets(
    List<Spritesheet> sheets,
    SvgBundlerOptions options,
  ) {
    sheets.sort((x, y) => x.pixelRatio.compareTo(y.pixelRatio));

    final names = sheets.first.sprites.map((x) => x.name).toList()..sort();
    final positions = <int>[];
    final startOffset = <(int size, double pixelRatio), int>{};
    for (var i = 0; i < sheets.length; i++) {
      final sheet = sheets[i];
      startOffset[(sheet.spriteWidth, sheet.pixelRatio)] = positions.length;
      for (var sprite in sheet.sprites) {
        final pos = sprite.rect;
        positions.add(pos.left.toInt());
        positions.add(pos.top.toInt());
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
    );
  }
  final SvgBundlerOptions options;
  final Map<(int size, double pixelRatio), int> startOffset;
  final List<String> fileName;
  final List<String> fieldNames;
  final List<double> pixelRatios;
  final List<int> positions;
}

class SpritesheetDartGenerator {
  String generate(List<Spritesheet> sheets, SvgBundlerOptions options) {
    final compiled = CompiledSpritesheet.fromSpritesheets(sheets, options);
    final result = StringBuffer();
    result.writeln("import 'dart:ui' as ui;");
    result.writeln();
    result.writeln("import 'package:flutter/material.dart';");
    result.writeln("import 'package:vector_graphics/vector_graphics.dart';");
    result.writeln();
    result.writeln(buildSpritesClass(compiled));
    result.writeln();
    result.writeln(buildWidgetClass(compiled));
    result.writeln();
    result.writeln(buildSpriteDataClass(compiled));
    result.writeln();
    result.writeln(buildSpriteWidgetClass(compiled));
    return result.toString();
  }
}
