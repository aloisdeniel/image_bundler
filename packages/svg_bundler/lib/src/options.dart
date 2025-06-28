import 'dart:io';

import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:svg_bundler/src/geometry.dart';

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
  });
  final List<SheetVariantOptions> variants;
  final List<File> inputSvgs;
  final String name;

  final Directory output;
  final String assetRelativePath;
  final String codeRelativePath;
  late String fileName = ReCase(name).snakeCase;
  late String fieldName = ReCase(name).camelCase;
  late String typeName = ReCase(name).pascalCase;
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
  String assetVecRelativePath(String name) =>
      join(assetRelativePath, fileName, 'vec', name);
}
