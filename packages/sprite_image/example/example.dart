import 'package:flutter/widgets.dart';
import 'package:sprite_image/sprite_image.dart';

Widget build(BuildContext context) {
  return Sprite.asset(
    'assets/sprite.png',
    source: Offset(24, 24) & Size(64, 64), // The subpart of the image to render
    width: 64,
    height: 64,
  );
}
