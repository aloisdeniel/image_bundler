import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'package:sprite_image/sprite_image.dart' as si;

abstract class Sprites {
  static const cloudLightning = SpriteData(0, 'cloudLightning');
  static const confetti = SpriteData(1, 'confetti');
  static const dominos = SpriteData(2, 'dominos');
  static const flowChart = SpriteData(3, 'flowChart');
  static const flutter = SpriteData(4, 'flutter');
  static const homeHeartFill = SpriteData(5, 'homeHeartFill');
  static const magicFill = SpriteData(6, 'magicFill');
  static const mailVolumeFill = SpriteData(7, 'mailVolumeFill');
  static const rocket = SpriteData(8, 'rocket');
  static const values = [
    cloudLightning,
    confetti,
    dominos,
    flowChart,
    flutter,
    homeHeartFill,
    magicFill,
    mailVolumeFill,
    rocket,
  ];
}

class Sprite extends StatelessWidget {
  const Sprite({
    super.key,
    required this.data,
    this.size,
    this.color,
    this.strategy = SpriteRenderingStrategy.auto,
  });

  final double? size;
  final SpriteData data;
  final Color? color;
  final SpriteRenderingStrategy strategy;

  Widget _build(BuildContext context, double maxWidth) {
    if (strategy == SpriteRenderingStrategy.original ||
        (strategy == SpriteRenderingStrategy.auto && maxWidth > 144)) {
      return VectorGraphic(
        loader: AssetBytesLoader('assets/sprite/vec/${data.name}'),
        width: maxWidth,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        colorFilter:
            (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
      );
    }

    const image = SpriteImage();
    final size = image.resolveSize(
      maxWidth,
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    final source = data.resolveSource(size.toDouble());
    return si.Sprite(
      image: image,
      source: source,
      color: color,
      width: maxWidth,
      height: maxWidth * (source.height / source.width),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (size case final size?) {
      return SizedBox(width: size, child: _build(context, size!));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return _build(context, constraints.maxWidth);
      },
    );
  }
}

enum SpriteRenderingStrategy { auto, original, sheet }

class SpriteData {
  const SpriteData(this.id, this.name, {this.isPng = false});
  const SpriteData.png(this.id, this.name) : this.isPng = true;
  final int id;
  final bool isPng;
  final String name;
  Rect resolveSource(double size) {
    var index = id * 4;
    switch (size) {
      case <= 24:
        index += 0;
      case <= 48:
        index += 36;
      case <= 72:
        index += 72;
      case <= 96:
        index += 108;
      case <= 144:
        index += 144;
    }
    return Rect.fromLTWH(
      _pos[index].toDouble(),
      _pos[index + 1].toDouble(),
      _pos[index + 2].toDouble(),
      _pos[index + 3].toDouble(),
    );
  }

  /// All positions are stored consecutively in a list.
  static const _pos = [
    // 0 - 24
    1,
    190,
    24,
    24,
    1,
    138,
    24,
    24,
    1,
    111,
    24,
    25,
    1,
    59,
    24,
    24,
    1,
    27,
    24,
    30,
    1,
    85,
    24,
    24,
    1,
    164,
    24,
    24,
    1,
    1,
    24,
    24,
    1,
    216,
    24,
    24,
    // 1 - 48
    1,
    364,
    48,
    48,
    1,
    264,
    48,
    48,
    1,
    213,
    48,
    49,
    1,
    113,
    48,
    48,
    1,
    51,
    48,
    60,
    1,
    163,
    48,
    48,
    1,
    314,
    48,
    48,
    1,
    1,
    48,
    48,
    1,
    414,
    48,
    48,
    // 2 - 72
    1,
    538,
    72,
    72,
    1,
    390,
    72,
    72,
    1,
    315,
    72,
    73,
    1,
    167,
    72,
    72,
    1,
    75,
    72,
    90,
    1,
    241,
    72,
    72,
    1,
    464,
    72,
    72,
    1,
    1,
    72,
    72,
    1,
    612,
    72,
    72,
    // 3 - 96
    1,
    712,
    96,
    96,
    1,
    516,
    96,
    96,
    1,
    417,
    96,
    97,
    1,
    221,
    96,
    96,
    1,
    99,
    96,
    120,
    1,
    319,
    96,
    96,
    1,
    614,
    96,
    96,
    1,
    1,
    96,
    96,
    1,
    810,
    96,
    96,
    // 4 - 144
    1,
    1059,
    144,
    144,
    1,
    767,
    144,
    144,
    1,
    620,
    144,
    145,
    1,
    328,
    144,
    144,
    1,
    147,
    144,
    179,
    1,
    474,
    144,
    144,
    1,
    913,
    144,
    144,
    1,
    1,
    144,
    144,
    1,
    1205,
    144,
    144,
  ];
}

@immutable
class AssetBundleSpriteKey {
  const AssetBundleSpriteKey({required this.bundle, required this.size});

  final AssetBundle bundle;
  final int size;

  String get name => 'assets/sprite/sheet_$size.png';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AssetBundleSpriteKey &&
        other.bundle == bundle &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(bundle, size);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AssetBundleSpriteKey')}(bundle: $bundle, size: $size)';
}

@immutable
class SpriteImage extends ImageProvider<AssetBundleSpriteKey> {
  const SpriteImage();

  static Future<void> precache(BuildContext context) {
    return Future.wait([
      precacheImage(const SpriteImage(), context, size: Size(24, 24)),
      precacheImage(const SpriteImage(), context, size: Size(48, 48)),
      precacheImage(const SpriteImage(), context, size: Size(72, 72)),
      precacheImage(const SpriteImage(), context, size: Size(96, 96)),
      precacheImage(const SpriteImage(), context, size: Size(144, 144)),
    ]);
  }

  int resolveSize(double expectedSize, {required double pixelRatio}) {
    final size = (expectedSize * pixelRatio).round();
    return switch (size) {
      > 96 => 144,
      > 72 => 96,
      > 48 => 72,
      > 24 => 48,
      _ => 24,
    };
  }

  @override
  Future<AssetBundleSpriteKey> obtainKey(ImageConfiguration configuration) {
    final resolvedSize = resolveSize(
      configuration.size?.width ?? 48.0,
      pixelRatio: configuration.devicePixelRatio ?? 1.0,
    );

    return Future.value(
      AssetBundleSpriteKey(
        bundle: configuration.bundle ?? rootBundle,
        size: resolvedSize,
      ),
    );
  }

  @override
  ImageStreamCompleter loadImage(
    AssetBundleSpriteKey key,
    ImageDecoderCallback decode,
  ) {
    InformationCollector? collector;
    assert(() {
      collector =
          () => <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<AssetBundleSpriteKey>('Image key', key),
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
    AssetBundleSpriteKey key,
    DecoderBufferCallback decode,
  ) {
    InformationCollector? collector;
    assert(() {
      collector =
          () => <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<AssetBundleSpriteKey>('Image key', key),
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
    AssetBundleSpriteKey key, {
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
