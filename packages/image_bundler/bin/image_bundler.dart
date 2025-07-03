import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:image_bundler/src/options.dart';
import 'package:image_bundler/image_bundler.dart';

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption(
    'sizes',
    abbr: 's',
    help:
        'Comma-separated list of sizes in the format spriteWidth:sheetSize, e.g. 24:512,48:1024',
  );
  parser.addOption(
    'name',
    abbr: 'n',
    defaultsTo: 'sprite',
    help: 'Name of the spritesheet and generated classes.',
  );
  parser.addOption(
    'package',
    abbr: 'p',
    mandatory: false,
    help: 'Name of the package to add it to generated image providers.',
  );
  parser.addOption(
    'pixel-ratios',
    abbr: 'r',
    defaultsTo: '1.0,2.0,3.0',
    help: 'Comma-separated list of pixel ratios to generate spritesheets for.',
  );
  parser.addOption(
    'input',
    abbr: 'i',
    defaultsTo: '.',
    help: 'Directory containing SVG files to bundle.',
  );

  parser.addOption(
    'output',
    abbr: 'o',
    defaultsTo: '.',
    help: 'Directory to output the generated spritesheets and code.',
  );

  parser.addOption(
    'asset-relative-path',
    abbr: 'a',
    defaultsTo: 'assets/',
    help: 'Relative path for assets in the output directory.',
  );

  parser.addOption(
    'code-relative-path',
    abbr: 'c',
    defaultsTo: 'lib/src/widgets/',
    help: 'Relative path for generated code in the output directory.',
  );
  parser.addFlag(
    'include-original',
    abbr: 'g',
    defaultsTo: true,
    help:
        'Whether to include the original vector graphics or raster image files in the output.',
  );

  var args = parser.parse(arguments);

  final baseSizes =
      (args['sizes']! as String).split(',').map((x) {
          final parts = x.split(':');
          return MapEntry(int.parse(parts[0]), int.parse(parts[1]));
        }).toList()
        ..sort((x, y) => x.key.compareTo(y.key));
  final pixelRatios =
      (args['pixel-ratios']! as String)
          .split(',')
          .map((x) => double.parse(x))
          .toList()
        ..sort((x, y) => x.compareTo(y));
  final name = args['name'] ?? 'sprite';
  final sizes = <int, int>{};
  for (var baseSize in baseSizes) {
    for (var pixelRatio in pixelRatios) {
      sizes[(baseSize.key * pixelRatio).toInt()] =
          (baseSize.value * pixelRatio).toInt();
    }
  }

  final options = SvgBundlerOptions(
    name: name,
    package: args['package'],
    output: Directory(args['output'] ?? '.'),
    assetRelativePath: args['asset-relative-path'] ?? 'assets/',
    codeRelativePath: args['code-relative-path'] ?? 'lib/src/widgets',
    includeOriginal: args['include-original'] ?? true,
    variants: [
      for (final size in sizes.entries)
        SheetVariantOptions(
          spriteWidth: size.key,
          sheetSize: Size(size.value.toDouble(), size.value.toDouble()),
        ),
    ]..sort((x, y) => x.spriteWidth.compareTo(y.spriteWidth)),
    inputImages:
        Directory(args['input'] ?? '.')
            .listSync()
            .whereType<File>()
            .where(
              (f) => const [
                '.svg',
                '.png',
                '.jpg',
                '.jpeg',
              ].contains(extension(f.path)),
            )
            .toList(),
  );
  await bundleImages(options).toList();
}
