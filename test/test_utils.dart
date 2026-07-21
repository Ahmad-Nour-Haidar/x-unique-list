import 'package:test/test.dart';
import 'package:x_unique_list/x_unique_list.dart';

/// A value type whose identity (`id`) is distinct from its equality (`id` and
/// `name`), which is exactly the situation [XUniqueList] exists to handle.
class User {
  final int id;
  final String name;

  const User(this.id, this.name);

  @override
  String toString() => 'User($id, $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

XUniqueList<User, int> userList([Iterable<User> initial = const []]) =>
    XUniqueList<User, int>.from(initial, (u) => u.id);

/// Asserts every structural guarantee the collection makes, using only its
/// public API.
///
/// Call this after *every* mutation in a test: it is what turns a test of one
/// method into a test of the whole data structure.
void expectInvariants<T, K extends Object>(
  XUniqueListBase<T, K> list, {
  String reason = '',
}) {
  final where = reason.isEmpty ? '' : ' ($reason)';

  final items = list.items;
  final keys = list.keys.toList();

  expect(items, hasLength(list.length), reason: 'items/length disagree$where');
  expect(keys, hasLength(list.length), reason: 'keys/length disagree$where');

  expect(
    keys.toSet(),
    hasLength(keys.length),
    reason: 'duplicate keys leaked into the collection$where: $keys',
  );

  for (var i = 0; i < items.length; i++) {
    final key = keys[i];
    expect(
      list.keyOf(items[i]),
      key,
      reason: 'keys[$i] does not describe items[$i]$where',
    );
    expect(list.indexOfKey(key), i, reason: 'index of $key is stale$where');
    expect(list.lookup(key), same(items[i]),
        reason: 'lookup($key) wrong$where');
    expect(list.containsKey(key), isTrue, reason: 'containsKey($key)$where');
    expect(list.contains(items[i]), isTrue,
        reason: 'contains(items[$i])$where');
    expect(list[i], same(items[i]), reason: 'operator [] disagrees$where');
    expect(list.indexOf(items[i]), i, reason: 'indexOf disagrees$where');
  }

  expect(list.toMap(), hasLength(list.length), reason: 'toMap size$where');
  expect(list.isEmpty, items.isEmpty, reason: 'isEmpty$where');
  expect(list.isNotEmpty, items.isNotEmpty, reason: 'isNotEmpty$where');
  expect(list.toList(), items, reason: 'iteration order$where');
}
