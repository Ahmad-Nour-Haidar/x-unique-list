# Changelog

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