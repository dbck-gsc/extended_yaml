import 'file_provider.dart';

class FunctionWrapper implements FileProvider {
  const FunctionWrapper(this._getContents, this._resolvePath);
  final Future<String> Function(Uri) _getContents;
  final Uri Function(Uri, String) _resolvePath;

  @override
  Future<String> getContents(Uri source) => _getContents(source);

  @override
  Uri resolveInclusion(Uri context, String path) => _resolvePath(context, path);
}
