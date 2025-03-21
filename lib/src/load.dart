import 'dart:io';

import 'package:yaml/yaml.dart';

import 'file/default_file_opener.dart';
import 'file/file_provider.dart';
import 'parse/file_inclusion.dart';
import 'parse/file_properties.dart';
import 'process/convert.dart';

///
/// Parses the string [yaml] containing yaml-encoded data.
/// For `include` key lookup, a [FileProvider] and [Uri] context can be given.
/// The default provider and context assumes all includes are in the local file system relative to the current directory.
///
Future<dynamic> parseExtendedYaml(String yaml, {FileProvider? fileProvider, Uri? context}) async {
  fileProvider ??= DefaultProvider();
  context ??= Uri.directory(Directory.current.path);
  if (containsDocumentList(yaml)) {
    return _parseDocuments(yaml, fileProvider, context);
  } else {
    return _parseSingleDocument(yaml, fileProvider, context);
  }
}

///
/// Loads yaml from [source] and parses it. A [FileProvider] may be given for included file lookup.
/// The default provider assumes all included files are in the local file system
///
Future<dynamic> loadExtendedYaml(Uri source, {FileProvider? fileProvider}) async {
  fileProvider ??= DefaultProvider();
  return parseExtendedYaml(await fileProvider.getContents(source), fileProvider: fileProvider, context: source);
}

Future<dynamic> _parseSingleDocument(String yaml, FileProvider provider, Uri context) async {
  Future<String> includedYaml = getMergedYamlString(yaml, (provider: provider, context: context));
  return convertYaml(loadYaml(await includedYaml, recover: true));
}

Future<List<dynamic>> _parseDocuments(String yaml, FileProvider provider, Uri context) {
  Future<dynamic> handleDocument(String doc) => _parseSingleDocument(doc, provider, context);
  return Future.wait(yaml.split(docRegex).where(_isNotEmptyDoc).nonNulls.map(handleDocument));
}

bool _isNotEmptyDoc(String s) => s.trim().isNotEmpty;
