import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

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
    return package == null ? assetName : 'packages/$package/$assetName';
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

          print('Key $key');
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
      '${objectRuntimeType(this, '_ResponsiveImage')}(bundle: $bundle, name: "$keyName")';
}
