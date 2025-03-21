import 'package:yaml/yaml.dart';

import 'merge_keys.dart';

dynamic convertYaml(dynamic yaml) => _processNode(yaml);

dynamic _processNode(dynamic node) {
  switch (node) {
    case YamlDocument _:
      return _processNode(node.contents);
    case YamlScalar _:
      return node.value;
    case YamlList _:
      return _processYamlList(node);
    case YamlMap _:
      return _processYamlMap(node);
    case List<YamlDocument> _:
      return node.map((YamlDocument doc) => _processNode(doc)).toList();
    default:
      return node;
  }
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
