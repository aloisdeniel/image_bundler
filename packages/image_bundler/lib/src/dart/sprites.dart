import 'package:image_bundler/src/dart/generator.dart';

String buildSpritesClass(CompiledSpritesheet spritesheet) {
  final buffer = StringBuffer();
  buffer.writeln(
    'abstract class ${spritesheet.options.dataCollectionClassName} {',
  );

  for (var i = 0; i < spritesheet.fieldNames.length; i++) {
    final name = spritesheet.fieldNames[i];
    buffer.writeln(
      '  static const $name = ${spritesheet.options.dataClassName}($i, \'$name\');',
    );
  }

  buffer.writeln('  static const values = [');
  for (var name in spritesheet.fieldNames) {
    buffer.writeln('    $name,');
  }

  buffer.writeln('  ];');
  buffer.writeln();
  buffer.writeln();

  buffer.writeln('}');
  return buffer.toString();
}
