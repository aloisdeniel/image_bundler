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
    'pixelRatios',
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
    'assetRelativePath',
    abbr: 'a',
    defaultsTo: 'assets/',
    help: 'Relative path for assets in the output directory.',
  );

  parser.addOption(
    'codeRelativePath',
    abbr: 'c',
    defaultsTo: 'lib/src/widgets/',
    help: 'Relative path for generated code in the output directory.',
  );

  var args = parser.parse(arguments);

  final pixelRatios =
      args['pixelRatios']
          ?.split(',')
          .map((x) => double.tryParse(x.trim()) ?? 1.0)
          .toList() ??
      [1.0, 2.0, 3.0];
  final sizes =
      args['sizes']!.split(',').map((x) {
        final parts = x.split(':');
        return (int.parse(parts[0]), int.parse(parts[1]));
      }).toList();

  final name = args['name'] ?? 'sprite';
  final options = SvgBundlerOptions(
    name: name,
    package: args['package'],
    output: Directory(args['output'] ?? '.'),
    assetRelativePath: args['assetRelativePath'] ?? 'assets/',
    codeRelativePath: args['codeRelativePath'] ?? 'lib/src/widgets',
    variants: [
      for (final pixelRatio in pixelRatios)
        for (final size in sizes)
          SheetVariantOptions(
            pixelRatio: pixelRatio,
            spriteWidth: size.$1,
            sheetSize: Size(
              size.$2.toDouble() * pixelRatio,
              size.$2.toDouble() * pixelRatio,
            ),
            name: name,
          ),
    ],
    inputSvgs:
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
