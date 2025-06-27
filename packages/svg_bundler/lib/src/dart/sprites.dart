import 'package:svg_bundler/src/dart/generator.dart';

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

  buffer.writeln('  static Future<void> precache(BuildContext context) {');
  buffer.writeln('    return Future.wait([');

  for (var size in spritesheet.spriteWidths) {
    buffer.writeln('      precacheImage(IconData.image$size, context),');
  }

  buffer.writeln('    ]);');
  buffer.writeln('  }');

  buffer.writeln('}');
  return buffer.toString();
}
