import 'dart:math';

import 'package:svg_bundler/src/dart/generator.dart';

String buildWidgetClass(CompiledSpritesheet sheet) {
  final maxSize = sheet.options.sizeVariants.fold(0, max);
  final vecPath = sheet.options.assetVecRelativePath('\${data.name}');
  final strategy = '${sheet.options.widgetClassName}RenderingStrategy';
  return '''class ${sheet.options.widgetClassName} extends StatelessWidget {
  const ${sheet.options.widgetClassName}({super.key, required this.data, this.size, this.color, this.strategy = $strategy.auto,});

  final double? size;
  final ${sheet.options.dataClassName} data;
  final Color? color;
  final $strategy strategy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LayoutBuilder(
        builder: (context, constraints) {
        if (strategy == $strategy.vector || (strategy == $strategy.auto && constraints.maxWidth > $maxSize)) {
          return VectorGraphic(
            loader: AssetBytesLoader('$vecPath'),
            width: constraints.maxWidth,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            colorFilter:
                (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
          );
        }
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        final resolved = data.resolve(constraints.maxWidth, pixelRatio);
        return Sprite(
          image: resolved.\$2,
          source: resolved.\$1,
          color: color,
        );
      }),
    );
  }
}

enum $strategy {
  auto,
  vector,
  raster,
}


/// Base on [AssetImage].
class ResponsiveAssetImage extends AssetBundleImageProvider {
  const ResponsiveAssetImage(
    this.assetNameForSize, {
    this.bundle,
    this.package,
  });

  final Map<int, String> assetNameForSize;

  String keyName(int size) {
    final assetName = assetNameForSize[size]!;
    return package == null ? assetName : 'packages/\$package/\$assetName';
  }

  int getVariantSize(double width) {
    final sizes = this.assetNameForSize.keys.toList()..sort();
    for (var i = 0; i < sizes.length; i++) {
      final s = sizes[i];

      if (width <= s) {
        return s;
      }
    }
    return sizes.last;
  }

  final AssetBundle? bundle;
  final String? package;
  static const double _naturalResolution = 1.0;

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    final size = getVariantSize(configuration.size?.width ?? double.infinity);
    final keyName = this.keyName(size);
    final AssetBundle chosenBundle =
        bundle ?? configuration.bundle ?? rootBundle;
    Completer<AssetBundleImageKey>? completer;
    Future<AssetBundleImageKey>? result;

    AssetManifest.loadFromAssetBundle(chosenBundle)
        .then((AssetManifest manifest) {
          final Iterable<AssetMetadata>? candidateVariants = manifest
              .getAssetVariants(keyName);
          final AssetMetadata chosenVariant = _chooseVariant(
            keyName,
            configuration,
            candidateVariants,
          );
          final AssetBundleImageKey key = AssetBundleImageKey(
            bundle: chosenBundle,
            name: chosenVariant.key,
            scale: chosenVariant.targetDevicePixelRatio ?? _naturalResolution,
          );

          if (completer != null) {
            completer.complete(key);
          } else {
            result = SynchronousFuture<AssetBundleImageKey>(key);
          }
        })
        .onError((Object error, StackTrace stack) {
          assert(completer != null);
          assert(result == null);
          completer!.completeError(error, stack);
        });

    if (result != null) {
      return result!;
    }
    completer = Completer<AssetBundleImageKey>();
    return completer.future;
  }

  AssetMetadata _chooseVariant(
    String mainAssetKey,
    ImageConfiguration config,
    Iterable<AssetMetadata>? candidateVariants,
  ) {
    if (candidateVariants == null ||
        candidateVariants.isEmpty ||
        config.devicePixelRatio == null) {
      return AssetMetadata(
        key: mainAssetKey,
        targetDevicePixelRatio: null,
        main: true,
      );
    }

    final SplayTreeMap<double, AssetMetadata> candidatesByDevicePixelRatio =
        SplayTreeMap<double, AssetMetadata>();
    for (final AssetMetadata candidate in candidateVariants) {
      candidatesByDevicePixelRatio[candidate.targetDevicePixelRatio ??
              _naturalResolution] =
          candidate;
    }

    return _findBestVariant(
      candidatesByDevicePixelRatio,
      config.devicePixelRatio!,
    );
  }

  AssetMetadata _findBestVariant(
    SplayTreeMap<double, AssetMetadata> candidatesByDpr,
    double value,
  ) {
    if (candidatesByDpr.containsKey(value)) {
      return candidatesByDpr[value]!;
    }
    final double? lower = candidatesByDpr.lastKeyBefore(value);
    final double? upper = candidatesByDpr.firstKeyAfter(value);
    if (lower == null) {
      return candidatesByDpr[upper]!;
    }
    if (upper == null) {
      return candidatesByDpr[lower]!;
    }

    const double kLowDprLimit = 2.0;
    if (value < kLowDprLimit || value > (lower + upper) / 2) {
      return candidatesByDpr[upper]!;
    } else {
      return candidatesByDpr[lower]!;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AssetImage &&
        other.keyName == keyName &&
        other.bundle == bundle;
  }

  @override
  int get hashCode => Object.hash(keyName, bundle);

  @override
  String toString() =>
      '\${objectRuntimeType(this, '_ResponsiveImage')}(bundle: \$bundle, name: "\$keyName")';
}
''';
}
