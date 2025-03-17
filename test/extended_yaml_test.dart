import 'dart:io';

import 'package:extended_yaml/extended_yaml.dart';
import 'package:extended_yaml/src/file/default_file_opener.dart';
import 'package:test/test.dart';

void main() {
  group('merge key', () {
    test('basic merging', () async {
      String yamlString = File('test/data/merge_keys.yaml').readAsStringSync();
      final result = await loadExtendedYaml(yamlString) as Map<dynamic, dynamic>;
      final overrideMap = result['override_map'] as Map<dynamic, dynamic>;
      expect(overrideMap['a'], 1);
      expect(overrideMap['b'], 3);
      expect(overrideMap['c'], 1);
    });

    test('keeps unique values', () async {
      String yamlString = File('test/data/merge_keys.yaml').readAsStringSync();
      final result = await loadExtendedYaml(yamlString) as Map<dynamic, dynamic>;
      final more = result['provide_extra'] as Map<dynamic, dynamic>;
      expect(more['a'], 3);
      expect(more['b'], 3);
      expect(more['c'], 3);
      expect(more['d'], 3);
    });

    test('has deep merging', () async {
      String yamlString = File('test/data/merge_keys.yaml').readAsStringSync();
      final result = await loadExtendedYaml(yamlString) as Map<dynamic, dynamic>;
      final replace = result['real'] as Map<dynamic, dynamic>;

      assert(replace['first'] is Map);
      assert(replace['second'] is Map);
      assert(replace['third'] is Map);

      final first = replace['first'] as Map<dynamic, dynamic>;
      final second = replace['second'] as Map<dynamic, dynamic>;
      final third = replace['third'] as Map<dynamic, dynamic>;

      expect(first['a'], 1);
      expect(first['b'], 2);
      expect(first['c'], 3);

      expect(second['d'], 4);
      expect(second['e'], 5);
      expect(second['f'], 6);

      expect(third['g'], 7);
      expect(third['h'], 8);
      expect(third['i'], 9);
    });
  });

  group('including files', () {
    test('test list inclusion', () async {
      String yamlString = File('test/data/include.yaml').readAsStringSync();
      dynamic result = await loadExtendedYaml(yamlString, FileOpener(Directory('test/data')).getFile);
      assert(result is Map);

      final resultMap = result as Map<dynamic, dynamic>;
      assert(resultMap.containsKey('a_map'));
      expect(result['a_map'], 'abc');
      assert(resultMap.containsKey('b_map'));
      expect(result['b_map'], 'abc');
      assert(resultMap.containsKey('c_map'));
      expect(result['c_map'], 'abc');
    });

    test('test string inclusion', () async {
      String yamlString = File('test/data/include2.yaml').readAsStringSync();
      dynamic result = await loadExtendedYaml(yamlString, FileOpener(Directory('test/data')).getFile);
      assert(result is Map);
      expect((result as Map<dynamic, dynamic>)['a_map'], 'abc');
    });
  });

  group('iterative file inclusion', () {
    test('deep include', () async {
      String yamlString = File('test/data/include_include.yaml').readAsStringSync();
      final Future<String> Function(String) opener = FileOpener(Directory('test/data')).getFile;
      final result = await loadExtendedYaml(yamlString, opener) as Map<dynamic, dynamic>;
      assert(result.containsKey('a_map'));
      expect(result['a_map'], 'abc');
    });

    test('diamond include', () async {
      String yamlString = File('test/data/diamond_inclusion.yaml').readAsStringSync();
      final Future<String> Function(String) opener = FileOpener(Directory('test/data')).getFile;
      final result = await loadExtendedYaml(yamlString, opener) as Map<dynamic, dynamic>;
      assert(result.containsKey('a_map'));
      expect(result['a_map'], 'abc');

      assert(result.containsKey('b_map'));
      expect(result['b_map'], 'abc');

      assert(result.containsKey('c_map'));
      expect(result['c_map'], 'abc');
    });
  });
}
