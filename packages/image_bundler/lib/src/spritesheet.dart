// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'geometry.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart'
    hide Rect;

sealed class Sprite {
  final String name;
  final int index;
  final Rect rect;
  final File source;
  const Sprite({
    required this.name,
    required this.source,
    required this.index,
    required this.rect,
  });
}

class VectorSprite extends Sprite {
  final String svg;
  final VectorInstructions instructions;
  final Uint8List bytes;
  const VectorSprite({
    required super.name,
    required super.index,
    required super.rect,
    required super.source,
    required this.bytes,
    required this.svg,
    required this.instructions,
  });
}

class RasterizedSprite extends Sprite {
  final Image image;
  final Uint8List bytes;
  const RasterizedSprite({
    required super.name,
    required super.index,
    required super.rect,
    required super.source,
    required this.bytes,
    required this.image,
  });
}

class Spritesheet {
  const Spritesheet({
    required this.sprites,
    required this.spriteWidth,
    required this.width,
    required this.height,
    required this.pixelRatio,
  });
  final List<Sprite> sprites;
  final int spriteWidth;
  final double pixelRatio;
  final int width;
  final int height;
}
