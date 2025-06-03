String buildSpriteWidgetClass() {
  return r'''
class _Sprite extends LeafRenderObjectWidget {
  const _Sprite({
    super.key,
    required this.data,
    this.size = 24,
  });

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
  })  : _source = source,
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
''';
}
