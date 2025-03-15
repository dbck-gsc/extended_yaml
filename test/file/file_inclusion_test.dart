import 'dart:io';

import 'package:extended_yaml/src/parse/file_inclusion.dart';
import 'package:test/test.dart';

void main() {
  test('regex doesnt match non include:<string> or include:<list of string>', () async {
    Future<String> mockFileLoader(String source) =>
        Future<String>.error("This shouldn't be called. The item looked up is: $source");
    String yamlString = File('test/data/file_inclusion/no_matches.yaml').readAsStringSync();
    String result = await getMergedYamlString(yamlString, mockFileLoader);

    expect(result, yamlString);
  });

  test('all matches are replaced', () async {
    // replace all includes with empty string
    Future<String> mockFileLoader(String source) => Future<String>.value(' ');
    String yamlString = File('test/data/file_inclusion/all_matches.yaml').readAsStringSync();
    String result = await getMergedYamlString(yamlString, mockFileLoader);

    // resulting file should be all whitespace, trim is empty string
    expect(result.trim(), '');
  });
}
