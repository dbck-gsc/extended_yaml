const String _mergeKey = "<<";

void mergeMap(Map<dynamic, dynamic> map) {
  if (map.containsKey(_mergeKey)) {
    dynamic innerMap = map[_mergeKey];
    if (innerMap is Map) {
      deepMerge(map, innerMap);
      map.remove(_mergeKey);
    }
  }
}

void deepMerge(Map<dynamic, dynamic> map, Map<dynamic, dynamic> useIfExtra) {
  useIfExtra.forEach((dynamic key, dynamic value) {
    if (map.containsKey(key)) {
      if (map[key] is Map && value is Map) {
        deepMerge(map[key] as Map<dynamic, dynamic>, value);
      }
    } else {
      map[key] = value;
    }
  });
}
