import 'package:recase/recase.dart';

abstract class Naming {
  static String className(String name) {
    name = _leadingDigits(name);
    name = ReCase(name).pascalCase;
    return _keyword(name);
  }

  static String fieldName(String name) {
    name = _leadingDigits(name);
    name = ReCase(name).camelCase;
    return _keyword(name);
  }

  static String fileName(String name) {
    name = _leadingDigits(name);
    name = ReCase(name).snakeCase;
    return _keyword(name);
  }

  static String _leadingDigits(String name) {
    name = name.trim();
    if (name.isEmpty) return '';
    final firstChar = name[0].codeUnitAt(0);
    final start = '0'.codeUnitAt(0);
    final end = '9'.codeUnitAt(0);
    if (firstChar >= start && firstChar <= end) {
      return 'n$firstChar';
    }
    return '';
  }

  static String _keyword(String name) {
    const Set<String> keywords = {
      'abstract',
      'as',
      'assert',
      'async',
      'await',
      'break',
      'case',
      'catch',
      'class',
      'const',
      'continue',
      'default',
      'deferred',
      'do',
      'dynamic',
      'else',
      'enum',
      'export',
      'extends',
      'extension',
      'external',
      'factory',
      'false',
      'final',
      'finally',
      'for',
      'Function',
      'get',
      'hide',
      'if',
      'implements',
      'import',
      'in',
      'interface',
      'is',
      'library',
      'mixin',
      'new',
      'null',
      'on',
      'operator',
      'part',
      'required',
      'rethrow',
      'return',
      'set',
      'show',
      'static',
      'super',
      'switch',
      'sync',
      'this',
      'throw',
      'true',
      'try',
      'typedef',
    };
    if (keywords.contains(name)) {
      return '${name}_';
    }
    return name;
  }
}
