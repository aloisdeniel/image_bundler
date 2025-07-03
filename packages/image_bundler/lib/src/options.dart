import 'dart:io';

import 'package:image_bundler/src/utils/naming.dart';
import 'package:path/path.dart';
import 'package:image_bundler/src/geometry.dart';

class SheetVariantOptions {
  const SheetVariantOptions({
    required this.spriteWidth,
    required this.sheetSize,
  });
  final int spriteWidth;
  final Size sheetSize;
}

class SvgBundlerOptions {
  SvgBundlerOptions({
    required this.name,
    required this.inputImages,
    required this.output,
    required this.variants,
    this.includeOriginal = true,
    this.assetRelativePath = 'assets/',
    this.codeRelativePath = 'lib/src/widgets/',
    this.package,
  }) {
    variants.sort((x, y) => x.spriteWidth.compareTo(y.spriteWidth));
  }

  /// All the variants for the spritesheet.
  final List<SheetVariantOptions> variants;

  /// The input files.
  final List<File> inputImages;

  /// The base name for the spritesheet and all generated types.
  final String name;

  /// The package name for the assets, if any.
  final String? package;

  /// The output directory for the generated code and assets.
  final Directory output;

  /// The relative path for assets in the output directory.
  final String assetRelativePath;

  /// The relative path for generated code in the output directory.
  final String codeRelativePath;

  /// Whether to include the original vector graphics or raster image files in the output.
  ///
  /// If false, the rendered image might look pixelated in bigger sizes than the maximum sheet sprite size,
  /// but the app bundle size is smaller.
  final bool includeOriginal;

  late String fileName = Naming.fileName(name);
  late String fieldName = Naming.fieldName(name);
  late String typeName = Naming.className(name);
  late String widgetClassName = typeName;
  late String dataClassName = '${typeName}Data';
  late String dataCollectionClassName = '${typeName}s';
  late final codeOutput = Directory(join(output.path, codeRelativePath));
  late final assetOutput = Directory(join(output.path, assetRelativePath));
  late final widgetCodeRelativePath = join(
    codeRelativePath,
    '$fileName.g.dart',
  );
  String assetSheetRelativePath(String size) =>
      join(assetRelativePath, fileName, 'sheet_$size.png');
  String assetRasterRelativePath(String name, double pixelRatio) => join(
    assetRelativePath,
    fileName,
    pixelRatio != 1.0
        ? join('${pixelRatio.toStringAsFixed(1)}x', '$name.png')
        : '$name.png',
  );
  String assetVecRelativePath(String name) =>
      join(assetRelativePath, fileName, 'vec', name);
}
