import 'package:icon_bundler/src/options.dart';
import 'package:icon_bundler/src/spritesheet.dart';

class IconBundleCodeGenerator {
  IconBundleCodeGenerator(this.spritesheet, this.options);
  final IconBundlerOptions options;
  final Spritesheet spritesheet;

  String build() {
    final result = StringBuffer();

    result.writeln("import 'package:flutter/material.dart';");
    result.writeln();
    result.writeln("import 'package:sprite_image/sprite_image.dart' as si;");
    result.writeln();
    result.writeln(_data());
    result.writeln();
    result.writeln(_widgetClass());
    result.writeln();
    result.writeln(_dataClass());
    return result.toString();
  }

  String _data() {
    final buffer = StringBuffer();
    buffer.writeln('abstract class ${options.dataCollectionClassName} {');

    for (var sprite in spritesheet.sprites) {
      final name = sprite.sprite.name;
      final i = sprite.index;
      buffer.writeln(
        '  static const $name = ${options.dataClassName}($i, \'$name\');',
      );
    }

    buffer.writeln('  static const values = [');
    for (var name in spritesheet.sprites.map((x) => x.sprite.name)) {
      buffer.writeln('    $name,');
    }

    buffer.writeln('  ];');
    buffer.writeln();
    buffer.writeln();

    buffer.writeln('}');
    return buffer.toString();
  }

  String _dataClass() {
    final buffer = StringBuffer();
    buffer.writeln('class ${options.dataClassName} {');

    // Constructor
    buffer.writeln('  const ${options.dataClassName}(this.id, this.name);');

    // Properties
    buffer.writeln('  final int id;');
    buffer.writeln('  final String name;');

    buffer.writeln('}');
    return buffer.toString();
  }

  String _widgetClass() {
    final cols = spritesheet.cols;
    var sheetPath = options.assetSheetRelativePath('\$size', true);

    final widths = options.variants.toList()..sort((x, y) => y.compareTo(x));
    var resolved = '';
    for (var i = 1; i < widths.length; i++) {
      final wp = widths[i - 1];
      final w = widths[i];
      resolved += '        > $w => $wp,\n';
    }
    resolved += '        _ => ${widths.last},\n';

    return '''class ${options.widgetClassName} extends StatelessWidget {
  const ${options.widgetClassName}({super.key, required this.data, this.size, this.color});

  final double? size;
  final ${options.dataClassName} data;
  final Color? color;

  static Future<void> precache(BuildContext context) {
    return Future.wait([
      ${options.variants.map((x) => 'precacheImage(const AssetImage(\'${options.assetSheetRelativePath(x.toString(), true)}\'), context),').join('\n      ')}
    ]);
  }

  int resolveSize(
    double expectedSize, {
    required double pixelRatio,
  }) {
    final size = (expectedSize * pixelRatio).round();
    return switch (size) {
$resolved
    };
  }

  Widget _build(BuildContext context, double maxWidth) {
    final size = resolveSize(
      maxWidth,
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    );

    final sizeWithMargin = size + 2;
    final source = Rect.fromLTWH(
      1.0 + sizeWithMargin * (data.id % $cols),
      1.0 + sizeWithMargin * (data.id ~/ $cols),
      size.toDouble(),
      size.toDouble(),
    );
    return si.Sprite(
      image: AssetImage('$sheetPath'),
      source: source,
      color: color,
      width: maxWidth,
      height: maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (size case final size?) {
      return SizedBox(
        width: size,
        child: _build(context, size),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return _build(context, constraints.maxWidth);
      },
    );
  }
}
''';
  }
}
