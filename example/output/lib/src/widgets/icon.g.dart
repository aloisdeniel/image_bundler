import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'sprite.dart';

abstract class Icons {
  static const cloudLightning = IconData(0, 'cloudLightning');
  static const confetti = IconData(1, 'confetti');
  static const dominos = IconData(2, 'dominos');
  static const flowChart = IconData(3, 'flowChart');
  static const flutter = IconData(4, 'flutter');
  static const homeHeartFill = IconData(5, 'homeHeartFill');
  static const magicFill = IconData(6, 'magicFill');
  static const mailVolumeFill = IconData(7, 'mailVolumeFill');
  static const rocket = IconData(8, 'rocket');
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

class Icon extends StatelessWidget {
  const Icon({
    super.key,
    required this.data,
    this.size,
    this.color,
    this.strategy = IconRenderingStrategy.auto,
  });

  final double? size;
  final IconData data;
  final Color? color;
  final IconRenderingStrategy strategy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (strategy == IconRenderingStrategy.vector ||
              (strategy == IconRenderingStrategy.auto &&
                  constraints.maxWidth > 48)) {
            return VectorGraphic(
              loader: AssetBytesLoader('assets/icon/vec/${data.name}'),
              width: constraints.maxWidth,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              colorFilter:
                  (color != null
                      ? ColorFilter.mode(color!, BlendMode.srcIn)
                      : null),
            );
          }
          final pixelRatio = MediaQuery.devicePixelRatioOf(context);
          final resolved = data.resolve(constraints.maxWidth, pixelRatio);
          return Sprite(image: resolved.$2, source: resolved.$1, color: color);
        },
      ),
    );
  }
}

enum IconRenderingStrategy { auto, vector, raster }

class IconData {
  const IconData(this.id, this.name);
  final int id;
  final String name;
  // This image is shared between all sprites.
  static ImageProvider image24 = const AssetImage('assets/icon/sheet_24.png');
  static ImageProvider image48 = const AssetImage('assets/icon/sheet_48.png');
  (Rect, ImageProvider) resolve(double size, double pixelRatio) {
    var index = id * 4;
    double resolvedSize = 48.0;
    var image = image48;
    switch (size) {
      case <= 24:
        image = image24;
        resolvedSize = 24.0;
        index += switch (pixelRatio) {
          <= 1.0 => 0,
          <= 2.0 => 72,
          _ => 144,
        };
      case <= 48:
        image = image48;
        resolvedSize = 48.0;
        index += switch (pixelRatio) {
          <= 1.0 => 36,
          <= 2.0 => 108,
          _ => 180,
        };
    }
    return (
      Rect.fromLTWH(
        _pos[index].toDouble(),
        _pos[index + 1].toDouble(),
        _pos[index + 2].toDouble(),
        _pos[index + 3].toDouble(),
      ),
      image,
    );
  }

  /// All positions are stored consecutively in a list.
  static const _pos = [
    105,
    1,
    24,
    24,
    27,
    27,
    24,
    24,
    79,
    1,
    24,
    25,
    27,
    1,
    24,
    24,
    1,
    27,
    24,
    24,
    53,
    1,
    24,
    24,
    53,
    27,
    24,
    24,
    1,
    1,
    24,
    24,
    131,
    1,
    24,
    24,
    201,
    1,
    48,
    48,
    51,
    51,
    48,
    48,
    151,
    1,
    48,
    49,
    51,
    1,
    48,
    48,
    1,
    51,
    48,
    48,
    101,
    1,
    48,
    48,
    101,
    51,
    48,
    48,
    1,
    1,
    48,
    48,
    251,
    1,
    48,
    48,
    201,
    1,
    48,
    48,
    51,
    51,
    48,
    48,
    151,
    1,
    48,
    49,
    51,
    1,
    48,
    48,
    1,
    51,
    48,
    48,
    101,
    1,
    48,
    48,
    101,
    51,
    48,
    48,
    1,
    1,
    48,
    48,
    251,
    1,
    48,
    48,
    393,
    1,
    96,
    96,
    99,
    99,
    96,
    96,
    295,
    1,
    96,
    97,
    99,
    1,
    96,
    96,
    1,
    99,
    96,
    96,
    197,
    1,
    96,
    96,
    197,
    99,
    96,
    96,
    1,
    1,
    96,
    96,
    491,
    1,
    96,
    96,
    297,
    1,
    72,
    72,
    75,
    75,
    72,
    72,
    223,
    1,
    72,
    73,
    75,
    1,
    72,
    72,
    1,
    75,
    72,
    72,
    149,
    1,
    72,
    72,
    149,
    75,
    72,
    72,
    1,
    1,
    72,
    72,
    371,
    1,
    72,
    72,
    585,
    1,
    144,
    144,
    147,
    147,
    144,
    144,
    439,
    1,
    144,
    145,
    147,
    1,
    144,
    144,
    1,
    147,
    144,
    144,
    293,
    1,
    144,
    144,
    293,
    147,
    144,
    144,
    1,
    1,
    144,
    144,
    731,
    1,
    144,
    144,
  ];
}
