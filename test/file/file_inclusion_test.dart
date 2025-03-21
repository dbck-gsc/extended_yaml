import 'dart:io';

import 'package:extended_yaml/src/file/function_wrapper.dart';
import 'package:extended_yaml/src/parse/file_inclusion.dart';
import 'package:test/test.dart';

Future<String> getError(Uri u) => Future<String>.error('This should not be called (reading $u)');
Uri resolveError(Uri u, String s) => throw Exception('This should not be called (looking up $s from $u)');

Future<String> getBlank(Uri u) => Future<String>.value(' ');
Uri normalResolve(Uri u, String s) => u.resolve(s);

void main() {
  var dummy = Uri.directory(Directory.current.path);

  test('regex doesnt match non include:<string> or include:<list of string>', () async {
    String yamlString = File('test/data/file_inclusion/no_matches.yaml').readAsStringSync();
    String result =
        await getMergedYamlString(yamlString, (provider: FunctionWrapper(getError, resolveError), context: dummy));

    expect(result, yamlString);
  });

  test('all matches are replaced', () async {
    String yamlString = File('test/data/file_inclusion/all_matches.yaml').readAsStringSync();
    String result =
        await getMergedYamlString(yamlString, (provider: FunctionWrapper(getBlank, normalResolve), context: dummy));

    // resulting file should be all whitespace
    expect(result.trim(), '');
  });
}
