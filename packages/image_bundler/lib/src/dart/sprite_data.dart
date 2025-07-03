import 'package:image_bundler/src/dart/generator.dart';

String buildSpriteDataClass(CompiledSpritesheet spritesheet) {
  final buffer = StringBuffer();
  buffer.writeln('class ${spritesheet.options.dataClassName} {');

  // Constructor
  buffer.writeln(
    '  const ${spritesheet.options.dataClassName}(this.id, this.name, {this.isPng = false});',
  );
  buffer.writeln(
    '  const ${spritesheet.options.dataClassName}.png(this.id, this.name) : this.isPng = true;',
  );
  buffer.writeln('  final int id;');
  buffer.writeln('  final bool isPng;');
  buffer.writeln('  final String name;');

  // Resolve method
  buffer.writeln('  Rect resolveSource(double size) {');
  buffer.writeln('    var index = id * 4;');

  // Size offset
  buffer.writeln('    switch (size) {');
  for (var size in spritesheet.spriteWidths) {
    buffer.writeln('      case <= $size:');
    final offset = spritesheet.startOffset[size] ?? 0;
    buffer.writeln('        index +=  $offset;');
  }
  buffer.writeln('    }');

  buffer.writeln('    return Rect.fromLTWH(');
  buffer.writeln('      _pos[index].toDouble(),');
  buffer.writeln('      _pos[index + 1].toDouble(),');
  buffer.writeln('      _pos[index + 2].toDouble(),');
  buffer.writeln('      _pos[index + 3].toDouble(),');
  buffer.writeln('    );');
  buffer.writeln('  }');

  // Positions
  buffer.writeln('  /// All positions are stored consecutively in a list.');
  buffer.writeln('  static const _pos = [');
  for (var i = 0; i < spritesheet.positions.length; i++) {
    buffer.writeln('    // $i - ${spritesheet.spriteWidths[i]}');
    buffer.writeln('    ${spritesheet.positions[i].join(', ')},');
  }
  buffer.writeln('  ];');

  buffer.writeln('}');
  return buffer.toString();
}
