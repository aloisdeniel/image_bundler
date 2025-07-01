import 'dart:math';

import 'package:image_bundler/src/dart/generator.dart';

String buildWidgetClass(CompiledSpritesheet sheet) {
  final maxSize = sheet.options.variants.map((x) => x.spriteWidth).fold(0, max);
  final vecPath = sheet.options.assetVecRelativePath('\${data.name}');
  final strategy = '${sheet.options.widgetClassName}RenderingStrategy';
  return '''class ${sheet.options.widgetClassName} extends StatelessWidget {
  const ${sheet.options.widgetClassName}({super.key, required this.data, this.size, this.color, this.strategy = $strategy.auto,});

  final double? size;
  final ${sheet.options.dataClassName} data;
  final Color? color;
  final $strategy strategy;


  Widget _build(BuildContext context, double maxWidth) {
    if (strategy == $strategy.vector || (strategy == $strategy.auto && maxWidth > $maxSize)) {
      return VectorGraphic(
        loader: AssetBytesLoader('$vecPath'),
        width: maxWidth,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        colorFilter:
            (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
      );
    }
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final resolved = data.resolve(maxWidth, pixelRatio);
    return si.Sprite(
      image: resolved.\$2,
      source: resolved.\$1,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (size case final size?) {
      return SizedBox(
        width: size,
        child: _build(context, size!),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return _build(context, constraints.maxWidth);
      },
    );
  }
}

enum $strategy {
  auto,
  vector,
  raster,
}''';
}
