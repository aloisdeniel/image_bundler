import 'package:svg_bundler/src/dart/generator.dart';

String buildSpriteDataClass(CompiledSpritesheet spritesheet) {
  final buffer = StringBuffer();
  buffer.writeln('class ${spritesheet.options.dataClassName} {');

  // Constructor
  buffer.writeln(
    '  const ${spritesheet.options.dataClassName}(this.id, this.name);',
  );
  buffer.writeln('  final int id;');
  buffer.writeln('  final String name;');

  // Shared image
  buffer.writeln('  // This image is shared between all sprites.');
  for (var size in spritesheet.options.sizeVariants) {
    final sheetPath = spritesheet.options.assetSheetRelativePath(1, size);
    buffer.writeln(
      '  static ImageProvider image$size = const AssetImage(\'$sheetPath\');',
    );
  }

  // Resolve method
  buffer.writeln(
    '  (Rect,ImageProvider) resolve(double size, double pixelRatio) {',
  );
  buffer.writeln('    var index = id * 4;');

  // Size offset
  buffer.writeln(
    '    var image = image${spritesheet.options.sizeVariants.last};',
  );
  buffer.writeln('    switch (size) {');
  for (var size in spritesheet.options.sizeVariants) {
    buffer.writeln('      case <= $size:');
    buffer.writeln('        image = image$size;');
    buffer.writeln('        index += switch (pixelRatio) {');
    for (var i = 0; i < spritesheet.pixelRatios.length; i++) {
      final pixelRatio = spritesheet.pixelRatios[i];
      final offset = spritesheet.startOffset[(size, pixelRatio)] ?? 0;
      if (i == spritesheet.pixelRatios.length - 1) {
        buffer.writeln('          _ => $offset,');
      } else {
        buffer.writeln('          <= $pixelRatio => $offset,');
      }
    }
    buffer.writeln('        };');
  }
  buffer.writeln('    }');

  buffer.writeln('    return (Rect.fromLTWH(');
  buffer.writeln('      _pos[index].toDouble(),');
  buffer.writeln('      _pos[index + 1].toDouble(),');
  buffer.writeln('      _pos[index + 2].toDouble(),');
  buffer.writeln('      _pos[index + 3].toDouble(),');
  buffer.writeln('    ), image);');
  buffer.writeln('  }');

  // Positions
  buffer.writeln('  /// All positions are stored consecutively in a list.');
  buffer.writeln('  static const _pos = [');
  buffer.writeln('    ${spritesheet.positions.join(', ')},');
  buffer.writeln('  ];');

  buffer.writeln('}');
  return buffer.toString();
}
