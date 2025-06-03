import 'package:svg_bundler/src/dart/generator.dart';

String buildSpritesClass(CompiledSpritesheet spritesheet) {
  final buffer = StringBuffer();
  buffer.writeln('abstract class Sprites {');

  for (var i = 0; i < spritesheet.fieldNames.length; i++) {
    final name = spritesheet.fieldNames[i];
    buffer.writeln('  static const $name = SpriteData($i, \'$name\');');
  }

  buffer.writeln('  static const values = [');
  for (var name in spritesheet.fieldNames) {
    buffer.writeln('    $name,');
  }

  buffer.writeln('  ];');

  buffer.writeln('}');
  return buffer.toString();
}
