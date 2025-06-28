import '../../../extended_yaml.dart';

abstract interface class PostProcessor {
  Future<dynamic> process(dynamic input, FileProvider provider, Uri context);
}
