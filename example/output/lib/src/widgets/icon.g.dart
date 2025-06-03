import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

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

class Icon extends StatelessWidget {
  const Icon({super.key, required this.data, this.size = 24, this.color});

  final double size;
  final SpriteData data;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (size > 48) {
      return VectorGraphic(
        loader: AssetBytesLoader('assets/icon/vec/${data.name}'),
        height: size,
        width: size,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        colorFilter:
            (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
      );
    }
    Widget result = _Sprite(data: data, size: size);
    if (color != null) {
      result = ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: result,
      );
    }
    return result;
  }
}

class SpriteData {
  const SpriteData(this.id, this.name);
  final int id;
  final String name;
  // This image is shared between all sprites.
  static ImageProvider image = const AssetImage(
    'output/lib/src/widgets/icon.g.dart',
  );
  Rect resolve(double size, double pixelRatio) {
    var index = id * 2;
    double resolvedSize = 48.0;
    switch (size) {
      case <= 24:
        index += 0;
        resolvedSize = 24.0;
      case <= 48:
        index += 18;
        resolvedSize = 48.0;
    }
    switch (pixelRatio) {
      case <= 1.0:
        index += 0;
        resolvedSize *= 1.0;
      case <= 2.0:
        index += 36;
        resolvedSize *= 2.0;
      case <= 3.0:
        index += 72;
        resolvedSize *= 3.0;
    }
    return Rect.fromLTWH(
      _pos[index].toDouble(),
      _pos[index + 1].toDouble(),
      resolvedSize,
      resolvedSize,
    );
  }

  /// All positions are stored consecutively in a list.
  static const _pos = [
    176,
    1,
    343,
    26,
    126,
    1,
    245,
    26,
    76,
    1,
    147,
    26,
    26,
    1,
    49,
    26,
    101,
    1,
    196,
    26,
    51,
    1,
    98,
    26,
    151,
    1,
    294,
    26,
    1,
    1,
    0,
    26,
    201,
    1,
    392,
    26,
    344,
    1,
    679,
    50,
    246,
    1,
    485,
    50,
    148,
    1,
    291,
    50,
    50,
    1,
    97,
    50,
    197,
    1,
    388,
    50,
    99,
    1,
    194,
    50,
    295,
    1,
    582,
    50,
    1,
    1,
    0,
    50,
    393,
    1,
    776,
    50,
    512,
    1,
    1015,
    74,
    366,
    1,
    725,
    74,
    220,
    1,
    435,
    74,
    74,
    1,
    145,
    74,
    293,
    1,
    580,
    74,
    147,
    1,
    290,
    74,
    439,
    1,
    870,
    74,
    1,
    1,
    0,
    74,
    585,
    1,
    1160,
    74,
  ];
}

class _Sprite extends LeafRenderObjectWidget {
  const _Sprite({super.key, required this.data, this.size = 24});

  final double size;
  final SpriteData data;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return _RenderSprite(
      image: SpriteData.image,
      source: data.resolve(size, pixelRatio),
      sizeValue: size,
    )..resolveImage(context);
  }

  @override
  // ignore: library_private_types_in_public_api
  void updateRenderObject(BuildContext context, _RenderSprite renderObject) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    renderObject
      ..imageProvider = SpriteData.image
      ..source = data.resolve(size, pixelRatio)
      ..sizeValue = size
      ..resolveImage(context);
  }
}

class _RenderSprite extends RenderBox {
  _RenderSprite({
    required ImageProvider image,
    required Rect source,
    required double sizeValue,
  }) : _source = source,
       _imageProvider = image,
       _sizeValue = sizeValue;

  ImageProvider _imageProvider;
  Rect _source;
  double _sizeValue;

  set sizeValue(double value) {
    if (_sizeValue == value) return;
    _sizeValue = value;
    markNeedsLayout();
  }

  set source(Rect value) {
    if (_source == value) return;
    _source = value;
    markNeedsPaint();
  }

  set imageProvider(ImageProvider value) {
    if (_imageProvider == value) return;
    _imageProvider = value;
    markNeedsPaint();
  }

  ui.Image? _image;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  void resolveImage(BuildContext context) {
    final ImageStream newStream = _imageProvider.resolve(
      createLocalImageConfiguration(context),
    );

    if (_imageStream?.key == newStream.key) return;

    _imageStream?.removeListener(_listener!);

    _listener = ImageStreamListener((
      ImageInfo imageInfo,
      bool synchronousCall,
    ) {
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
    size = constraints.constrain(Size.square(_sizeValue));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_image == null) return;

    final canvas = context.canvas;

    final dst = offset & size;
    canvas.drawImageRect(_image!, _source, dst, Paint());
  }
}
