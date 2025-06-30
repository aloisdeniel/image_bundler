import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:image_bundler/src/bundler.dart';
import 'package:image_bundler/src/options.dart';
import 'package:image_bundler/src/png/renderer.dart';
import 'package:image_bundler/src/spritesheet.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

export 'package:image_bundler/src/geometry.dart' show Size;

Stream<List<File>> bundleImages(SvgBundlerOptions options) async* {
  initializePathOpsFromFlutterCache();

  final pngRenderer = SpritesheetPngRenderer();
  final bundler = ImageBundler();
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
    final bytes = await pngRenderer.render(
      sheet,
      onStartSprite: (s) {
        print(' Sprite > ${s.name}');
      },
    );
    await outputFile.writeAsBytes(bytes);
    print('Saved spritesheet to $path.');
  }

  print('Starting rendering vector sprites to vector assets...');
  for (var sprite
      in result.spritesheets.first.sprites.whereType<VectorSprite>()) {
    final path = join(
      options.output.path,
      options.assetVecRelativePath(sprite.name),
    );
    final outputFile = File(path);
    await outputFile.create(recursive: true);
    await outputFile.writeAsBytes(sprite.bytes);
    print('Saved vector sprite to $path.');
  }

  print('Starting rendering rasterized sprites to assets...');
  final pixelRatios =
      result.spritesheets.map((e) => e.pixelRatio).toSet().toList()
        ..sort((a, b) => a.compareTo(b));
  for (var sprite
      in result.spritesheets.first.sprites.whereType<RasterizedSprite>()) {
    for (var pixelRatio in pixelRatios) {
      final path = join(
        options.output.path,
        options.assetRasterRelativePath(sprite.name, pixelRatio),
      );
      final scale = pixelRatio / pixelRatios.last;
      final scaledImage =
          scale == 1.0
              ? sprite.image
              : copyResize(
                sprite.image,
                interpolation: Interpolation.cubic,
                width: (sprite.image.width * scale).floor(),
                height: (sprite.image.height * scale).floor(),
              );
      final bytes = encodePng(scaledImage);
      final outputFile = File(path);
      await outputFile.create(recursive: true);
      await outputFile.writeAsBytes(bytes);
      print('Saved rasterized sprite to $path.');
    }
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
