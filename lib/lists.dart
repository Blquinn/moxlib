/// A wrapper around List<T>.firstWhere that does not throw but instead just
/// returns true if [test] returns true for an element or false if [test] never
/// returned true.
bool listContains<T>(List<T> list, bool Function(T element) test) {
  return firstWhereOrNull<T>(list, test) != null;
}

/// A wrapper around [List<T>.firstWhere] that does not throw but instead just
/// return null if [test] never returned true
T? firstWhereOrNull<T>(List<T> list, bool Function(T element) test) {
  try {
    return list.firstWhere(test);
  } catch(e) {
    return null;
  }
}
