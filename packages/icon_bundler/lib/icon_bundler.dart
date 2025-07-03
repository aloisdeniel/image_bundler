import 'dart:async';
import 'dart:io';

import 'package:icon_bundler/src/code.dart';
import 'package:icon_bundler/src/options.dart';
import 'package:icon_bundler/src/renderer.dart';
import 'package:icon_bundler/src/spritesheet.dart';
import 'package:path/path.dart';

export 'src/options.dart';

Stream<IconBundlerEvent> bundleIcons(IconBundlerOptions options) async* {
  // Preparing configuration
  final spritesheets = <Spritesheet>[];
  for (var sizeVariant in options.variants) {
    final spritesheet = await Spritesheet.fromFiles(
      files: options.inputImages,
      spriteSize: sizeVariant,
    );
    spritesheets.add(spritesheet);
  }
  yield SpritesheetConfigurationCompletedEvent(spritesheets);

  // Rendering sheets to PNG
  yield SpritesheetRenderingStarted();
  final pngRenderer = SpritesheetRenderer();
  for (var i = 0; i < spritesheets.length; i++) {
    final sheet = spritesheets[i];
    final path = join(
      options.output.path,
      options.assetSheetRelativePath(sheet.spriteSize.toString(), false),
    );
    final outputFile = File(path);
    await outputFile.create(recursive: true);
    final progress = StreamController<IconBundlerEvent>.broadcast();
    final bytesFuture = pngRenderer
        .render(
          sheet,
          onStartSprite: (s) {
            progress.add(
              SpritesheetRenderingProgressEvent(
                s.sprite,
                sheet,
                s.index,
                sheet.sprites.length,
              ),
            );
          },
        )
        .then((bytes) {
          progress.close();
          return bytes;
        });
    yield* progress.stream;

    final bytes = await bytesFuture;
    await outputFile.writeAsBytes(bytes);
    yield SpritesheetRenderedEvent(
      sheet,
      outputFile,
      bytes.lengthInBytes,
      i == spritesheets.length - 1,
    );
  }
  yield SpritesheetRenderingCompleted();

  // Code generation
  yield SpritesheetCodeGenerationStarted();
  final codeGenerator = IconBundleCodeGenerator(spritesheets.first, options);
  final code = codeGenerator.build();
  final codeFile = File(
    join(options.codeOutput.path, '${options.fileName}.g.dart'),
  );
  await codeFile.create(recursive: true);
  await codeFile.writeAsString(code);
  yield SpritesheetCodeGenerationCompleted(code, codeFile);
}

sealed class IconBundlerEvent {
  const IconBundlerEvent();
}

class SpritesheetConfigurationCompletedEvent extends IconBundlerEvent {
  const SpritesheetConfigurationCompletedEvent(this.spritesheets);
  final List<Spritesheet> spritesheets;
}

class SpritesheetRenderingStarted extends IconBundlerEvent {
  const SpritesheetRenderingStarted();
}

class SpritesheetRenderingProgressEvent extends IconBundlerEvent {
  const SpritesheetRenderingProgressEvent(
    this.nextSprite,
    this.spritesheet,
    this.index,
    this.total,
  );
  final Spritesheet spritesheet;
  final Sprite nextSprite;
  final int index;
  final int total;
  double get progress => index / total;
}

class SpritesheetRenderedEvent extends IconBundlerEvent {
  const SpritesheetRenderedEvent(
    this.spritesheet,
    this.file,
    this.sizeInBytes,
    this.isLast,
  );
  final Spritesheet spritesheet;
  final File file;
  final int sizeInBytes;
  final bool isLast;
}

class SpritesheetRenderingCompleted extends IconBundlerEvent {
  const SpritesheetRenderingCompleted();
}

class SpritesheetCodeGenerationStarted extends IconBundlerEvent {
  const SpritesheetCodeGenerationStarted();
}

class SpritesheetCodeGenerationCompleted extends IconBundlerEvent {
  const SpritesheetCodeGenerationCompleted(this.code, this.file);
  final String code;
  final File file;
}
