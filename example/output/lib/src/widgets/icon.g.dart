import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

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
  const Icon({super.key, required this.data, this.size, this.color, this.strategy = IconRenderingStrategy.auto,});

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
        if (strategy == IconRenderingStrategy.vector || (strategy == IconRenderingStrategy.auto && constraints.maxWidth > 48)) {
          return VectorGraphic(
            loader: AssetBytesLoader('assets/icon/vec/${data.name}'),
            fit: BoxFit.contain,
            alignment: Alignment.center,
            colorFilter:
                (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
          );
        }
        Widget result = _Sprite(data: data);
        if (color != null) {
          result = ColorFiltered(
            colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
            child: result,
          );
        }
        return result;
      }),
    );
  }
}

enum IconRenderingStrategy {
  auto,
  vector,
  raster,
}

class IconData {
  const IconData(this.id, this.name);
  final int id;
  final String name;
  // This image is shared between all sprites.
  static ImageProvider image24 = const AssetImage('assets/icon/sheet_24.png');
  static ImageProvider image48 = const AssetImage('assets/icon/sheet_48.png');
  (Rect,ImageProvider) resolve(double size, double pixelRatio) {
    var index = id * 2;
    double resolvedSize = 48.0;
    var image = image48;
    switch (size) {
      case <= 24:
        image = image24;
        resolvedSize = 24.0;
        index += switch (pixelRatio) {
          <= 1.0 => 0,
          <= 2.0 => 36,
          _ => 72,
        };
      case <= 48:
        image = image48;
        resolvedSize = 48.0;
        index += switch (pixelRatio) {
          <= 1.0 => 18,
          <= 2.0 => 54,
          _ => 90,
        };
    }
    return (Rect.fromLTWH(
      _pos[index].toDouble(),
      _pos[index + 1].toDouble(),
      resolvedSize,
      resolvedSize,
    ), image);
  }
  /// All positions are stored consecutively in a list.
  static const _pos = [
    1, 1, 26, 1, 51, 1, 76, 1, 101, 1, 126, 1, 151, 1, 176, 1, 201, 1, 1, 1, 50, 1, 99, 1, 148, 1, 197, 1, 246, 1, 295, 1, 344, 1, 393, 1, 1, 1, 50, 1, 99, 1, 148, 1, 197, 1, 246, 1, 295, 1, 344, 1, 393, 1, 1, 1, 98, 1, 195, 1, 292, 1, 389, 1, 486, 1, 583, 1, 680, 1, 777, 1, 1, 1, 74, 1, 147, 1, 220, 1, 293, 1, 366, 1, 439, 1, 512, 1, 585, 1, 1, 1, 146, 1, 291, 1, 436, 1, 581, 1, 726, 1, 871, 1, 1016, 1, 1161, 1,
  ];
}


class _Sprite extends LeafRenderObjectWidget {
  const _Sprite({
    super.key,
    required this.data,
  });

  final IconData data;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSprite(
      data: data,
    )..resolveImage(context);
  }

  @override
  // ignore: library_private_types_in_public_api
  void updateRenderObject(BuildContext context, _RenderSprite renderObject) {
    renderObject
      ..data = data
      ..resolveImage(context);
  }
}

class _RenderSprite extends RenderBox {
  _RenderSprite({
    required IconData data,
  })  : _data = data;

  IconData _data;

  set data(IconData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  ui.Image? _image;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  Rect _source = Rect.zero;

  void resolveImage(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final config = createLocalImageConfiguration(context);
    final (source, provider) = _data.resolve(_sizeValue, pixelRatio);
    _source = source;
    final ImageStream newStream = provider.resolve(config);

    if (_imageStream?.key == newStream.key) return;

    _imageStream?.removeListener(_listener!);

    _listener =
        ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      _image = imageInfo.image;
      markNeedsPaint();
    });

    _imageStream = newStream;
    _imageStream!.addListener(_listener!);
  }

  @override
  void detach() {
    _imageStream?.removeListener(_listener!);
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_image == null) return;

    final canvas = context.canvas;

    final dst = offset & size;
    canvas.drawImageRect(_image!, _source, dst, Paint());
  }
}

