abstract interface class FileProvider {
  /// Given Uri [context], find [path] and return Uri
  /// Both Uris should be absolute
  Uri resolveInclusion(Uri context, String path);

  /// Return the contents of a file described by absolute Uri [source]
  Future<String> getContents(Uri source);
}
