import 'dart:io';

import 'package:path/path.dart' as path;

///
/// Looks for a file relative to a directory. If no directory is provided via contructor, [Directory.current] is used.
///
class FileOpener {
  const FileOpener([this._directory]);

  final Directory? _directory;

  Future<String> getFile(String source) {
    Directory dir = _directory ?? Directory.current;
    var file = File(path.join(dir.path, source));
    return file.readAsString();
  }
}
