import 'dart:math' show Random;

import 'x_unique_list.dart';

/// Summary of a bulk upsert performed by [XUniqueListBase.addAllOrReplace].
typedef UpsertResult = ({int added, int updated});

/// Summary of a reconciliation performed by [XUniqueListBase.syncWith].
typedef SyncResult = ({int added, int updated, int removed});

/// The contract implemented by [XUniqueList].
///
/// An ordered collection of [T] in which no two elements share the same key,
/// where the key is derived by a caller supplied function of type
/// `K Function(T)` rather than by the `==` operator of [T].
///
/// Depend on this type (rather than on [XUniqueList]) when you want to fake or
/// mock the collection in your own tests.
///
/// ## Keys must be stable
///
/// The key of an element is computed **once**, when the element enters the
/// collection, and is remembered from then on. Mutating the field a key is
/// derived from after insertion does not update the collection's bookkeeping,
/// so the element will still be found under its original key. Prefer immutable
/// key fields.
abstract interface class XUniqueListBase<T, K extends Object>
    implements Iterable<T> {
  // ---------------------------------------------------------------------------
  // Access
  // ---------------------------------------------------------------------------

  /// The function used to derive an element's key.
  ///
  /// Useful for building a derived collection with the same identity rule.
  K Function(T element) get keyOf;

  /// An unmodifiable *view* of the elements, in order.
  ///
  /// The view reflects later mutations of this collection. Attempting to
  /// modify it throws [UnsupportedError]. Use [toList] for an independent copy.
  ///
  /// Time complexity: O(1).
  List<T> get items;

  /// The keys of the elements, in the same order as [items].
  ///
  /// Time complexity: O(1).
  Iterable<K> get keys;

  /// The element at [index].
  ///
  /// [index] must be non-negative and less than [length].
  ///
  /// Time complexity: O(1).
  T operator [](int index);

  /// Replaces the element at [index] with [value].
  ///
  /// Throws [ArgumentError] if the key of [value] already belongs to a
  /// *different* element, since that would introduce a duplicate key.
  ///
  /// Time complexity: O(1).
  void operator []=(int index, T value);

  /// The element stored under [key], or `null` if there is none.
  ///
  /// Time complexity: O(1).
  T? lookup(K key);

  /// Whether an element with the given [key] is present.
  ///
  /// Time complexity: O(1).
  bool containsKey(K key);

  /// Whether an element with the same key as [element] is present.
  ///
  /// Does **not** use the `==` operator of [T]; comparison is by key only.
  /// Returns `false` if [element] is not a [T].
  ///
  /// Time complexity: O(1).
  @override
  bool contains(Object? element);

  /// The index of the element whose key matches that of [element], or `-1`.
  ///
  /// Only indices greater than or equal to [start] are considered.
  ///
  /// Time complexity: O(1).
  int indexOf(T element, [int start = 0]);

  /// The index of the element stored under [key], or `-1` if there is none.
  ///
  /// Time complexity: O(1).
  int indexOfKey(K key);

  /// The index of the first element satisfying [test], or `-1`.
  ///
  /// Time complexity: O(n).
  int indexWhere(bool Function(T element) test, [int start = 0]);

  /// The first element satisfying [test], or `null` if there is none.
  ///
  /// Unlike [firstWhere], this never throws.
  ///
  /// Time complexity: O(n).
  T? firstWhereOrNull(bool Function(T element) test);

  /// The last element satisfying [test], or `null` if there is none.
  ///
  /// Time complexity: O(n).
  T? lastWhereOrNull(bool Function(T element) test);

  /// The elements in reverse order.
  ///
  /// Time complexity: O(1) to obtain, O(n) to iterate.
  Iterable<T> get reversed;

  /// An independent list containing the elements from [start] to [end].
  ///
  /// Time complexity: O(n).
  List<T> sublist(int start, [int? end]);

  /// A `Map` from key to element, in iteration order.
  ///
  /// The returned map is a new, modifiable copy.
  ///
  /// Time complexity: O(n).
  Map<K, T> toMap();

  /// An independent copy of this collection sharing the same key function.
  ///
  /// Time complexity: O(n).
  XUniqueListBase<T, K> copy();

  // ---------------------------------------------------------------------------
  // Adding
  // ---------------------------------------------------------------------------

  /// Appends [element] unless its key is already present.
  ///
  /// Returns `true` if it was appended.
  ///
  /// Time complexity: O(1).
  bool add(T element);

  /// Appends every element of [elements] whose key is not already present.
  ///
  /// Returns the number appended.
  ///
  /// Time complexity: O(m).
  int addAll(Iterable<T> elements);

  /// Inserts [element] at [index] unless its key is already present.
  ///
  /// Returns `true` if it was inserted.
  ///
  /// Time complexity: O(n).
  bool insert(int index, T element);

  /// Inserts the elements of [elements] at consecutive positions from [index],
  /// skipping any whose key is already present.
  ///
  /// Returns the number inserted.
  ///
  /// Time complexity: O(n + m).
  int insertAll(int index, Iterable<T> elements);

  /// Appends [element], or replaces the existing element with the same key.
  ///
  /// Returns `false` when an element equal to [element] (per `==`) is already
  /// stored under that key, in which case nothing changes.
  ///
  /// Time complexity: O(1).
  bool addOrReplace(T element);

  /// Applies [addOrReplace] to each element of [elements].
  ///
  /// Returns how many were added and how many were updated.
  ///
  /// Time complexity: O(m).
  UpsertResult addAllOrReplace(Iterable<T> elements);

  /// Returns the element stored under [key], inserting the result of
  /// [ifAbsent] and returning that instead when the key is absent.
  ///
  /// Throws [ArgumentError] if the value produced by [ifAbsent] does not have
  /// the key [key].
  ///
  /// Time complexity: O(1).
  T putIfAbsent(K key, T Function() ifAbsent);

  // ---------------------------------------------------------------------------
  // Replacing
  // ---------------------------------------------------------------------------

  /// Replaces the element sharing a key with [element], if it differs.
  ///
  /// Returns `true` if a replacement occurred. Returns `false` when the key is
  /// absent, or when the stored element is already equal to [element].
  ///
  /// Time complexity: O(1).
  bool replaceOne(T element);

  /// Replaces the first element satisfying [test] with [element].
  ///
  /// Returns `false` — leaving the collection untouched — when no element
  /// satisfies [test], or when the key of [element] already belongs to a
  /// *different* element, since replacing would introduce a duplicate key.
  ///
  /// Time complexity: O(n).
  bool replaceOneWhere(T element, bool Function(T element) test);

  /// Replaces the element stored under [key] with `update(current)`.
  ///
  /// Returns `false` if [key] is absent. Throws [ArgumentError] if the updated
  /// value does not have the key [key].
  ///
  /// Time complexity: O(1).
  bool update(K key, T Function(T current) update);

  // ---------------------------------------------------------------------------
  // Removing
  // ---------------------------------------------------------------------------

  /// Removes the element whose key matches that of [element].
  ///
  /// Does **not** use the `==` operator of [T].
  ///
  /// Time complexity: O(n) — the element is located in O(1), but the elements
  /// after it must shift.
  bool remove(T element);

  /// Removes the element stored under [key].
  ///
  /// Returns the removed element, or `null` if [key] was absent.
  ///
  /// Time complexity: O(n).
  T? removeKey(K key);

  /// Removes and returns the element at [index].
  ///
  /// Time complexity: O(n).
  T removeAt(int index);

  /// Removes and returns the last element.
  ///
  /// Throws [StateError] if the collection is empty.
  ///
  /// Time complexity: O(1).
  T removeLast();

  /// Removes every element whose key matches one in [elements].
  ///
  /// Returns the number removed.
  ///
  /// Time complexity: O(n + m).
  int removeAll(Iterable<T> elements);

  /// Removes the elements stored under [keys].
  ///
  /// Returns the number removed.
  ///
  /// Time complexity: O(n + m).
  int removeKeys(Iterable<K> keys);

  /// Removes the first element satisfying [test].
  ///
  /// Time complexity: O(n).
  bool removeOneWhere(bool Function(T element) test);

  /// Removes every element satisfying [test].
  ///
  /// Returns the number removed.
  ///
  /// Time complexity: O(n).
  int removeWhere(bool Function(T element) test);

  /// Removes every element *not* satisfying [test].
  ///
  /// Returns the number removed.
  ///
  /// Time complexity: O(n).
  int retainWhere(bool Function(T element) test);

  /// Removes every element whose key is not in [keys].
  ///
  /// Returns the number removed.
  ///
  /// Time complexity: O(n + m).
  int retainKeys(Iterable<K> keys);

  /// Removes all elements.
  ///
  /// Time complexity: O(n).
  void clear();

  // ---------------------------------------------------------------------------
  // Reconciling
  // ---------------------------------------------------------------------------

  /// Makes this collection mirror [source].
  ///
  /// For each element of [source]: it is appended if its key is absent,
  /// replaces the stored element if the key is present and the values differ,
  /// and is ignored if an equal value is already stored. Elements whose keys
  /// do not appear in [source] are removed.
  ///
  /// When [preserveOrder] is `true` (the default) surviving elements keep
  /// their current positions and new elements are appended. When it is `false`
  /// the resulting order matches the order of [source] exactly.
  ///
  /// If [source] contains several elements with the same key, the last one
  /// wins.
  ///
  /// Time complexity: O(n + m).
  SyncResult syncWith(Iterable<T> source, {bool preserveOrder = true});

  // ---------------------------------------------------------------------------
  // Ordering
  // ---------------------------------------------------------------------------

  /// Sorts the elements in place.
  ///
  /// Unlike `List.sort`, this sort is **stable**: elements that compare equal
  /// keep their relative order.
  ///
  /// If [compare] is omitted the elements are compared with
  /// `Comparable.compare`, which throws if [T] is not [Comparable].
  ///
  /// Time complexity: O(n log n).
  void sort([int Function(T a, T b)? compare]);

  /// Shuffles the elements in place.
  ///
  /// Time complexity: O(n).
  void shuffle([Random? random]);

  /// Moves the element at [oldIndex] to [newIndex].
  ///
  /// [newIndex] is interpreted *after* the element has been removed, matching
  /// `List.removeAt` followed by `List.insert`. Flutter's
  /// `ReorderableListView.onReorder` reports an index computed *before*
  /// removal, so subtract one from it when `newIndex > oldIndex`.
  ///
  /// Time complexity: O(n).
  void reorder(int oldIndex, int newIndex);

  /// Exchanges the elements at [indexA] and [indexB].
  ///
  /// Time complexity: O(1).
  void swap(int indexA, int indexB);

  // ---------------------------------------------------------------------------
  // Set algebra
  // ---------------------------------------------------------------------------

  /// A new collection holding these elements followed by those of [other]
  /// whose keys are not already present.
  ///
  /// Time complexity: O(n + m).
  XUniqueListBase<T, K> union(Iterable<T> other);

  /// A new collection holding the elements whose keys also occur in [other].
  ///
  /// Time complexity: O(n + m).
  XUniqueListBase<T, K> intersection(Iterable<T> other);

  /// A new collection holding the elements whose keys do not occur in [other].
  ///
  /// Time complexity: O(n + m).
  XUniqueListBase<T, K> difference(Iterable<T> other);

  /// Shorthand for [union].
  XUniqueListBase<T, K> operator +(Iterable<T> other);

  // ---------------------------------------------------------------------------
  // Batching
  // ---------------------------------------------------------------------------

  /// Runs [action], coalescing the change notifications it produces into one.
  ///
  /// Has no observable effect on a plain [XUniqueList]; see
  /// `XObservableUniqueList`. Batches may be nested.
  R batch<R>(R Function() action);
}
