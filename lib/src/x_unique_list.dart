import 'dart:collection';
import 'dart:math' show Random;

import 'x_unique_list_base.dart';

/// An ordered collection in which no two elements share the same key.
///
/// The key of an element is produced by the function passed to the
/// constructor, so uniqueness is decided by that key rather than by the `==`
/// operator of [T]:
///
/// ```dart
/// final users = XUniqueList<User, int>((u) => u.id);
/// users.add(User(1, 'Ahmad'));
/// users.add(User(1, 'Someone else')); // false — id 1 is taken
/// ```
///
/// Lookup by key, membership tests, [addOrReplace] and [replaceOne] are all
/// O(1); the collection maintains an index from key to position internally.
///
/// [XUniqueList] is an [Iterable], so `for (final u in users)`, `users.map`,
/// `[...users]` and the rest of the `Iterable` API work directly on it.
class XUniqueList<T, K extends Object> extends IterableBase<T>
    implements XUniqueListBase<T, K> {
  /// Derives the key of an element. Called exactly once per element, when the
  /// element enters the collection.
  final K Function(T element) _keyOf;

  /// The elements, in order.
  final List<T> _items = [];

  /// `_keys[i]` is the key of `_items[i]`. Kept parallel to [_items] so a key
  /// is never recomputed, and so mutating the field a key was derived from
  /// cannot desynchronise the collection.
  final List<K> _keys = [];

  /// Maps each key to its position in [_items].
  final Map<K, int> _index = {};

  int _batchDepth = 0;
  bool _pendingNotification = false;

  /// Creates an empty collection keyed by [key].
  XUniqueList(K Function(T element) key) : _keyOf = key;

  /// Creates a collection keyed by [key] holding those of [elements] whose
  /// keys are distinct; for each repeated key the first element wins.
  factory XUniqueList.from(
    Iterable<T> elements,
    K Function(T element) key,
  ) =>
      XUniqueList<T, K>(key)..addAll(elements);

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Rewrites [_index] for every position from [start] onwards.
  void _reindexFrom(int start) {
    for (var i = start; i < _items.length; i++) {
      _index[_keys[i]] = i;
    }
  }

  void _rebuildIndex() {
    _index.clear();
    _reindexFrom(0);
  }

  /// Appends without checking the key. The caller must have verified it.
  void _appendUnchecked(T element, K key) {
    _index[key] = _items.length;
    _items.add(element);
    _keys.add(key);
  }

  /// Signals that the collection changed, honouring any open [batch].
  void _changed() {
    if (_batchDepth > 0) {
      _pendingNotification = true;
      return;
    }
    onMutated();
  }

  /// Called after every mutation, once per [batch] at most.
  ///
  /// Does nothing here. Subclasses override it to observe changes; see
  /// `XObservableUniqueList`. Not intended to be called directly.
  void onMutated() {}

  @override
  R batch<R>(R Function() action) {
    _batchDepth++;
    try {
      return action();
    } finally {
      _batchDepth--;
      if (_batchDepth == 0 && _pendingNotification) {
        _pendingNotification = false;
        onMutated();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Access
  // ---------------------------------------------------------------------------

  @override
  K Function(T element) get keyOf => _keyOf;

  @override
  Iterator<T> get iterator => _items.iterator;

  @override
  List<T> get items => UnmodifiableListView<T>(_items);

  /// An unmodifiable view of the elements, in order.
  @Deprecated(
    'Use items, which is now an unmodifiable view and costs O(1). '
    'Use toList() for an independent modifiable copy. '
    'unmodifiableItems will be removed in 3.0.0.',
  )
  List<T> get unmodifiableItems => items;

  @override
  Iterable<K> get keys => UnmodifiableListView<K>(_keys);

  @override
  int get length => _items.length;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  T get first => _items.first;

  @override
  T get last => _items.last;

  @override
  T operator [](int index) => _items[index];

  @override
  void operator []=(int index, T value) {
    RangeError.checkValidIndex(index, this, 'index', _items.length);
    final newKey = _keyOf(value);
    final existing = _index[newKey];
    if (existing != null && existing != index) {
      throw ArgumentError.value(
        value,
        'value',
        'Key $newKey already belongs to the element at index $existing',
      );
    }
    final oldKey = _keys[index];
    if (oldKey != newKey) {
      _index.remove(oldKey);
      _index[newKey] = index;
      _keys[index] = newKey;
    }
    _items[index] = value;
    _changed();
  }

  @override
  T? lookup(K key) {
    final i = _index[key];
    return i == null ? null : _items[i];
  }

  @override
  bool containsKey(K key) => _index.containsKey(key);

  @override
  bool contains(Object? element) =>
      element is T && _index.containsKey(_keyOf(element));

  @override
  int indexOf(T element, [int start = 0]) {
    RangeError.checkNotNegative(start, 'start');
    final i = _index[_keyOf(element)];
    return (i == null || i < start) ? -1 : i;
  }

  @override
  int indexOfKey(K key) => _index[key] ?? -1;

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    RangeError.checkNotNegative(start, 'start');
    for (var i = start; i < _items.length; i++) {
      if (test(_items[i])) return i;
    }
    return -1;
  }

  @override
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in _items) {
      if (test(element)) return element;
    }
    return null;
  }

  @override
  T? lastWhereOrNull(bool Function(T element) test) {
    for (var i = _items.length - 1; i >= 0; i--) {
      if (test(_items[i])) return _items[i];
    }
    return null;
  }

  @override
  Iterable<T> get reversed => _items.reversed;

  @override
  List<T> sublist(int start, [int? end]) => _items.sublist(start, end);

  @override
  Map<K, T> toMap() => {
        for (var i = 0; i < _items.length; i++) _keys[i]: _items[i],
      };

  @override
  XUniqueList<T, K> copy() => XUniqueList<T, K>(_keyOf)..addAll(_items);

  // ---------------------------------------------------------------------------
  // Adding
  // ---------------------------------------------------------------------------

  @override
  bool add(T element) {
    final key = _keyOf(element);
    if (_index.containsKey(key)) return false;
    _appendUnchecked(element, key);
    _changed();
    return true;
  }

  @override
  int addAll(Iterable<T> elements) => batch(() {
        var added = 0;
        for (final element in elements) {
          if (add(element)) added++;
        }
        return added;
      });

  @override
  bool insert(int index, T element) {
    RangeError.checkValueInInterval(index, 0, _items.length, 'index');
    final key = _keyOf(element);
    if (_index.containsKey(key)) return false;
    _items.insert(index, element);
    _keys.insert(index, key);
    _reindexFrom(index);
    _changed();
    return true;
  }

  @override
  int insertAll(int index, Iterable<T> elements) {
    RangeError.checkValueInInterval(index, 0, _items.length, 'index');
    final fresh = <T>[];
    final freshKeys = <K>[];
    final seen = <K>{};
    for (final element in elements) {
      final key = _keyOf(element);
      if (_index.containsKey(key) || !seen.add(key)) continue;
      fresh.add(element);
      freshKeys.add(key);
    }
    if (fresh.isEmpty) return 0;
    _items.insertAll(index, fresh);
    _keys.insertAll(index, freshKeys);
    _reindexFrom(index);
    _changed();
    return fresh.length;
  }

  @override
  bool addOrReplace(T element) {
    final key = _keyOf(element);
    final i = _index[key];
    if (i == null) {
      _appendUnchecked(element, key);
      _changed();
      return true;
    }
    if (_items[i] == element) return false;
    _items[i] = element;
    _changed();
    return true;
  }

  @override
  UpsertResult addAllOrReplace(Iterable<T> elements) => batch(() {
        var added = 0;
        var updated = 0;
        for (final element in elements) {
          final key = _keyOf(element);
          final i = _index[key];
          if (i == null) {
            _appendUnchecked(element, key);
            added++;
            _changed();
          } else if (_items[i] != element) {
            _items[i] = element;
            updated++;
            _changed();
          }
        }
        return (added: added, updated: updated);
      });

  @override
  T putIfAbsent(K key, T Function() ifAbsent) {
    final i = _index[key];
    if (i != null) return _items[i];
    final element = ifAbsent();
    final actualKey = _keyOf(element);
    if (actualKey != key) {
      throw ArgumentError.value(
        element,
        'ifAbsent',
        'Produced an element keyed $actualKey, but $key was requested',
      );
    }
    _appendUnchecked(element, key);
    _changed();
    return element;
  }

  // ---------------------------------------------------------------------------
  // Replacing
  // ---------------------------------------------------------------------------

  @override
  bool replaceOne(T element) {
    final i = _index[_keyOf(element)];
    if (i == null || _items[i] == element) return false;
    _items[i] = element;
    _changed();
    return true;
  }

  @override
  bool replaceOneWhere(T element, bool Function(T element) test) {
    final at = indexWhere(test);
    if (at < 0) return false;

    final newKey = _keyOf(element);
    final owner = _index[newKey];
    // Replacing would give two elements the same key.
    if (owner != null && owner != at) return false;

    final oldKey = _keys[at];
    if (oldKey != newKey) {
      _index.remove(oldKey);
      _index[newKey] = at;
      _keys[at] = newKey;
    }
    _items[at] = element;
    _changed();
    return true;
  }

  @override
  bool update(K key, T Function(T current) update) {
    final i = _index[key];
    if (i == null) return false;
    final updated = update(_items[i]);
    final actualKey = _keyOf(updated);
    if (actualKey != key) {
      throw ArgumentError.value(
        updated,
        'update',
        'Changed the key from $key to $actualKey; '
            'use replaceOneWhere or removeKey plus add instead',
      );
    }
    if (_items[i] == updated) return false;
    _items[i] = updated;
    _changed();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Removing
  // ---------------------------------------------------------------------------

  /// Removes position [i] without notifying.
  T _removeAtUnchecked(int i) {
    final removed = _items.removeAt(i);
    _index.remove(_keys.removeAt(i));
    _reindexFrom(i);
    return removed;
  }

  @override
  bool remove(T element) => removeKey(_keyOf(element)) != null;

  @override
  T? removeKey(K key) {
    final i = _index[key];
    if (i == null) return null;
    final removed = _removeAtUnchecked(i);
    _changed();
    return removed;
  }

  @override
  T removeAt(int index) {
    RangeError.checkValidIndex(index, this, 'index', _items.length);
    final removed = _removeAtUnchecked(index);
    _changed();
    return removed;
  }

  @override
  T removeLast() {
    if (_items.isEmpty) {
      throw StateError('Cannot remove the last element of an empty collection');
    }
    final removed = _items.removeLast();
    _index.remove(_keys.removeLast());
    _changed();
    return removed;
  }

  @override
  int removeAll(Iterable<T> elements) =>
      removeKeys([for (final element in elements) _keyOf(element)]);

  @override
  int removeKeys(Iterable<K> keys) {
    final doomed = {for (final key in keys) key};
    if (doomed.isEmpty) return 0;
    return _removeWhereKey(doomed.contains);
  }

  @override
  int retainKeys(Iterable<K> keys) {
    final survivors = {for (final key in keys) key};
    return _removeWhereKey((key) => !survivors.contains(key));
  }

  @override
  bool removeOneWhere(bool Function(T element) test) {
    final at = indexWhere(test);
    if (at < 0) return false;
    _removeAtUnchecked(at);
    _changed();
    return true;
  }

  @override
  int removeWhere(bool Function(T element) test) =>
      _compact((i) => !test(_items[i]));

  @override
  int retainWhere(bool Function(T element) test) =>
      _compact((i) => test(_items[i]));

  int _removeWhereKey(bool Function(K key) doomed) =>
      _compact((i) => !doomed(_keys[i]));

  /// Keeps the positions for which [survives] holds, in a single pass.
  /// Returns how many were removed.
  int _compact(bool Function(int index) survives) {
    var write = 0;
    for (var read = 0; read < _items.length; read++) {
      if (!survives(read)) continue;
      if (write != read) {
        _items[write] = _items[read];
        _keys[write] = _keys[read];
      }
      write++;
    }
    final removed = _items.length - write;
    if (removed == 0) return 0;
    _items.removeRange(write, _items.length);
    _keys.removeRange(write, _keys.length);
    _rebuildIndex();
    _changed();
    return removed;
  }

  @override
  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    _keys.clear();
    _index.clear();
    _changed();
  }

  // ---------------------------------------------------------------------------
  // Reconciling
  // ---------------------------------------------------------------------------

  @override
  SyncResult syncWith(Iterable<T> source, {bool preserveOrder = true}) =>
      batch(() {
        // Last one wins on duplicate keys, and preserves source order.
        final incoming = <K, T>{};
        for (final element in source) {
          incoming[_keyOf(element)] = element;
        }

        final removed = retainKeys(incoming.keys);

        var updated = 0;
        for (var i = 0; i < _items.length; i++) {
          final replacement = incoming[_keys[i]] as T;
          if (_items[i] != replacement) {
            _items[i] = replacement;
            updated++;
            _changed();
          }
        }

        var added = 0;
        for (final entry in incoming.entries) {
          if (_index.containsKey(entry.key)) continue;
          _appendUnchecked(entry.value, entry.key);
          added++;
          _changed();
        }

        if (!preserveOrder) {
          final order = incoming.keys.toList();
          for (var i = 0; i < order.length; i++) {
            final key = order[i];
            _items[i] = incoming[key] as T;
            _keys[i] = key;
          }
          _rebuildIndex();
          _changed();
        }

        return (added: added, updated: updated, removed: removed);
      });

  // ---------------------------------------------------------------------------
  // Ordering
  // ---------------------------------------------------------------------------

  /// Reorders [_items] and [_keys] according to [order], a permutation of the
  /// current positions.
  void _permute(List<int> order) {
    final items = [for (final i in order) _items[i]];
    final keys = [for (final i in order) _keys[i]];
    _items.setRange(0, _items.length, items);
    _keys.setRange(0, _keys.length, keys);
    _rebuildIndex();
    _changed();
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    if (_items.length < 2) return;
    final compareOrDefault = compare ??
        (T a, T b) => Comparable.compare(a as Comparable, b as Comparable);
    final order = List<int>.generate(_items.length, (i) => i);
    // Falling back to the original position makes the sort stable.
    order.sort((a, b) {
      final result = compareOrDefault(_items[a], _items[b]);
      return result != 0 ? result : a - b;
    });
    _permute(order);
  }

  @override
  void shuffle([Random? random]) {
    if (_items.length < 2) return;
    final order = List<int>.generate(_items.length, (i) => i)..shuffle(random);
    _permute(order);
  }

  @override
  void reorder(int oldIndex, int newIndex) {
    RangeError.checkValidIndex(oldIndex, this, 'oldIndex', _items.length);
    RangeError.checkValueInInterval(newIndex, 0, _items.length - 1, 'newIndex');
    if (oldIndex == newIndex) return;
    final element = _items.removeAt(oldIndex);
    final key = _keys.removeAt(oldIndex);
    _items.insert(newIndex, element);
    _keys.insert(newIndex, key);
    _reindexFrom(oldIndex < newIndex ? oldIndex : newIndex);
    _changed();
  }

  @override
  void swap(int indexA, int indexB) {
    RangeError.checkValidIndex(indexA, this, 'indexA', _items.length);
    RangeError.checkValidIndex(indexB, this, 'indexB', _items.length);
    if (indexA == indexB) return;
    final item = _items[indexA];
    final key = _keys[indexA];
    _items[indexA] = _items[indexB];
    _keys[indexA] = _keys[indexB];
    _items[indexB] = item;
    _keys[indexB] = key;
    _index[_keys[indexA]] = indexA;
    _index[_keys[indexB]] = indexB;
    _changed();
  }

  // ---------------------------------------------------------------------------
  // Set algebra
  // ---------------------------------------------------------------------------

  @override
  XUniqueList<T, K> union(Iterable<T> other) => copy()..addAll(other);

  @override
  XUniqueList<T, K> intersection(Iterable<T> other) {
    final wanted = {for (final element in other) _keyOf(element)};
    return XUniqueList<T, K>(_keyOf)
      ..addAll([
        for (var i = 0; i < _items.length; i++)
          if (wanted.contains(_keys[i])) _items[i],
      ]);
  }

  @override
  XUniqueList<T, K> difference(Iterable<T> other) {
    final excluded = {for (final element in other) _keyOf(element)};
    return XUniqueList<T, K>(_keyOf)
      ..addAll([
        for (var i = 0; i < _items.length; i++)
          if (!excluded.contains(_keys[i])) _items[i],
      ]);
  }

  @override
  XUniqueList<T, K> operator +(Iterable<T> other) => union(other);

  // ---------------------------------------------------------------------------
  // Value semantics
  // ---------------------------------------------------------------------------

  /// Whether [other] holds equal elements, per `==`, in the same order.
  ///
  /// Note that [hashCode] changes as the collection is mutated, so an
  /// [XUniqueList] must not be used as a `Map` key or `Set` element unless it
  /// is treated as immutable from then on.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XUniqueList<T, K> || other.length != length) return false;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i] != other._items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_items);

  @override
  String toString() => 'XUniqueList<$T, $K>${_items.toString()}';
}
