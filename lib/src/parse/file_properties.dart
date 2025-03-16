final docRegex = RegExp('^---', multiLine: true);

bool containsDocumentList(String yamlString) {
  final Iterable<RegExpMatch> matches = docRegex.allMatches(yamlString.trim());
  if (matches.length > 1) {
    return true;
  }
  if (matches.length == 1 && matches.first.start > 0) {
    return true;
  }
  return false;
}
