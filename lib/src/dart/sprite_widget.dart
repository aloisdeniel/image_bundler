import 'package:svg_bundler/src/dart/generator.dart';

String buildSpriteWidgetClass(CompiledSpritesheet sheet) {
  return '''
class _Sprite extends LeafRenderObjectWidget {
  const _Sprite({
    super.key,
    required this.data,
  });

  final ${sheet.options.dataClassName} data;

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
    required ${sheet.options.dataClassName} data,
  })  : _data = data;

  ${sheet.options.dataClassName} _data;

  set data(${sheet.options.dataClassName} value) {
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
''';
}
