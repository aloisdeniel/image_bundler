import 'dart:io';

import 'package:image_bundler/src/utils/naming.dart';
import 'package:path/path.dart';
import 'package:image_bundler/src/geometry.dart';

class SheetVariantOptions {
  const SheetVariantOptions({
    required this.pixelRatio,
    required this.spriteWidth,
    required this.sheetSize,
    required this.name,
  });
  final double pixelRatio;
  final int spriteWidth;
  final Size sheetSize;
  final String name;
}

class SvgBundlerOptions {
  SvgBundlerOptions({
    required this.name,
    required this.inputSvgs,
    required this.output,
    required this.variants,
    this.assetRelativePath = 'assets/',
    this.codeRelativePath = 'lib/src/widgets/',
    this.package,
  });
  final List<SheetVariantOptions> variants;
  final List<File> inputSvgs;
  final String name;
  final String? package;
  final Directory output;
  final String assetRelativePath;
  final String codeRelativePath;
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
  String assetSheetRelativePath(double pixelRatio, int size) => join(
    assetRelativePath,
    fileName,
    pixelRatio != 1.0
        ? join('${pixelRatio.toStringAsFixed(1)}x', 'sheet_$size.png')
        : 'sheet_$size.png',
  );
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
