part of 'x_unique_list.dart';

/// Abstract class that defines the structure and behavior of a unique list.
abstract class _BaseXUniqueList<T> {
  /// Function to determine the unique value for each item.
  /// Takes an item of type [T] and returns a dynamic value used for uniqueness.
  final dynamic Function(T e) _uniqueCondition;

  const _BaseXUniqueList(this._uniqueCondition);

  /// Returns items as an unmodifiable list.
  /// Time Complexity: O(n)
  List<T> get unmodifiableItems;

  /// Returns items as a modifiable list.
  /// Time Complexity: O(1)
  List<T> get items;

  /// The object at the given [index] in the list.
  ///
  /// The [index] must be a valid index of this list,
  /// which means that `index` must be non-negative and
  /// less than [length].
  /// Time Complexity: O(1)
  T operator [](int index);

  /// Adds a single [item] if its unique value is not already present.
  /// Returns true if the item was added, false if it already exists.
  /// Time Complexity: O(1)
  bool add(T item);

  /// Adds each item in [newItems] that has a unique value not already present.
  /// Returns the number of items that were successfully added.
  /// Time Complexity: O(m) where m is the number of [newItems]
  int addAll(Iterable<T> newItems);

  /// Inserts [item] at [index] if its unique value is not already present.
  /// Returns true if the item was inserted, false if it already exists.
  /// Time Complexity: O(n) where n is the number of items in the list
  bool insert(int index, T item);

  /// Inserts each item in [newItems] at consecutive positions starting from [index],
  /// skipping items whose unique value is already present.
  /// Returns the number of items that were successfully inserted.
  /// Time Complexity: O(m * n) where m is the number of [newItems] and n is the number of items in the list
  int insertAll(int index, Iterable<T> newItems);

  /// Removes the item whose unique value matches that of [item].
  /// Does NOT rely on the [==] operator of [T].
  /// Returns true if the item was found and removed, false otherwise.
  /// Time Complexity: O(n) where n is the number of items in the list
  bool remove(T item);

  /// Removes the first item that satisfies [test].
  /// Returns true if an item was removed, false otherwise.
  /// Time Complexity: O(n) where n is the number of items in the list
  bool removeOneWhere(bool Function(T item) test);

  /// Removes all items that satisfy [test], keeping the unique set in sync.
  /// Time Complexity: O(n) where n is the number of items in the list
  void removeWhere(bool Function(T item) test);

  /// Replaces the item whose unique value matches that of [newItem], only if
  /// the existing item differs from [newItem].
  /// Returns true if a replacement occurred, false otherwise.
  /// Time Complexity: O(n) where n is the number of items in the list
  bool replaceOne(T newItem);

  /// Replaces the first item that satisfies [test] with [newItem],
  /// updating the unique set if the unique value changes.
  /// Returns true if a replacement occurred, false otherwise.
  /// Time Complexity: O(n) where n is the number of items in the list
  bool replaceOneWhere(T newItem, bool Function(T item) test);

  /// Adds [newItem] if its unique value is not already present.
  /// If the unique value exists but the stored item differs, replaces it in place.
  /// Returns true if the item was added or replaced, false if an identical item already exists.
  /// Time Complexity: O(n) where n is the number of items in the list
  bool addOrReplace(T newItem);

  /// Calls [addOrReplace] for each item in [newItems].
  /// Returns the total count of items that were added or replaced.
  /// Time Complexity: O(m * n) where m is the number of [newItems] and n is the number of items in the list
  int addAllOrReplace(Iterable<T> newItems);

  /// Sorts the list in place using the provided [compare] function.
  /// If no [compare] function is provided, the list is sorted in natural order.
  /// Time Complexity: O(n log n)
  void sort([int Function(T a, T b)? compare]);

  /// Returns all items that satisfy [test].
  /// Time Complexity: O(n) where n is the number of items in the list
  Iterable<T> where(bool Function(T item) test);

  /// Returns the first item that satisfies [test], or null if none is found.
  /// Time Complexity: O(n) where n is the number of items in the list
  T? firstWhere(bool Function(T item) test);

  /// Returns the index of the first item that satisfies [test], starting from [start].
  /// Returns -1 if no such item is found.
  /// Time Complexity: O(n) where n is the number of items in the list
  int indexWhere(bool Function(T item) test, [int start = 0]);

  /// Returns the index of the first item whose unique value matches that of [item],
  /// starting from [start]. Returns -1 if the item is not found.
  /// Does NOT rely on the [==] operator of [T].
  /// Time Complexity: O(n) where n is the number of items in the list
  int indexOf(T item, [int start = 0]);

  /// Returns true if an item with the same unique value as [item] exists in the list.
  /// Time Complexity: O(1)
  bool contains(T item);

  /// The number of items in the list.
  /// Time Complexity: O(1)
  int get length;

  /// Whether the list contains no items.
  /// Time Complexity: O(1)
  bool get isEmpty;

  /// Whether the list contains at least one item.
  /// Time Complexity: O(1)
  bool get isNotEmpty;

  /// Removes all items from the list and clears the unique set.
  /// Time Complexity: O(1)
  void clear();
}
