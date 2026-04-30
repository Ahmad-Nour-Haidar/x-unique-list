part 'base_unique_list.dart';

/// Concrete implementation of BaseXUniqueList
final class XUniqueList<T> extends _BaseXUniqueList<T> {
  /// List to maintain the order of items
  List<T> _itemsList = [];

  /// Set to ensure uniqueness based on the unique condition
  Set<dynamic> _uniqueItemsSet = {};

  /// Constructor
  XUniqueList(super.uniqueCondition);

  /// O(n)
  @override
  List<T> get unmodifiableItems => List<T>.unmodifiable(_itemsList);

  /// O(1)
  @override
  List<T> get items => _itemsList;

  /// O(1)
  @override
  T operator [](int index) => _itemsList[index];

  /// Returns true if the item was added, false if it already exists.
  /// O(1)
  @override
  bool add(T item) {
    final uniqueValue = _uniqueCondition(item);
    if (_uniqueItemsSet.contains(uniqueValue)) return false;
    _itemsList.add(item);
    _uniqueItemsSet.add(uniqueValue);
    return true;
  }

  /// Returns the number of items actually added.
  /// O(n)
  @override
  int addAll(Iterable<T> newItems) {
    int count = 0;
    for (final item in newItems) {
      if (add(item)) count++;
    }
    return count;
  }

  /// Returns true if the item was inserted, false if it already exists.
  /// O(n) — due to list insertion at arbitrary index
  @override
  bool insert(int index, T item) {
    final uniqueValue = _uniqueCondition(item);
    if (_uniqueItemsSet.contains(uniqueValue)) return false;
    _itemsList.insert(index, item);
    _uniqueItemsSet.add(uniqueValue);
    return true;
  }

  /// Returns the number of items actually inserted.
  /// O(n * m) — n items to insert, each list insert is O(m) where m is list length
  @override
  int insertAll(int index, Iterable<T> newItems) {
    int count = 0;
    for (final item in newItems) {
      final uniqueValue = _uniqueCondition(item);
      if (!_uniqueItemsSet.contains(uniqueValue)) {
        _itemsList.insert(index + count, item);
        _uniqueItemsSet.add(uniqueValue);
        count++;
      }
    }
    return count;
  }

  /// Returns true if the item was removed, false if it was not found.
  /// O(n) — scans list to find item by unique value, then removes by index.
  /// Does NOT rely on [==] operator of [T].
  @override
  bool remove(T item) {
    final uniqueValue = _uniqueCondition(item);
    if (!_uniqueItemsSet.contains(uniqueValue)) return false;

    for (int i = 0; i < _itemsList.length; i++) {
      if (_uniqueCondition(_itemsList[i]) == uniqueValue) {
        _itemsList.removeAt(i); // O(n) — shifts elements
        _uniqueItemsSet.remove(uniqueValue); // O(1)
        return true;
      }
    }

    return false;
  }

  /// Removes the first item matching [test]. Returns true if one was removed.
  /// O(n)
  @override
  bool removeOneWhere(bool Function(T item) test) {
    for (int i = 0; i < _itemsList.length; i++) {
      final item = _itemsList[i];
      if (test(item)) {
        final uniqueValue = _uniqueCondition(item);
        _uniqueItemsSet.remove(uniqueValue);
        _itemsList.removeAt(i);
        return true;
      }
    }
    return false;
  }

  /// Removes all items matching [test], keeping [_uniqueItemsSet] in sync.
  /// O(n)
  @override
  void removeWhere(bool Function(T item) test) {
    _itemsList.removeWhere((item) {
      if (test(item)) {
        _uniqueItemsSet.remove(_uniqueCondition(item));
        return true;
      }
      return false;
    });
  }

  /// Replaces the item whose unique value matches [newItem]'s unique value,
  /// only if the item itself is different. Returns true if a replacement occurred.
  /// O(n)
  @override
  bool replaceOne(T newItem) {
    final newUniqueValue = _uniqueCondition(newItem);

    for (int i = 0; i < _itemsList.length; i++) {
      final oldItem = _itemsList[i];
      final oldUniqueValue = _uniqueCondition(oldItem);

      if (oldUniqueValue == newUniqueValue && oldItem != newItem) {
        _itemsList[i] = newItem; // O(1)
        // The unique value is unchanged, so no set update is needed.
        return true;
      }
    }
    return false;
  }

  /// Replaces the first item matching [test] with [newItem],
  /// updating the unique set accordingly. Returns true if a replacement occurred.
  /// O(n)
  @override
  bool replaceOneWhere(T newItem, bool Function(T item) test) {
    for (int i = 0; i < _itemsList.length; i++) {
      final oldItem = _itemsList[i];
      if (test(oldItem)) {
        final oldUniqueValue = _uniqueCondition(oldItem);
        final newUniqueValue = _uniqueCondition(newItem);
        _itemsList[i] = newItem; // O(1)
        _uniqueItemsSet.remove(oldUniqueValue); // O(1)
        _uniqueItemsSet.add(newUniqueValue); // O(1)
        return true;
      }
    }
    return false;
  }

  /// Adds [item] if its unique value is not already present.
  /// If the unique value exists but the item differs, replaces it.
  /// Returns true if the item was added or replaced, false if it was identical.
  /// O(n) — requires scanning the list to locate the existing item for replacement
  @override
  bool addOrReplace(T newItem) {
    final newUniqueValue = _uniqueCondition(newItem);

    if (!_uniqueItemsSet.contains(newUniqueValue)) {
      // Unique value not present — simply add.
      _itemsList.add(newItem);
      _uniqueItemsSet.add(newUniqueValue);
      return true;
    }

    // Unique value exists — find and replace if the item itself differs.
    for (int i = 0; i < _itemsList.length; i++) {
      if (_uniqueCondition(_itemsList[i]) == newUniqueValue) {
        if (_itemsList[i] == newItem) return false; // Identical item, no-op.
        // O(1) — unique value unchanged, no set update needed.
        _itemsList[i] = newItem;
        return true;
      }
    }

    return false; // Unreachable, but satisfies the compiler.
  }

  /// For each item in [newItems]:
  ///   - adds it if its unique value is absent,
  ///   - replaces the existing item if the unique value matches but the item differs,
  ///   - skips it if an identical item already exists.
  ///
  /// Returns the total count of items added plus items replaced.
  /// O(n * m) — n incoming items, each may scan up to m existing items
  @override
  int addAllOrReplace(Iterable<T> newItems) {
    int count = 0;
    for (final item in newItems) {
      if (addOrReplace(item)) count++;
    }
    return count;
  }

  /// O(n log n)
  @override
  void sort([int Function(T a, T b)? compare]) {
    return _itemsList.sort(compare);
  }

  /// O(n)
  @override
  Iterable<T> where(bool Function(T item) test) {
    return _itemsList.where(test);
  }

  /// Returns the first matching item, or null if none found.
  /// O(n)
  @override
  T? firstWhere(bool Function(T item) test) {
    for (final item in _itemsList) {
      if (test(item)) return item;
    }
    return null;
  }

  /// O(n)
  @override
  int indexWhere(bool Function(T item) test, [int start = 0]) {
    assert(start >= 0, 'The start index must be greater than or equal to 0.');
    return _itemsList.indexWhere(test, start);
  }

  /// O(n) — set lookup is O(1), but scanning for index is O(n)
  @override
  int indexOf(T item, [int start = 0]) {
    assert(start >= 0, 'The start index must be greater than or equal to 0.');
    final uniqueValue = _uniqueCondition(item);

    if (!_uniqueItemsSet.contains(uniqueValue)) return -1;

    for (int i = start; i < _itemsList.length; i++) {
      if (_uniqueCondition(_itemsList[i]) == uniqueValue) {
        return i;
      }
    }

    return -1;
  }

  /// O(1)
  @override
  bool contains(T item) => _uniqueItemsSet.contains(_uniqueCondition(item));

  /// O(1)
  @override
  int get length => _itemsList.length;

  /// O(1)
  @override
  bool get isEmpty => _itemsList.isEmpty;

  /// O(1)
  @override
  bool get isNotEmpty => _itemsList.isNotEmpty;

  /// O(1)
  @override
  void clear() {
    _itemsList = [];
    _uniqueItemsSet = {};
  }
}
