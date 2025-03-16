import 'package:yaml/yaml.dart';

import 'file/default_file_opener.dart';
import 'parse/file_inclusion.dart';
import 'parse/file_properties.dart';
import 'process/convert.dart';

typedef _Provider = Future<String> Function(String);

///
/// Parses the string [yaml] containing yaml-encoded data.
/// For `include` key lookup, a [fileProvider] function can be given. The function takes
/// the include value string as a parameter and returns a Future to the file contents.
/// The default file provider opens files in the current working directory.
Future<dynamic> loadExtendedYaml(String yaml, [Future<String> Function(String)? fileProvider]) async {
  fileProvider ??= FileOpener().getFile;
  if (containsDocumentList(yaml)) {
    return _parseDocuments(yaml, fileProvider);
  } else {
    return _parseSingleDocument(yaml, fileProvider);
  }
}

Future<dynamic> _parseSingleDocument(String yaml, _Provider provider) async {
  Future<String> includedYaml = getMergedYamlString(yaml, provider);
  return convertYaml(loadYaml(await includedYaml, recover: true));
}

Future<List<dynamic>> _parseDocuments(String yaml, _Provider provider) {
  Future<dynamic> handleDocument(String doc) => _parseSingleDocument(doc, provider);
  return Future.wait(yaml.split(docRegex).where(_isNotEmptyDoc).nonNulls.map(handleDocument));
}

bool _isNotEmptyDoc(String s) => s.trim().isNotEmpty;
