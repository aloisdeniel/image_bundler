import 'package:image_bundler/src/dart/generator.dart';
import 'package:path/path.dart';

String buildImageClass(CompiledSpritesheet sheet) {
  final key = 'AssetBundle${sheet.options.typeName}Key';
  final img = '${sheet.options.typeName}Image';
  var sheetPath = sheet.options.assetSheetRelativePath('\$size');
  if (sheet.options.package case final p?) {
    sheetPath = join('packages', p, sheetPath);
  }
  final widths = sheet.spriteWidths.toList()..sort((x, y) => y.compareTo(x));
  var resolved = '';
  for (var i = 1; i < widths.length; i++) {
    final wp = widths[i - 1];
    final w = widths[i];
    resolved += '  > $w => $wp,\n';
  }
  resolved += '  _ => ${widths.last},\n';

  // Precache function
  final precache = StringBuffer();
  precache.writeln('  static Future<void> precache(BuildContext context) {');
  precache.writeln('    return Future.wait([');

  for (var size in sheet.spriteWidths) {
    precache.writeln(
      '      precacheImage(const $img(), context, size: Size($size,$size)),',
    );
  }
  precache.writeln('    ]);');
  precache.writeln('  }');
  return '''
@immutable
class $key {
  const $key({required this.bundle, required this.size});

  final AssetBundle bundle;
  final int size;

  String get name => '$sheetPath';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is $key &&
        other.bundle == bundle &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(bundle, size);

  @override
  String toString() =>
      '\${objectRuntimeType(this, '$key')}(bundle: \$bundle, size: \$size)';
}

@immutable
class $img extends ImageProvider<$key> {
  const $img();

  $precache

  int resolveSize(
    double expectedSize, {
    required double pixelRatio,
  }) {
    final size = (expectedSize * pixelRatio).round();
    return switch (size) {
      $resolved
    };
  }

  @override
  Future<$key> obtainKey(ImageConfiguration configuration) {
    final resolvedSize = resolveSize(
      configuration.size?.width ?? 48.0,
      pixelRatio: configuration.devicePixelRatio ?? 1.0,
    );

    return Future.value(
      $key(
        bundle: configuration.bundle ?? rootBundle,
        size: resolvedSize,
      ),
    );
  }

  @override
  ImageStreamCompleter loadImage(
      $key key, ImageDecoderCallback decode) {
    InformationCollector? collector;
    assert(() {
      collector = () => <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<$key>('Image key', key),
          ];
      return true;
    }());
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: 1,
      debugLabel: key.name,
      informationCollector: collector,
    );
  }

  /// Converts a key into an [ImageStreamCompleter], and begins fetching the
  /// image.
  @override
  ImageStreamCompleter loadBuffer(
      $key key, DecoderBufferCallback decode) {
    InformationCollector? collector;
    assert(() {
      collector = () => <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<$key>('Image key', key),
          ];
      return true;
    }());
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: 1,
      debugLabel: key.name,
      informationCollector: collector,
    );
  }

  @protected
  Future<ui.Codec> _loadAsync(
    $key key, {
    required Future<ui.Codec> Function(ui.ImmutableBuffer buffer) decode,
  }) async {
    final ui.ImmutableBuffer buffer;
    try {
      buffer = await key.bundle.loadBuffer(key.name);
    } on FlutterError {
      PaintingBinding.instance.imageCache.evict(key);
      rethrow;
    }
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
''';
}
