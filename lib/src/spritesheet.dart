// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'dart:io';
import 'dart:typed_data';

import 'geometry.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart'
    hide Rect;

class Sprite {
  final String name;
  final int index;
  final Map<int, Rect> rect;
  final VectorSprite vectorGraphics;
  const Sprite({
    required this.name,
    required this.vectorGraphics,
    required this.index,
    this.rect = const {},
  });
}

class Spritesheet {
  const Spritesheet({
    required this.sprites,
    required this.width,
    required this.height,
    required this.pixelRatio,
    required this.sizeVariants,
  });
  final List<int> sizeVariants;
  final List<Sprite> sprites;
  final double pixelRatio;
  final int width;
  final int height;
}

class VectorSprite {
  const VectorSprite({
    required this.bytes,
    required this.svg,
    required this.instructions,
    required this.source,
  });
  final String svg;
  final File source;
  final VectorInstructions instructions;
  final Uint8List bytes;
}
