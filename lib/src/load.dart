import 'package:yaml/yaml.dart';

import 'file/default_file_opener.dart';
import 'parse/file_inclusion.dart';
import 'process/convert.dart';

///
/// Parses the string [yaml] containing yaml-encoded data.
/// For `include` key lookup, a [fileProvider] function can be given. The function takes
/// the include value string as a parameter and returns a Future to the file contents.
/// The default file provider opens files in the current working directory.
Future<dynamic> loadExtendedYaml(String yaml, [Future<String> Function(String)? fileProvider]) async {
  fileProvider ??= FileOpener().getFile;
  Future<String> includedYaml = getMergedYamlString(yaml, fileProvider);
  return convertYaml(loadYaml(await includedYaml, recover: true));
}
