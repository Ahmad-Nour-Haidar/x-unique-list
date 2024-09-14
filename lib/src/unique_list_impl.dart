part 'base_unique_list.dart';

/// Concrete implementation of BaseUniqueList
final class UniqueList<T> extends _BaseUniqueList<T> {
  /// List to maintain the order of items
  List<T> _itemsList = [];

  /// Set to ensure uniqueness based on the unique condition
  Set<dynamic> _uniqueItemsSet = {};

  /// Constructor
  UniqueList(super.uniqueCondition);

  @override
  List<T> get items => List.unmodifiable(_itemsList);

  @override
  List<T> get data => _itemsList;

  @override
  T operator [](int index) => _itemsList[index];

  @override
  bool add(T item) {
    final uniqueValue = uniqueCondition(item);
    if (_uniqueItemsSet.contains(uniqueValue)) return false;
    _itemsList.add(item);
    _uniqueItemsSet.add(uniqueValue);
    return true;
  }

  @override
  int addAll(List<T> newItems) {
    int count = 0;
    for (final T item in newItems) {
      if (add(item)) count++;
    }
    return count;
  }

  @override
  bool insert(int index, T item) {
    final uniqueValue = uniqueCondition(item);
    if (_uniqueItemsSet.contains(uniqueValue)) return false;
    _itemsList.insert(index, item);
    _uniqueItemsSet.add(uniqueValue);
    return true;
  }

  @override
  int insertAll(int index, Iterable<T> newItems) {
    int count = 0;
    for (final T item in newItems) {
      final uniqueValue = uniqueCondition(item);
      if (!_uniqueItemsSet.contains(uniqueValue)) {
        _itemsList.insert(index + count, item);
        _uniqueItemsSet.add(uniqueValue);
        count++;
      }
    }
    return count;
  }

  @override
  bool remove(T item) {
    final uniqueValue = uniqueCondition(item);
    if (_uniqueItemsSet.contains(uniqueValue)) {
      _uniqueItemsSet.remove(uniqueValue);
      return _itemsList.remove(item);
    }
    return false;
  }

  @override
  bool removeOneWhere(bool Function(T) test) {
    for (int i = 0; i < _itemsList.length; i++) {
      final item = _itemsList[i];
      if (test(item)) {
        final uniqueValue = uniqueCondition(item);
        _uniqueItemsSet.remove(uniqueValue); // Remove from the set
        _itemsList.removeAt(i); // Remove from the list
        return true; // Successfully removed
      }
    }
    return false; // No item was removed
  }

  @override
  void removeWhere(bool Function(T e) test) {
    return _itemsList.removeWhere(test);
  }

  @override
  bool replaceOne(T newItem) {
    final newUniqueValue = uniqueCondition(newItem);

    for (int i = 0; i < _itemsList.length; i++) {
      final oldItem = _itemsList[i];
      final oldUniqueValue = uniqueCondition(oldItem);

      if (oldUniqueValue == newUniqueValue && oldItem != newItem) {
        _itemsList[i] = newItem; // O(1)
        _uniqueItemsSet.remove(oldUniqueValue); // O(1)
        _uniqueItemsSet.add(newUniqueValue); // O(1)
        return true;
      }
    }
    return false;
  }

  @override
  bool replaceOneWhere(T newItem, bool Function(T) test) {
    for (int i = 0; i < _itemsList.length; i++) {
      if (test(_itemsList[i])) {
        final oldItem = _itemsList[i];
        final oldUniqueValue = uniqueCondition(oldItem);
        final newUniqueValue = uniqueCondition(newItem);

        _itemsList[i] = newItem; // O(1)
        _uniqueItemsSet.remove(oldUniqueValue); // O(1)
        _uniqueItemsSet.add(newUniqueValue); // O(1)
        return true;
      }
    }
    return false;
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    _itemsList.sort(compare); // O(n log n)
  }

  @override
  List<T> where(bool Function(T) test) {
    return _itemsList.where(test).toList(); // O(n)
  }

  @override
  T? firstWhere(bool Function(T) test) {
    try {
      return _itemsList.firstWhere(test); // O(n)
    } catch (e) {
      return null; // Return null if no item matches the condition
    }
  }

  @override
  int indexWhere(bool Function(T) test) {
    for (int i = 0; i < _itemsList.length; i++) {
      if (test(_itemsList[i])) {
        return i;
      }
    }
    return -1; // Return -1 if no item matches the condition
  }

  @override
  int indexOf(T item) {
    final uniqueValue = uniqueCondition(item);

    // Early return if the unique value is not in the set
    if (!_uniqueItemsSet.contains(uniqueValue)) return -1;

    for (int i = 0; i < _itemsList.length; i++) {
      if (uniqueCondition(_itemsList[i]) == uniqueValue) {
        return i;
      }
    }

    return -1; // Return -1 if the item is not found
  }

  @override
  bool contains(T item) => _uniqueItemsSet.contains(uniqueCondition(item));

  @override
  int get length => _itemsList.length;

  @override
  bool get isEmpty => _itemsList.isEmpty;

  @override
  bool get isNotEmpty => _itemsList.isNotEmpty;

  @override
  void clear() {
    _itemsList = []; // O(1)
    _uniqueItemsSet = {}; // O(1)
  }
}
