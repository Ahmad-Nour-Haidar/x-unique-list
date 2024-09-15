part of 'x_unique_list.dart';

/// Abstract class that defines the structure and behavior of a unique list.
abstract class _BaseXUniqueList<T> {
  /// Function to determine the unique value for each item
  /// This function takes an item of type T and returns a dynamic value used for uniqueness
  final dynamic Function(T) uniqueCondition;

  _BaseXUniqueList(this.uniqueCondition);

  /// Retrieve items as unmodifiable list
  /// Time Complexity: O(n)
  List<T> get items;

  /// Retrieve items as unmodifiable list
  /// Time Complexity: O(1)
  List<T> get data;

  /// The object at the given [index] in the list.
  ///
  /// The [index] must be a valid index of this list,
  /// which means that `index` must be non-negative and
  /// less than [length].
  T operator [](int index);

  /// Add a single item
  /// Time Complexity: O(1 + k) where k is the complexity of the uniqueCondition function
  bool add(T item);

  /// Add multiple items
  /// Returns the number of items that were successfully added.
  /// Time Complexity: O(m * (1 + k)) where m is the number of newItems and k is the average complexity of the uniqueCondition function
  int addAll(List<T> newItems);

  /// Insert an item at the specified index.
  /// Returns true if the item was inserted successfully, false if the item already exists.
  /// Time Complexity: O(n + k) where n is the number of items in the list and k is the complexity of the uniqueCondition function
  bool insert(int index, T item);

  /// Insert multiple items at the specified index.
  /// Returns the number of items that were successfully inserted.
  /// Time Complexity: O(m * (n + k)) where m is the number of newItems, n is the number of items in the list, and k is the complexity of the uniqueCondition function
  int insertAll(int index, Iterable<T> newItems);

  /// Remove a single item
  /// Time Complexity: O(n + k) where n is the number of items in the list and k is the complexity of the uniqueCondition function
  bool remove(T item);

  /// Remove a single item based on a condition
  /// Returns true if an item was removed, false otherwise
  /// Time Complexity: O(n * (1 + k)) where n is the number of items and k is the complexity of the uniqueCondition function
  bool removeOneWhere(bool Function(T) test);

  /// Remove items based on a condition
  /// Time Complexity: O(n * (1 + k)) where n is the number of items and k is the complexity of the uniqueCondition function
  void removeWhere(bool Function(T e) test);

  /// Replace an existing item with a new item based on unique condition
  /// Time Complexity: O(n * (1 + k)) where n is the number of items and k is the complexity of the uniqueCondition function
  bool replaceOne(T newItem);

  /// Replace item that matches a condition with a new item
  /// Time Complexity: O(n * (1 + k)) where n is the number of items and k is the complexity of the uniqueCondition function
  bool replaceOneWhere(T newItem, bool Function(T) test);

  /// Sort the list in place using the provided [compare] function.
  /// If no [compare] function is provided, the list is sorted in natural order.
  /// Time Complexity: O(n log n)
  void sort([int Function(T a, T b)? compare]);

  /// Method to filter items based on a condition
  /// Time Complexity: O(n) where n is the number of items in the list
  List<T> where(bool Function(T) test);

  /// Retrieve a single item based on a condition
  /// Time Complexity: O(n) where n is the number of items in the list
  T? firstWhere(bool Function(T) test);

  /// Returns the index of the first item that satisfies the provided [test] function.
  /// Returns -1 if no such item is found.
  /// Time Complexity: O(n)
  int indexWhere(bool Function(T) test);

  /// Returns the index of the first occurrence of [item] in the list.
  /// Returns -1 if the item is not found.
  /// Time Complexity: O(n)
  int indexOf(T item);

  /// Check if the list contains an item based on the unique condition
  /// Time Complexity: O(1 + k) where k is the complexity of the uniqueCondition function
  bool contains(T item);

  /// Get the length of the list
  /// Time Complexity: O(1)
  int get length;

  /// Check if the list is empty
  /// Time Complexity: O(1)
  bool get isEmpty;

  /// Check if the list is not empty
  /// Time Complexity: O(1)
  bool get isNotEmpty;

  /// Clear all items from the list and set
  /// Time Complexity: O(1)
  void clear();
}
