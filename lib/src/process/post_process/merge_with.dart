import '../../../extended_yaml.dart';
import '../merge_keys.dart';
import 'post_processor.dart';

class MergeWithProcessor implements PostProcessor {
  @override
  Future<dynamic> process(dynamic input, FileProvider provider, Uri context) async {
    if (input is! Map || !input.containsKey('merge_with')) {
      return input;
    }
    final dynamic value = input['merge_with'];
    if (value is String) {
      final dynamic mergeYaml = await loadExtendedYaml(
        provider.resolveInclusion(context, value),
        fileProvider: provider,
      );
      if (mergeYaml is Map) {
        deepMerge(input, mergeYaml);
        input.remove('merge_with');
      }
    }

    return input;
  }
}
