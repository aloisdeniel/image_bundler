import 'dart:io';

import 'package:svg_bundler/svg_bundler.dart';

void main(List<String> arguments) async {
  final files = bundleSvgs(
    pixelRatios: [1.0, 2.0, 3.0],
    input: Directory('input'),
    name: 'icon',
    output: Directory('output/'),
  );

  await for (var element in files) {
    print(element.join(', '));
  }
}
