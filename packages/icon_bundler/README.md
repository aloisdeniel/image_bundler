# Icon Bundler

[![pub package](https://img.shields.io/pub/v/icon_bundler.svg)](https://pub.dev/packages/icon_bundler)

Bundle a collection of svg, png, jpg files as a single image containing all the icons.

# Install

```sh
brew install resvg # required for SVG rendering
flutter pub global activate icon_bundler
```

# Usage

## Command Line arguments

```sh
-s, --sizes                  Comma-separated list of sizes, e.g. 24,48
-n, --name                   Name of the spritesheet and generated classes.
                             (defaults to "app_icon")
-p, --package                Name of the package to add it to generated image providers.
-r, --pixel-ratios           Comma-separated list of pixel ratios to generate spritesheets for.
                             (defaults to "1.0,2.0,3.0")
-i, --input                  Directory containing SVG files to bundle.
                             (defaults to ".")
-o, --output                 Directory to output the generated spritesheets and code.
                             (defaults to ".")
-a, --asset-relative-path    Relative path for assets in the output directory.
                             (defaults to "assets/")
-c, --code-relative-path     Relative path for generated code in the output directory.
                             (defaults to "lib/src/widgets/")
-h, --[no-]help              Show help.
```

## Generated Code

Once generated, you can simply use the resulting widget with its associated data.

# Example

[Input files](../example/input/):

<table>
  <tr>
    <td><img src="https://github.com/aloisdeniel/image_bundler/blob/main/packages/icon_bundler/example/input/cloud-lightning.svg" width="64"></td>
    <td><img src="https://github.com/aloisdeniel/image_bundler/blob/main/packages/icon_bundler/example/input/confetti.svg" width="64"></td>
    <td><img src="https://github.com/aloisdeniel/image_bundler/blob/main/packages/icon_bundler/example/input/dominos.svg" width="64"></td>
  </tr>
</table>

[Output files](../example/output/):

<img src="https://github.com/aloisdeniel/image_bundler/blob/main/packages/icon_bundler/example/output/assets/app_icon/sheet_96.png?raw=true" width="200">

# Q&A

> What is the advantage of using this package compared to using `flutter_svg`?

The advantage of using this package is that it allows you to bundle multiple SVG, PNG, or JPG files into a single spritesheet. This reduces the number of asset files in your project, which can improve performance and organization. Additionally, it generates a widget that can be used to easily access and display the bundled icons without needing to manage individual files.

> What is the advantage of using this package compared to a font icon package?

The advantage of using this package is that it allows you to use SVG, PNG, or JPG files directly as icons, which can provide better quality and flexibility compared to font icons. You can easily customize the appearance of each icon without needing to create a new font file. Additionally, this package supports colored icons as well as tinted ones.
