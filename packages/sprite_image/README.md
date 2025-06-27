# sprite_image

A widget that renders a subpart of an image.

## Quickstart

```dart
@override 
Widget build(BuildContext context) {
return SpriteImage.asset(
        'assets/sprite.png',
        source: Offset(24,24) & Size(64, 64), // The subpart of the image to render
        width: 64,
        height: 64,
    );
}
```
