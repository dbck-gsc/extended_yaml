import 'package:yaml/yaml.dart';

typedef _FileProvider = Future<String> Function(String);

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
  Iterable<RegExpMatch> matches = _getIncludes(yamlString);
  String replaced = yamlString;
  Set<String> includes = {};

  for (RegExpMatch match in matches) {
    String? matchString = match[0];
    if (matchString == null) {
      continue;
    }

    await _parseInclude(matchString, fileProvider, includes);
    if (includes.isNotEmpty) {
      replaced = replaced.replaceFirst(matchString, '');
    }
  }

  return includes.join('\n\n') + replaced;
}

Iterable<RegExpMatch> _getIncludes(String yaml) => _regex.allMatches(yaml);

/// takes an include (or list) and resolves and returns the contents of included files
/// returns whether a match is recognized as a valid include
Future<bool> _parseInclude(String match, _FileProvider fileProvider, Set<String> includeContents) async {
  dynamic parsed = (loadYaml(match) as Map<dynamic, dynamic>)['include'];
  if (parsed is String) {
    await _handleFileInclude(parsed, fileProvider, includeContents);
  } else if (parsed is YamlList) {
    // ignore: specify_nonobvious_local_variable_types (dynamic)
    for (dynamic parsedItem in parsed) {
      if (parsedItem is String) {
        await _handleFileInclude(parsedItem, fileProvider, includeContents);
      }
    }
  } else {
    return false;
  }
  return true;
}

Future<void> _handleFileInclude(String fileDef, _FileProvider provider, Set<String> includeContents) async {
  String includeDef = await provider(fileDef);
  String replaceText = '';
  for (RegExpMatch match in _getIncludes(includeDef)) {
    String? matchString = match[0];
    if (matchString != null) {
      if (await _parseInclude(matchString, provider, includeContents)) {
        replaceText = matchString;
      }
    }
  }
  includeContents.add(includeDef.replaceFirst(replaceText, ''));
}
