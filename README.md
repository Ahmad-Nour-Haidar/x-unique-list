# XUniqueList

An ordered Dart collection in which **no two elements share the same key** — and you decide what
the key is.

`Set` and `Map` decide identity with `==`. That is rarely what you want for domain models: two
`User` objects with the same `id` but a different `name` are the *same user*, and a `Set` will
happily hold both. `XUniqueList` lets you say "identity is `id`" and then keeps that promise, while
preserving order like a `List`.

```dart
final users = XUniqueList<User, int>((u) => u.id);

users.add(User(1, 'Ahmad'));              // true
users.add(User(1, 'Impostor'));           // false — id 1 is taken
users.addOrReplace(User(1, 'Ahmad N.'));  // true  — replaced in place

users.lookup(1);       // O(1)
users.containsKey(1);  // O(1)
users.removeKey(1);    // located in O(1)
```

[![pub package](https://img.shields.io/pub/v/x_unique_list.svg)](https://pub.dev/packages/x_unique_list)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

- **Zero dependencies.** Pure Dart — works in Flutter, on the server, and on the web.
- **O(1) where it counts.** Lookup, membership, upsert and replace are constant time.
- **A real `Iterable`.** `for (final u in users)`, `users.map(...)`, `[...users]` all work.
- **Order preserving.** Insertion order by default, with `sort`, `reorder` and `swap`.

| Android | iOS | Web | macOS | Linux | Windows |
|:-------:|:---:|:---:|:-----:|:-----:|:-------:|
|   ✅    | ✅  | ✅  |  ✅   |  ✅   |   ✅    |

## Install

```yaml
dependencies:
  x_unique_list: ^2.0.0
```

```dart
import 'package:x_unique_list/x_unique_list.dart';
```

## Why not just a `Map`?

A `Map<int, User>` gives you O(1) by id but leaks the key into every call site, and its ordering
guarantees stop at insertion order — you cannot sort it, insert at an index, or reorder it.
A `List<User>` gives you order but every uniqueness check is an O(n) scan you have to write
yourself. `XUniqueList` is both: a list that indexes itself by a key you choose.

## Choosing a key

The key can be any non-null type. Dart records make composite keys effortless:

```dart
// Unique by id
XUniqueList<User, int>((u) => u.id);

// Unique by email, case-insensitively
XUniqueList<User, String>((u) => u.email.toLowerCase());

// Unique by the pair (tenant, id)
XUniqueList<User, (String, int)>((u) => (u.tenantId, u.id));
```

> **Keys must be stable.** An element's key is computed **once**, when it enters the collection, and
> remembered from then on. Mutating the field a key was derived from will not update the
> bookkeeping — the element stays findable under its original key. Prefer `final` key fields.

## Reconciling with a server: `syncWith`

The problem `addAll` cannot solve — a refresh where items were *deleted* upstream:

```dart
final products = XUniqueList<Product, int>((p) => p.id);
products.addAll(await api.fetch());     // [1, 2, 3, 4, 5]

// Meanwhile 2 and 4 are deleted on the server, 3 is renamed, 9 is new.
final result = products.syncWith(await api.fetch());

print(result);         // (added: 1, updated: 1, removed: 2)
print(products.items); // [1, 3(renamed), 5, 9]
```

`syncWith` adds what is new, replaces what changed, removes what disappeared, and — importantly —
**leaves unchanged elements untouched**, so a UI that diffs on `==` will not rebuild them.

By default survivors keep their positions and newcomers are appended. Pass `preserveOrder: false`
to adopt the source's order instead (for server-controlled sorting).

## Observing changes

`XObservableUniqueList` notifies listeners on every change, without pulling in Flutter:

```dart
final users = XObservableUniqueList<User, int>((u) => u.id)
  ..addListener(() => print('changed'));

users.addAll([a, b, c]);  // one notification, not three

users.batch(() {          // one notification for the whole group
  users.removeKey(1);
  users.add(d);
  users.sort((a, b) => a.name.compareTo(b.name));
});
```

Bridging to Flutter is a few lines:

```dart
class UserStore extends ChangeNotifier {
  final users = XObservableUniqueList<User, int>((u) => u.id);

  UserStore() {
    users.addListener(notifyListeners);
  }

  @override
  void dispose() {
    users.removeListener(notifyListeners);
    users.dispose();
    super.dispose();
  }
}
```

## API

### Access

| Member | Cost | Notes |
|---|---|---|
| `items` | O(1) | Unmodifiable **view**, reflects later changes |
| `toList()` | O(n) | Independent modifiable copy |
| `keys` | O(1) | Keys in element order |
| `list[i]` / `list[i] = v` | O(1) | Throws if the assignment would duplicate a key |
| `lookup(key)` | O(1) | The element, or `null` |
| `containsKey(key)` | O(1) | |
| `contains(element)` | O(1) | Compares by **key**, not `==` |
| `indexOfKey(key)` / `indexOf(e)` | O(1) | `-1` when absent |
| `indexWhere` / `firstWhereOrNull` / `lastWhereOrNull` | O(n) | |
| `toMap()` / `copy()` / `sublist` / `reversed` | O(n) | |

### Adding and replacing

| Member | Cost | Returns |
|---|---|---|
| `add(e)` | O(1) | `false` if the key is taken |
| `addAll(es)` | O(m) | count added |
| `insert(i, e)` / `insertAll(i, es)` | O(n) | as above |
| `addOrReplace(e)` | O(1) | `false` if an equal element is already stored |
| `addAllOrReplace(es)` | O(m) | `(added:, updated:)` |
| `putIfAbsent(key, ifAbsent)` | O(1) | the stored or newly inserted element |
| `replaceOne(e)` | O(1) | replaces the element sharing `e`'s key |
| `replaceOneWhere(e, test)` | O(n) | `false` rather than duplicating a key |
| `update(key, fn)` | O(1) | edits in place; throws if `fn` changes the key |

### Removing

`remove(e)` · `removeKey(key)` · `removeAt(i)` · `removeLast()` · `removeAll(es)` ·
`removeKeys(keys)` · `removeOneWhere(test)` · `removeWhere(test)` · `retainWhere(test)` ·
`retainKeys(keys)` · `clear()`

The bulk variants return how many elements they removed.

### Ordering and algebra

`sort([compare])` — **stable**, unlike `List.sort` · `shuffle([random])` · `reorder(from, to)` ·
`swap(a, b)` · `union` · `intersection` · `difference` · `operator +`

### Testing your own code

Depend on `XUniqueListBase<T, K>` rather than the concrete class when you want to fake the
collection in your tests.

## Migrating from 1.x

2.0.0 fixes a bug in `replaceOneWhere` that could put two elements with the same key into the
collection, corrupting it permanently. If you use that method, upgrading is strongly recommended.

| 1.x | 2.0.0 |
|---|---|
| `XUniqueList<User>((u) => u.id)` | `XUniqueList<User, int>((u) => u.id)` — the key type is now explicit |
| `list.items.add(x)` | No longer possible; `items` is unmodifiable. Use `list.add(x)` |
| `list.unmodifiableItems` | `list.items` (deprecated alias kept until 3.0.0) |
| `list.firstWhere(test)` returning `null` | `list.firstWhereOrNull(test)`. `firstWhere` now throws, matching `Iterable` |
| `list.removeWhere(test)` returning `void` | Now returns the number removed |
| `list.addAllOrReplace(es)` returning `int` | Now returns `(added:, updated:)` |
| `list.remove(x)` on a corrupted list | `remove` now also accepts `removeKey(k)` — no need to fabricate an element |
| Iterating via `list.items` | `list` is itself an `Iterable`; iterate it directly |

Keys may no longer be `null`: the key type is bound to `Object`. If you relied on a nullable key,
map it to a sentinel value instead.

## License

MIT — see [LICENSE](LICENSE).
