import 'package:image_bundler/src/dart/image.dart';
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
    required this.positions,
    required this.startOffset,
    required this.spriteWidths,
  });

  factory CompiledSpritesheet.fromSpritesheets(
    List<Spritesheet> sheets,
    SvgBundlerOptions options,
  ) {
    final names = sheets.first.sprites.map((x) => x.name).toList()..sort();
    final positions = <List<int>>[];
    final spriteWidths = <int>{};
    final startOffset = <int, int>{};
    var offset = 0;
    for (var i = 0; i < sheets.length; i++) {
      final sizePositions = <int>[];
      final sheet = sheets[i];
      startOffset[sheet.spriteWidth] = offset;
      spriteWidths.add(sheet.spriteWidth);
      for (var name in names) {
        final sprite = sheet.sprites.firstWhere((x) => x.name == name);
        final pos = sprite.rect;
        sizePositions.add(pos.left.toInt());
        sizePositions.add(pos.top.toInt());
        sizePositions.add(pos.width.toInt());
        sizePositions.add(pos.height.toInt());
      }
      positions.add(sizePositions);
      offset += sizePositions.length;
    }

    return CompiledSpritesheet(
      options: options,
      fileName: names,
      fieldNames: names,
      positions: positions,
      startOffset: startOffset,
      spriteWidths: spriteWidths.toList()..sort((x, y) => x.compareTo(y)),
    );
  }
  final SvgBundlerOptions options;
  final Map<int, int> startOffset;
  final List<String> fileName;
  final List<String> fieldNames;
  final List<int> spriteWidths;
  final List<List<int>> positions;
}

class SpritesheetDartGenerator {
  String generate(List<Spritesheet> sheets, SvgBundlerOptions options) {
    final compiled = CompiledSpritesheet.fromSpritesheets(sheets, options);
    final result = StringBuffer();

    result.writeln("import 'dart:ui' as ui;");
    result.writeln();
    result.writeln("import 'package:flutter/foundation.dart';");
    result.writeln("import 'package:flutter/material.dart';");
    result.writeln("import 'package:flutter/services.dart';");
    if (options.includeOriginal) {
      result.writeln("import 'package:vector_graphics/vector_graphics.dart';");
    }
    result.writeln();
    result.writeln("import 'package:sprite_image/sprite_image.dart' as si;");
    result.writeln();
    result.writeln(buildSpritesClass(compiled));
    result.writeln();
    result.writeln(buildWidgetClass(compiled));
    result.writeln();
    result.writeln(buildSpriteDataClass(compiled));
    result.writeln();
    result.writeln(buildImageClass(compiled));
    return result.toString();
  }
}
