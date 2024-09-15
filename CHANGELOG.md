# Changelog

## 1.0.2

### 🔄 Changes:

- Improved `README.md` to provide clearer documentation and examples.
    - Added detailed sections for installation, usage, and methods.
    - Updated examples and explanations for better clarity.

## 1.0.1 - Support for Dart and Flutter 🛠

### 🔄 Changes:

- Added support for both Dart and Flutter environments, making the package versatile across
  projects.
- Improved compatibility and removed unnecessary Flutter dependencies for Dart-only projects.
- Fixed minor bugs in list manipulation functions for better performance and stability.

## 1.0.0 - Initial Release 🎉

### ✨ Features:

- **XUniqueList** class with uniqueness enforcement using `uniqueCondition`.
- Added the following methods:
    - `add()`: Add a single item ensuring uniqueness.
    - `addAll()`: Add multiple items at once.
    - `insert()`: Insert an item at a specified index.
    - `remove()`: Remove an item by value.
    - `removeOneWhere()`: Remove the first item that matches a condition.
    - `replaceOneWhere()`: Replace an item based on a matching condition.
    - `replaceOne()`: Replace an item if it matches based on unique condition.

### 🛠 Utility Functions:

- `contains()`: Check if an item is in the list based on the unique condition.
- `clear()`: Clear all items from the list.
- `length`: Retrieve the number of items in the list.
- `isEmpty` and `isNotEmpty`: Check if the list is empty or not.

### 📦 Access:

- `items`: Retrieve an unmodifiable list of items.
- `data`: Retrieve a modifiable list of items.

### ✅ Testing:

- Unit tests provided for all major functionality ensuring correctness and reliability.
