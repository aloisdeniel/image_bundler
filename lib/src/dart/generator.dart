import 'package:svg_bundler/src/dart/sprite_data.dart';
import 'package:svg_bundler/src/dart/sprite_widget.dart';
import 'package:svg_bundler/src/dart/sprites.dart';
import 'package:svg_bundler/src/dart/widget.dart';
import 'package:svg_bundler/src/spritesheet.dart';

/// Spritesheet data that is optimized to generate code.
class CompiledSpritesheet {
  const CompiledSpritesheet({
    required this.fileName,
    required this.fieldNames,
    required this.pixelRatios,
    required this.sizes,
    required this.positions,
    required this.sizeStartOffset,
    required this.pixelRatioStartOffset,
  });

  factory CompiledSpritesheet.fromSpritesheets(List<Spritesheet> sheets) {
    sheets.sort((x, y) => x.pixelRatio.compareTo(y.pixelRatio));

    final names = sheets.first.sprites.map((x) => x.name).toList()..sort();
    final sizes =
        sheets.first.sizeVariants.toList()..sort((x, y) => x.compareTo(y));
    final positions = <int>[];
    for (var sheet in sheets) {
      for (var name in names) {
        final sprite = sheet.sprites.where((x) => x.name == name).first;
        for (var size in sizes) {
          final pos = sprite.rect[size]!;
          positions.add(pos.left.toInt());
          positions.add(pos.top.toInt());
        }
      }
    }
    final pixelRatioStartOffset = <(double, int)>[];
    for (var i = 0; i < sheets.length; i++) {
      final sheet = sheets[i];
      final offset = i * names.length * sizes.length * 2;
      pixelRatioStartOffset.add((sheet.pixelRatio, offset));
    }

    final sizeStartOffset = <(int, int)>[];
    for (var i = 0; i < sizes.length; i++) {
      final size = sizes[i];
      final offset = i * names.length * 2;
      sizeStartOffset.add((size, offset));
    }

    return CompiledSpritesheet(
      fileName: names,
      fieldNames: names,
      sizes: sizes,
      pixelRatios: sheets.map((e) => e.pixelRatio).toList(),
      positions: positions,
      sizeStartOffset: sizeStartOffset,
      pixelRatioStartOffset: pixelRatioStartOffset,
    );
  }

  final List<(double, int)> pixelRatioStartOffset;
  final List<(int, int)> sizeStartOffset;
  final List<String> fileName;
  final List<String> fieldNames;
  final List<int> sizes;
  final List<double> pixelRatios;
  final List<int> positions;
}

class SpritesheetDartGenerator {
  String generate(List<Spritesheet> sheets, String assetPath) {
    final compiled = CompiledSpritesheet.fromSpritesheets(sheets);
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
    result.writeln(buildSpriteDataClass(compiled, assetPath));
    result.writeln();
    result.writeln(buildSpriteWidgetClass());
    return result.toString();
  }
}
