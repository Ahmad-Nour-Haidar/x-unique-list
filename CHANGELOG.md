# Changelog

## 2.0.0

A correctness and performance release. See the migration table in the README.

### 🐛 Fixed

- **`replaceOneWhere()` could corrupt the collection.** When the replacement's key already belonged
  to another element, it overwrote the matched element anyway and removed the *old* key from the
  index — leaving two elements sharing one key, a `length` that disagreed with the index, and a
  `contains()` that returned `false` for an element that was present. It now refuses the
  replacement and returns `false`. **If you use this method, upgrade.**
- **`items` handed out the live internal list**, so `list.items.add(x)` bypassed every uniqueness
  check. It is now an unmodifiable view.
- **`clear()` replaced the internal list** instead of emptying it, silently detaching any `items`
  reference a caller was already holding. It now clears in place.
- Argument validation used `assert`, which is stripped in release builds. It now throws
  `RangeError` / `ArgumentError` consistently in every mode.

### ⚡ Performance

- Rebuilt on a key → position index. `lookup`, `containsKey`, `contains`, `indexOf`, `indexOfKey`,
  `addOrReplace`, `replaceOne` and `update` are now **O(1)**; they were O(n).
- The key function is now called **once per element**, when the element is inserted, instead of
  O(n) times per operation. Expensive key functions no longer dominate the cost.
- `sort()` is now **stable**, unlike `List.sort`.

### ✨ Added

- **`Iterable<T>` conformance** — `for (final x in list)`, `map`, `where`, `fold`, `any`, `[...list]`
  and the rest of the `Iterable` API now work directly on the collection.
- **`syncWith(source, {preserveOrder})`** — reconciles the collection against a source: adds what is
  new, replaces what changed, removes what disappeared, leaves equal elements untouched. Returns
  `(added:, updated:, removed:)`.
- **Key-based API**: `lookup`, `containsKey`, `indexOfKey`, `removeKey`, `removeKeys`, `retainKeys`,
  `putIfAbsent`, `update`, `keys`, `keyOf`, `toMap`.
- **`XObservableUniqueList`** — notifies listeners on change, pure Dart, with `batch()` to coalesce
  a group of mutations into a single notification. Bulk operations already notify once.
- **`XUniqueListBase<T, K>`** — a public interface to depend on when faking the collection in tests.
- List essentials: `operator []=`, `first`, `last`, `removeAt`, `removeLast`, `removeAll`,
  `retainWhere`, `sublist`, `reversed`, `shuffle`, `firstWhereOrNull`, `lastWhereOrNull`.
- Reordering: `reorder(oldIndex, newIndex)` and `swap(a, b)`, for drag-and-drop lists.
- Set algebra: `union`, `intersection`, `difference`, `operator +`.
- Constructors and value semantics: `XUniqueList.from`, `copy()`, `operator ==`, `hashCode`,
  `toString()`.

### 💥 Breaking

- `XUniqueList<T>` is now `XUniqueList<T, K>`; the key type is explicit and bound to `Object`, so
  keys can no longer be `null`.
- `items` is unmodifiable. Use `toList()` for a modifiable copy.
- `firstWhere` now throws `StateError` when nothing matches, matching `Iterable`. The old
  null-returning behaviour is available as `firstWhereOrNull`.
- `removeWhere` returns the number removed instead of `void`.
- `addAllOrReplace` returns `(added:, updated:)` instead of a single `int`.
- `contains` accepts `Object?` and returns `false` for non-`T` values, matching `Iterable`.
- `unmodifiableItems` is deprecated in favour of `items`; it will be removed in 3.0.0.

### 📚 Documentation & tooling

- Documentation moved onto the public `XUniqueListBase` interface, so it now renders on pub.dev
  (previously it lived on a private class and was invisible).
- Test suite rewritten: an invariant harness asserted after every mutation, plus a fuzz test that
  cross-checks 20,000 random operations against a naive reference implementation.
- Added CI (format, analyze with `--fatal-infos`, test on the oldest and newest supported SDK,
  publish dry-run), stricter analysis options, and a `.pubignore` so IDE files stay out of the
  published archive.

## 1.1.1
- 📝 README.md

## 1.1.0

### ✨ Added

- Added `addOrReplace()`:
    - Adds item if unique key does not exist.
    - Replaces existing item if key matches but value differs.
    - Returns `false` if identical item already exists (no-op).
- Added `addAllOrReplace()`:
    - Batch version of `addOrReplace`.
    - Returns count of items added + replaced.

### 🔧 Improved

- `remove()`:
    - No longer relies on `==` for removal.
    - Now removes based on `uniqueCondition` → more predictable behavior.
- `removeWhere()`:
    - Now correctly keeps `_uniqueItemsSet` in sync with `_itemsList`.
    - Fixes potential data corruption bug.
- `firstWhere()`:
    - Removed exception-based flow.
    - Now uses safe iteration → avoids unnecessary try/catch overhead.
- `where()`:
    - Returns `Iterable<T>` instead of `List<T>` to avoid unnecessary allocation.
- `addAll()`:
    - Now accepts `Iterable<T>` instead of `List<T>` → more flexible API.
- `insertAll()`:
    - Improved documentation and clarified complexity behavior.
- `unmodifiableItems`:
    - Uses `List<T>.unmodifiable` explicitly.

### ⚡ Performance

- Reduced unnecessary allocations:
    - `where()` no longer creates a new list.
- Improved predictability of operations by aligning all mutations with `_uniqueItemsSet`.
- Documented precise time complexity for all public methods.

### 🐛 Fixed

- Critical bug where `removeWhere()` did not update `_uniqueItemsSet`.
- Potential inconsistency between `_itemsList` and `_uniqueItemsSet`.
- Edge cases in `remove()` where item existed in set but not properly removed from list.

### 🧠 Behavioral Changes

- `remove(T item)`:
    - Now removes based on `uniqueCondition` instead of relying on object equality.
- `addOrReplace()`:
    - Explicitly distinguishes between:
        - add
        - replace
        - no-op (identical item)

### 📚 Documentation

- Added detailed time complexity annotations for all methods.
- Improved method-level comments for clarity and maintainability.

---

## 1.0.7

### 🔄 Changes:

- 🔧 Fix example

## 1.0.6

### 🔄 Changes:

- ✨ Improve

## 1.0.5

### 🔄 Changes:

- ➕ Add example

## 1.0.4

### 🔄 Changes:

- Improved `README.md` to provide clearer documentation and examples.

## 1.0.3

### 🔄 Changes:

- Improved `README.md` to provide clearer documentation and examples.

## 1.0.2

### 🔄 Changes:

- Improved `README.md` to provide clearer documentation and examples.
    - Added detailed sections for installation, usage, and methods.
    - Updated examples and explanations for better clarity.

## 1.0.1 - Support for Dart and Flutter 🛠

### 🔄 Changes:

- Added support for both Dart and Flutter environments.
- Improved compatibility and removed unnecessary Flutter dependencies.
- Fixed minor bugs in list manipulation functions.

## 1.0.0 - Initial Release 🎉

### ✨ Features:

- `XUniqueList` with uniqueness enforcement via `uniqueCondition`.
- Core operations: `add`, `addAll`, `insert`, `remove`, `replaceOne`, etc.

### 🛠 Utility Functions:

- `contains`, `clear`, `length`, `isEmpty`, `isNotEmpty`.

### 📦 Access:

- `items` (modifiable)
- `unmodifiableItems`

### ✅ Testing:

- Unit tests for core functionality.