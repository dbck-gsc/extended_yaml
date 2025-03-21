import 'dart:io';

import 'file_provider.dart';

class DefaultProvider implements FileProvider {
  @override
  Future<String> getContents(Uri source) => File.fromUri(source).readAsString();

  @override
  Uri resolveInclusion(Uri context, String path) => context.resolve(path);
}
