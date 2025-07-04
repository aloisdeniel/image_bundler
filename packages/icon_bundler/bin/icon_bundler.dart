import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:icon_bundler/icon_bundler.dart';

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption(
    'sizes',
    abbr: 's',
    help: 'Comma-separated list of sizes, e.g. 24,48',
  );
  parser.addOption(
    'name',
    abbr: 'n',
    defaultsTo: 'app_icon',
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

  parser.addFlag('help', abbr: 'h', help: 'Show help.');
  var args = parser.parse(arguments);

  if (args['help'] == true) {
    print(parser.usage);
    exit(0);
  }

  final baseSizes = (args['sizes']! as String).split(',').map((x) {
    return int.parse(x);
  }).toSet();
  final pixelRatios =
      (args['pixel-ratios']! as String)
          .split(',')
          .map((x) => double.parse(x))
          .toList()
        ..sort((x, y) => x.compareTo(y));
  final name = args['name'] ?? 'sprite';
  final sizes = <int>{};
  for (var baseSize in baseSizes) {
    for (var pixelRatio in pixelRatios) {
      sizes.add((baseSize * pixelRatio).toInt());
    }
  }

  final options = IconBundlerOptions(
    name: name,
    package: args['package'],
    output: Directory(args['output'] ?? '.'),
    assetRelativePath: args['asset-relative-path'] ?? 'assets/',
    codeRelativePath: args['code-relative-path'] ?? 'lib/src/widgets',
    variants: sizes.toList()..sort((x, y) => x.compareTo(y)),
    inputImages: Directory(args['input'] ?? '.')
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

  const String logo =
      // ignore: prefer_adjacent_string_concatenation
      ' ░░▀█▀░█▀▀░█▀█░█▀█░░░█▀▄░█░█░█▀█░█▀▄░█░░░█▀▀░█▀▄\n' +
      ' ░░░█░░█░░░█░█░█░█░░░█▀▄░█░█░█░█░█░█░█░░░█▀▀░█▀▄\n' +
      ' ░░▀▀▀░▀▀▀░▀▀▀░▀░▀░░░▀▀░░▀▀▀░▀░▀░▀▀░░▀▀▀░▀▀▀░▀░▀';

  print('');
  print(logo);

  await for (var event in bundleIcons(options)) {
    switch (event) {
      case SpritesheetConfigurationCompletedEvent spritesheetConfig:
        print(' ░');
        print(' \x1B[1;34m█ Ready\x1B[0m');
        print(
          ' ░ \x1B[1;34m✓\x1B[0m Size variants: ${spritesheetConfig.spritesheets.map((x) => x.spriteSize).join(',')}',
        );
        print(
          ' ░ \x1B[1;34m✓\x1B[0m Sprite count: ${spritesheetConfig.spritesheets.first.sprites.length}',
        );
      case SpritesheetRenderingStarted():
        print(' ░');
        print(' \x1B[1;36m█ Rendering\x1B[0m');
        stdout.writeln();
      case SpritesheetRenderingProgressEvent progress:
        stdout.write('\x1B[1A'); // Move cursor up
        stdout.write('\x1B[2K'); // Clear entire line
        const loaderSymbols = ['▖', '▗', '▝', '▘'];
        final symbol = loaderSymbols[progress.index % loaderSymbols.length];
        stdout.writeln(
          ' $symbol ${(progress.progress * 100).toStringAsFixed(1)}% ${progress.nextSprite.name}',
        );
      case SpritesheetRenderedEvent rendered:
        stdout.write('\x1B[1A'); // Move cursor up
        stdout.write('\x1B[2K'); // Clear entire line
        stdout.writeln(
          ' ░ \x1B[1;36m✓\x1B[0m ${rendered.file.path} (${(rendered.sizeInBytes / 1024).toStringAsFixed(1)}kB)',
        );
        if (!event.isLast) stdout.writeln();
      case SpritesheetRenderingCompleted():
        print(' ░ \x1B[1;36m✓\x1B[0m Rendering completed ');
      case SpritesheetCodeGenerationStarted():
        print(' ░');
        print(' \x1B[1;35m█ Code generation\x1B[0m');
      case SpritesheetCodeGenerationCompleted():
        print(' ░ \x1B[1;35m✓\x1B[0m ${event.file.path} ');
    }
  }
  print(' ░');
  print(' \x1B[1;32m█ Completed\x1B[0m');
  print(' ░');
  print(' ░ Don\'t forget to update your pubspec.yaml file:');
  print(' ░');
  print(' ░ dependencies:');
  print(' ░   sprite_image: any');
  print(' ░');
  print(' ░ flutter:');
  print(' ░   assets:');
  print(' ░     - ${options.assetRelativePath}${options.fileName}/');
  print(' ░');
}
