import 'dart:io';

import 'package:path/path.dart';
import 'package:svg_bundler/src/bundler.dart';
import 'package:svg_bundler/src/dart/generator.dart';
import 'package:svg_bundler/src/png/renderer.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

Stream<List<File>> bundleSvgs({
  required List<double> pixelRatios,
  required Directory input,
  required String name,
  required Directory assetOutput,
  required Directory codeOutput,
}) async* {
  initializePathOpsFromFlutterCache();

  final pngRenderer = SpritesheetPngRenderer();
  final dartGenerator = SpritesheetDartGenerator();
  final bundler = SvgBundler();
  final options = SvgBundlerOptions(
    pixelRatios: pixelRatios,
    inputSvgs:
        input
            .listSync()
            .whereType<File>()
            .where((f) => extension(f.path) == '.svg')
            .toList(),
  );
  print('Starting processing spritesheets...');
  SvgBundle? result;
  await for (var last in bundler.bundle(options)) {
    print('Processed ${last.spritesheets.length} spritesheet(s)... ');
    result = last;
  }
  print('All spritesheets processed.');
  if (result != null) {
    print('Starting rendering spritesheets to PNG...');
    for (var sheet in result.spritesheets) {
      final path = join(
        assetOutput.path,
        name,
        sheet.pixelRatio != 1.0
            ? join('${sheet.pixelRatio.toStringAsFixed(1)}x', 'sheet.png')
            : 'sheet.png',
      );
      final outputFile = File(path);
      await outputFile.create(recursive: true);
      final bytes = await pngRenderer.render(sheet);
      await outputFile.writeAsBytes(bytes);
      print('Saved spritesheet to $path.');
    }

    print('Starting rendering sprites to vector graphics...');
    for (var sprite in result.spritesheets.first.sprites) {
      final path = join(assetOutput.path, name, 'vec', sprite.name);
      final outputFile = File(path);
      await outputFile.create(recursive: true);
      await outputFile.writeAsBytes(sprite.vectorGraphics.bytes);
      print('Saved sprite to $path.');
    }

    print('Starting code generation...');
    final codeFile = File(join(codeOutput.path, '$name.g.dart'));
    final code = dartGenerator.generate(result.spritesheets, codeFile.path);
    await codeFile.create(recursive: true);
    await codeFile.writeAsString(code);
    print('Generated code for spritesheets at ${codeFile.path}.');
  } else {
    print('No spritesheets were generated.');
  }
}

