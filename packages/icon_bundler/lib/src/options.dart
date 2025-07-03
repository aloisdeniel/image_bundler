import 'dart:io';

import 'package:icon_bundler/src/naming.dart';
import 'package:path/path.dart';

class IconBundlerOptions {
  IconBundlerOptions({
    required this.name,
    required this.inputImages,
    required this.output,
    required this.variants,
    this.assetRelativePath = 'assets/',
    this.codeRelativePath = 'lib/src/widgets/',
    this.package,
  }) {
    variants.sort((x, y) => x.compareTo(y));
  }

  /// All the size variants for the spritesheet.
  final List<int> variants;

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

  String assetSheetRelativePath(String size, bool includePackage) {
    final result = join(assetRelativePath, fileName, 'sheet_$size.png');
    if (includePackage && package != null) {
      return join('packages', package!, result);
    }
    return result;
  }
}
