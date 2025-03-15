import 'package:yaml/yaml.dart';

// This is liberal regex; it will match any root block that is keyed 'include'
final _regex = RegExp(r'^include:(?:\n?[ \t]+\S[\S ]*$)+', multiLine: true);

///
/// Takes text of yaml (i.e. from file) and parses includes
/// and merges them to a combined definition suitable for parsing
/// Arugments: [yamlString] - string encoded yaml definition
/// [fileProvider] - a function which takes a string file path,
/// asset key, etc.) and returns file/asset contents
///
Future<String> getMergedYamlString(String yamlString, Future<String> Function(String) fileProvider) async {
  Iterable<RegExpMatch> matches = _regex.allMatches(yamlString);
  String replaced = yamlString;

  for (RegExpMatch match in matches) {
    String? matchString = match[0];
    if (matchString == null) {
      continue;
    }

    String includeFileContents = await _parseInclude(matchString, fileProvider);
    if (includeFileContents.isNotEmpty) {
      replaced = replaced.replaceFirst(matchString, includeFileContents);
    }
  }

  return replaced;
}

/// takes an include (or list) and resolves and returns the contents of included files
Future<String> _parseInclude(String match, Future<String> Function(String) fileProvider) async {
  dynamic parsed = (loadYaml(match) as Map<dynamic, dynamic>)['include'];

  if (parsed is String) {
    return fileProvider(parsed);
  }

  if (parsed is YamlList) {
    return Future.wait(parsed.value.map<Future<String>>((dynamic file) async {
      if (file is String) {
        return fileProvider(file);
      } else {
        return '';
      }
    })).then((List<String> list) => list.where((s) => s.isNotEmpty).join('\n\n'));
  }

  return '';
}
