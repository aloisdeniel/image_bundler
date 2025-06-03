import 'package:svg_bundler/src/dart/generator.dart';

String buildSpriteDataClass(CompiledSpritesheet spritesheet, String assetPath) {
  final buffer = StringBuffer();
  buffer.writeln('class SpriteData {');

  // Constructor
  buffer.writeln('  const SpriteData(this.id, this.name);');
  buffer.writeln('  final int id;');
  buffer.writeln('  final String name;');

  // Shared image
  buffer.writeln('  // This image is shared between all sprites.');
  buffer.writeln(
    '  static ImageProvider image = const AssetImage(\'$assetPath\');',
  );

  // Resolve method
  buffer.writeln('  Rect resolve(double size, double pixelRatio) {');
  buffer.writeln('    var index = id * 2;');
  buffer.writeln('    double resolvedSize = ${spritesheet.sizes.last}.0;');

  // Size offset
  buffer.writeln('    switch (size) {');
  for (var size in spritesheet.sizeStartOffset) {
    buffer.writeln('      case <= ${size.$1}:');
    buffer.writeln('        index += ${size.$2};');
    buffer.writeln('        resolvedSize = ${size.$1}.0;');
  }
  buffer.writeln('    }');

  // Pixel ratio offset
  buffer.writeln('    switch (pixelRatio) {');
  for (var sheet in spritesheet.pixelRatioStartOffset) {
    buffer.writeln('      case <= ${sheet.$1}:');
    buffer.writeln('        index += ${sheet.$2};');
    buffer.writeln('        resolvedSize *= ${sheet.$1};');
  }
  buffer.writeln('    }');

  buffer.writeln('    return Rect.fromLTWH(');
  buffer.writeln('      _pos[index].toDouble(),');
  buffer.writeln('      _pos[index + 1].toDouble(),');
  buffer.writeln('      resolvedSize,');
  buffer.writeln('      resolvedSize,');
  buffer.writeln('    );');
  buffer.writeln('  }');

  // Positions
  buffer.writeln('  /// All positions are stored consecutively in a list.');
  buffer.writeln('  static const _pos = [');
  buffer.writeln('    ${spritesheet.positions.join(', ')},');
  buffer.writeln('  ];');

  buffer.writeln('}');
  return buffer.toString();
}
