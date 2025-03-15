import 'package:yaml/yaml.dart';

import 'merge_keys.dart';

dynamic convertYaml(dynamic yaml) => _processNode(yaml);

dynamic _processNode(dynamic node) {
  if (node is YamlDocument) {
    return _processNode(node.contents);
  }
  if (node is YamlScalar) {
    return node.value;
  }
  if (node is YamlList) {
    return _processYamlList(node);
  }
  if (node is YamlMap) {
    return _processYamlMap(node);
  }
  if (node is List<YamlDocument>) {
    return node.map((YamlDocument doc) => _processNode(doc)).toList();
  }
  return node;
}

List<dynamic> _processYamlList(List<dynamic> list) {
  List<dynamic> listResult = [];
  // ignore: specify_nonobvious_local_variable_types (needs to be dynamic)
  for (dynamic element in list) {
    listResult.add(_processNode(element));
  }
  return listResult;
}

Map<dynamic, dynamic> _processYamlMap(Map<dynamic, dynamic> map) {
  Map<dynamic, dynamic> mapResult = map.map(_processMapEntries);
  mergeMap(mapResult);
  return mapResult;
}

MapEntry<dynamic, dynamic> _processMapEntries(dynamic key, dynamic value) =>
    MapEntry<dynamic, dynamic>(_processNode(key), _processNode(value));
