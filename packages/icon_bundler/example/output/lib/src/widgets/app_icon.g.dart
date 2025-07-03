import 'package:flutter/material.dart';

import 'package:sprite_image/sprite_image.dart' as si;

abstract class AppIcons {
  static const cloudLightning = AppIconData(0, 'cloudLightning');
  static const confetti = AppIconData(1, 'confetti');
  static const dominos = AppIconData(2, 'dominos');
  static const flowChart = AppIconData(3, 'flowChart');
  static const flutter = AppIconData(4, 'flutter');
  static const homeHeartFill = AppIconData(5, 'homeHeartFill');
  static const magicFill = AppIconData(6, 'magicFill');
  static const mailVolumeFill = AppIconData(7, 'mailVolumeFill');
  static const rocket = AppIconData(8, 'rocket');
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


class AppIcon extends StatelessWidget {
  const AppIcon({super.key, required this.data, this.size, this.color});

  final double? size;
  final AppIconData data;
  final Color? color;

  static Future<void> precache(BuildContext context) {
    return Future.wait([
      precacheImage(const AssetImage('assets/app_icon/sheet_24.png'), context),
      precacheImage(const AssetImage('assets/app_icon/sheet_48.png'), context),
      precacheImage(const AssetImage('assets/app_icon/sheet_72.png'), context),
      precacheImage(const AssetImage('assets/app_icon/sheet_96.png'), context),
      precacheImage(const AssetImage('assets/app_icon/sheet_144.png'), context),
    ]);
  }

  int resolveSize(
    double expectedSize, {
    required double pixelRatio,
  }) {
    final size = (expectedSize * pixelRatio).round();
    return switch (size) {
        > 96 => 144,
        > 72 => 96,
        > 48 => 72,
        > 24 => 48,
        _ => 24,

    };
  }

  Widget _build(BuildContext context, double maxWidth) {
    final size = resolveSize(
      maxWidth,
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    );

    final sizeWithMargin = size + 2;
    final source = Rect.fromLTWH(
      1.0 + sizeWithMargin * (data.id % 3),
      1.0 + sizeWithMargin * (data.id ~/ 3),
      size.toDouble(),
      size.toDouble(),
    );
    return si.Sprite(
      image: AssetImage('assets/app_icon/sheet_$size.png'),
      source: source,
      color: color,
      width: maxWidth,
      height: maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (size case final size?) {
      return SizedBox(
        width: size,
        child: _build(context, size),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return _build(context, constraints.maxWidth);
      },
    );
  }
}


class AppIconData {
  const AppIconData(this.id, this.name);
  final int id;
  final String name;
}

