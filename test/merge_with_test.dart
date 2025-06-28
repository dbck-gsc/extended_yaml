import 'dart:io';

import 'package:extended_yaml/extended_yaml.dart';
import 'package:extended_yaml/src/file/default_file_opener.dart';
import 'package:extended_yaml/src/process/post_process/merge_with.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

final include2 = '''include: layer3
object:
  w: 0
  x: 1
  y: 2
''';

final doubleMerge = 'merge_with: layer3';

final include3 = 'banana: 2';

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.http('google.com'));
  });
  Uri context = Uri.directory('test/data');

  group('merge with directive', () {
    test('simple merging', () async {
      String yamlString = File('test/data/merge_with.yaml').readAsStringSync();
      final result = await parseExtendedYaml(yamlString, context: context) as Map<dynamic, dynamic>;
      final overrideMap = result['object'] as Map<dynamic, dynamic>;
      expect(overrideMap['a'], 1);
      expect(overrideMap['b'], 22);
      expect(overrideMap['c'], 33);
    }, tags: ['integration']);

    test('with json', () async {
      String yamlString = File('test/data/merge_over_json.yaml').readAsStringSync();
      final result = await parseExtendedYaml(yamlString, context: context) as Map<dynamic, dynamic>;
      final overrideMap = result['object'] as Map<dynamic, dynamic>;
      expect(overrideMap['a'], 1);
      expect(overrideMap['b'], 2);
      expect(overrideMap['c'], 33);
      expect(overrideMap['d'], 44);
    }, tags: ['integration']);

    group(MergeWithProcessor, () {
      final processor = MergeWithProcessor();
      final provider = DefaultProvider();

      group('non map input', () {
        test('string', () async {
          final input = 'string input';
          dynamic result = await processor.process(input, provider, context);

          expect(result, input);
        });

        test('num', () async {
          final input = 7;
          dynamic result = await processor.process(input, provider, context);

          expect(result, input);
        });

        test('list', () async {
          final input = ['a', 'b', 'c'];
          dynamic result = await processor.process(input, provider, context);

          expect(result, input);
        });
      });

      group('malformed maps', () {
        test('missing merge_with key', () async {
          final input = {'a': 1, 'b': 2, 'c': 3};
          dynamic result = await processor.process(input, provider, context);

          expect(result, input, reason: 'map should not be mutated without "merge_with" key');
        });

        test('merge_with key wrong type', () async {
          final input = {'merge_with': 1, 'b': 2, 'c': 3};
          dynamic result = await processor.process(input, provider, context);

          expect(result, input, reason: 'should not mutate coincidental key');
        });
      });

      group('positive test', () {
        final mock = MockProvider();
        final uri2 = Uri(path: 'layer2');
        final uri3 = Uri(path: 'layer3');
        final uriD = Uri(path: 'deep');

        setUpAll(() {
          when(() => mock.resolveInclusion(any(), 'layer2')).thenReturn(uri2);
          when(() => mock.resolveInclusion(any(), 'layer3')).thenReturn(uri3);
          when(() => mock.resolveInclusion(any(), 'deep_merge')).thenReturn(uriD);

          when(() => mock.getContents(uri2)).thenAnswer((_) async => include2);
          when(() => mock.getContents(uri3)).thenAnswer((_) async => include3);
          when(() => mock.getContents(uriD)).thenAnswer((_) async => doubleMerge);
        });

        test('uses file provider throughout parsing', () async {
          Map<String, dynamic> source = {
            'merge_with': 'layer2',
            'object': {'x': 11, 'y': 22, 'z': 33},
          };

          final result = await processor.process(source, mock, Uri.base) as Map;

          final object = result['object'] as Map;

          expect(object['w'], 0, reason: 'object[w]');
          expect(object['x'], 11, reason: 'object[x]');
          expect(object['y'], 22, reason: 'object[y]');
          expect(object['z'], 33, reason: 'object[z]');
          expect(result['banana'], 2);
        });

        test('removes directive', () async {
          Map<String, dynamic> source = {'merge_with': 'layer3'};

          final result = await processor.process(source, mock, context) as Map;

          expect(result.containsKey('banana'), true, reason: 'merge failure');

          expect(result.containsKey('merge_with'), false, reason: 'removing directive');
        });

        test('merges with merged', () async {
          Map<String, dynamic> source = {'merge_with': 'deep_merge'};

          final result = await processor.process(source, mock, context) as Map;

          expect(result.containsKey('banana'), true, reason: 'deep merge failure');
        });
      });
    });
  });
}
