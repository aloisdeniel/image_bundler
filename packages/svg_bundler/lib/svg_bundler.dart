import 'dart:io';

import 'package:path/path.dart';
import 'package:svg_bundler/src/bundler.dart';
import 'package:svg_bundler/src/options.dart';
import 'package:svg_bundler/src/png/renderer.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

export 'package:svg_bundler/src/geometry.dart' show Size;

Stream<List<File>> bundleSvgs(SvgBundlerOptions options) async* {
  initializePathOpsFromFlutterCache();

  final pngRenderer = SpritesheetPngRenderer();
  final bundler = SvgBundler();
  print('Starting processing spritesheets...');
  final result = await bundler.bundle(options);
  print('All spritesheets processed.');
  print('Starting rendering spritesheets to PNG...');
  for (var sheet in result.spritesheets) {
    final path = join(
      options.output.path,
      options.assetSheetRelativePath(sheet.pixelRatio, sheet.spriteWidth),
    );
    final outputFile = File(path);
    await outputFile.create(recursive: true);
    final bytes = await pngRenderer.render(sheet);
    await outputFile.writeAsBytes(bytes);
    print('Saved spritesheet to $path.');
  }

  print('Starting rendering sprites to vector graphics...');
  for (var sprite in result.spritesheets.first.sprites) {
    final path = join(
      options.output.path,
      options.assetVecRelativePath(sprite.name),
    );
    final outputFile = File(path);
    await outputFile.create(recursive: true);
    await outputFile.writeAsBytes(sprite.vectorGraphics.bytes);
    print('Saved sprite to $path.');
  }

  print('Starting code generation...');
  final codeFile = File(
    join(options.codeOutput.path, '${options.fileName}.g.dart'),
  );
  await codeFile.create(recursive: true);
  await codeFile.writeAsString(result.code);
  print('Generated code for spritesheets at ${codeFile.path}.');

  print(
    'Generation completed, don\'t forget to update your pubspec.yaml file:',
  );
  print('');
  print('flutter:');
  print('  assets:');
  print('    - ${options.assetRelativePath}${options.fileName}/');
  print('    - ${options.assetRelativePath}${options.fileName}/vec/');
  print('');
}
