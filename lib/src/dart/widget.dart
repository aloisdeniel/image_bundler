import 'dart:math';

import 'package:svg_bundler/src/dart/generator.dart';

String buildWidgetClass(CompiledSpritesheet sheet) {
  final maxSize = sheet.sizes.fold(0, max);
  return '''class Icon extends StatelessWidget {
  const Icon({super.key, required this.data, this.size = 24, this.color});

  final double size;
  final SpriteData data;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (size > $maxSize) {
      return VectorGraphic(
        loader: AssetBytesLoader('assets/icon/vec/\${data.name}'),
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
}''';
}
