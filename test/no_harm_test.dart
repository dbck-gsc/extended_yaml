import 'dart:io';

import 'package:extended_yaml/extended_yaml.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

// this test suite should demonstrate that yaml with
// non-extended features should be unchanged from normal parsing
void main() {
  test('map parsing', () async {
    String yamlString = File('test/data/no_harm/simple_map.yaml').readAsStringSync();
    final result = await loadExtendedYaml(yamlString) as Map<dynamic, dynamic>;
    assert(result.containsKey('map'));
    final map = result['map'] as Map<dynamic, dynamic>;
    expect(map['a'], 1);
    expect(map['b'], 2);
    expect(map['c'], 'string');
  });

  test('anchors', () async {
    String yamlString = File('test/data/no_harm/anchors.yaml').readAsStringSync();
    dynamic result = await loadExtendedYaml(yamlString);
    dynamic expected = loadYaml(yamlString);
    expect(expected, result);
  });

  test('other include defs intact', () async {
    String yamlString = File('test/data/no_harm/map_with_include_key.yaml').readAsStringSync();

    final result = await loadExtendedYaml(yamlString) as Map<dynamic, dynamic>;
    print(result);
    assert(result.containsKey('include'));
    var map = result['include'] as Map<dynamic, dynamic>;
    assert(map.containsKey('path'));
    expect(map['path'], 'some/path/to');

    assert(map.containsKey('reason'));
    expect(map['reason'], 'another string here');
  });

  test('documents output', () async {
    String yamlString = File('test/data/no_harm/multiple_docs.yaml').readAsStringSync();
    dynamic result = await loadExtendedYaml(yamlString);

    assert(result is List);
    for (var doc in result as List<dynamic>) {
      final docMap = doc as Map<dynamic, dynamic>;
      assert(docMap.containsKey('map'));

      var map = docMap['map'] as Map<dynamic, dynamic>;

      assert(map.containsKey('a'));
      expect(map['a'], 'a');

      assert(map.containsKey('b'));
      expect(map['b'], 'b');

      assert(map.containsKey('c'));
      expect(map['c'], 'c');
    }
  });
}
