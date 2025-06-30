import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart'
    hide Color;

abstract class Canvas {
  factory Canvas.create(int width, int height) {
    return _ResvgCanvas(width: width, height: height);
  }

  Canvas({required this.width, required this.height});
  final int width;
  final int height;
  late var image = Image(
    width: width,
    height: height,
    format: Format.int8,
    numChannels: 4,
    backgroundColor: ColorRgba8(0, 0, 0, 0),
  );

  /// Paints the given SVG image at the given coordinates.
  Future<void> paintSvg(
    String svgContent,
    VectorInstructions instructions,
    double x,
    double y,
    double width,
    double height,
    double scaleX,
    double scaleY,
  );

  /// Paints the given Png image at the given coordinates.
  Future<void> paintImage(
    Image image,
    double x,
    double y,
    double width,
    double height,
    double scaleX,
    double scaleY,
  ) async {
    this.image = compositeImage(
      this.image,
      image,
      dstX: x.toInt(),
      dstY: y.toInt(),
      dstW: width.toInt(),
      dstH: height.toInt(),
    );
  }

  Future<Uint8List> toImage() async {
    return encodePng(image);
  }
}

// Ideally we would want to use FFI binding instead of CLI call.
class _ResvgCanvas extends Canvas {
  _ResvgCanvas({required super.width, required super.height});

  @override
  Future<void> paintSvg(
    String svgContent,
    VectorInstructions instructions,
    double x,
    double y,
    double width,
    double height,
    double scaleX,
    double scaleY,
  ) async {
    final process = await Process.start('resvg', [
      '-',
      '-c',
      '-w',
      width.toInt().toString(),
      '-h',
      height.toInt().toString(),
      '--resources-dir',
      current,
    ]);
    final completer = Completer<Uint8List>();
    final output = <int>[];
    process.stdout.listen(
      (chunk) {
        output.addAll(chunk);
      },
      onError: (e) {
        completer.completeError(e);
      },
      onDone: () {
        completer.complete(Uint8List.fromList(output));
      },
    );
    process.stderr.listen((data) {
      print('Error: ${utf8.decode(data)}');
      completer.completeError(data);
      process.kill();
    });
    process.stdin.writeln(svgContent.replaceAll('\n', ''));
    await process.stdin.close();

    // Adding to sheet
    final result = await completer.future;
    final decoded = decodePng(Uint8List.fromList(result));
    paintImage(decoded!, x, y, width, height, scaleX, scaleY);
  }

  @override
  Future<Uint8List> toImage() async {
    return encodePng(image);
  }
}
