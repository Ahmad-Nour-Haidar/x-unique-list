# XUniqueList - A Dart/Flutter Package for Managing Unique Lists

`XUniqueList` is a utility package that ensures uniqueness in your lists based on a custom condition
you define. It's perfect for managing collections of objects that must adhere to specific uniqueness
rules.

## 📜 Table of Contents

- [✨ Features](#-features)
- [🚀 Getting Started](#-getting-started)
- [📝 Usage](#-usage)
- [🧩 Methods](#-methods)
- [🔜 Next Steps](#-next-steps)
- [📄 License](#-license)

## ✨ Features

- 🆕 **Unique List Management**: Add, insert, or remove items while ensuring no duplicates based on a
  custom condition.
- 🚀 **Fast Operations**: Optimized operations for adding, removing, and filtering items.
- 🔄 **Replace & Modify**: Replace items by condition or unique value.
- 🔍 **Check for Existence**: Quickly check if an item exists based on the uniqueness condition.
- 📦 **Unmodifiable and Modifiable Access**: Retrieve unmodifiable and modifiable versions of the
  list as needed.

## 🚀 Getting Started

To start using `XUniqueList`, you need to add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  x_unique_list: ^1.0.5
```

```bash
flutter pub get
```

```bash
dart pub get
```

## 📝 Usage

Here’s an example of using `XUniqueList` with a custom `uniqueCondition` based on the `id` field of
a `User` class:

```dart
import 'package:x_unique_list/x_unique_list.dart';

class User {
  final int id;
  final String name;

  User(this.id, this.name);

  @override
  String toString() => 'User(id: $id, name: $name)';

  // Override equality operator to compare both id and name
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is User && id == other.id && name == other.name);

  @override
  int get hashCode => Object.hash(id, name);
}

void main() {
  // Define a unique condition (in this case, users are unique by their ID)
  final uniqueUsers = XUniqueList<User>((user) => user.id);

  // Add users
  uniqueUsers.add(User(1, 'Ahmad'));
  uniqueUsers.add(User(2, 'Nour'));

  // Attempt to add a duplicate user (will not be added)
  uniqueUsers.add(User(1, 'Ahmad')); // This won't be added as ID 1 already exists

  // Retrieve unmodifiable list of users
  print(uniqueUsers.items); // [User(id: 1, name: Ahmad), User(id: 2, name: Nour)]

  // Remove a user - ⚠️ NOTE: This may not work as expected
  // ⚠️ Won't work unless you override `==` and `hashCode` for User
  uniqueUsers.remove(User(2, 'Nour'));

  // Explanation:
  // The `remove` method uses the `==` operator to check if the items match.
  // By default, Dart compares objects by their memory reference, not by the fields inside the object.
  // To make this work, you need to either manually override the `==` operator and `hashCode`
  // for your model (as shown above), or use third-party libraries like `equatable`, `freezed`, etc.

  // As an alternative, you can use `removeOneWhere` to remove an item by a condition
  uniqueUsers.removeOneWhere((user) => user.id == 2); // Works even without `==` override

  // Check if list contains a user
  // ⚠️ Important Note on `contains` Method
  // 
  // The `contains` method in `XUniqueList` relies on the `uniqueCondition` you define.
  // In the example above, the `uniqueCondition` is based on the `id` field of the `User` class.
  //
  // This means that when you check for the existence of an item using `contains`,
  // it only considers the value provided by the `uniqueCondition` function, not the entire object.
  //
  // For instance:
  bool exists = uniqueUsers.contains(User(1, 'Ahmad'));
  print(exists); // true
  // Even though the name 'Ahmad' is different from any existing user, the contains method returns true
  // because the id field (which is the unique condition) matches the ID of an existing user (ID = 1).

  // To check for existence or remove items based on different criteria (such as the name),
  // you can use the removeOneWhere method, which allows for more complex condition-based logic.
}
```

## 🧩 Methods

The `XUniqueList` class provides various methods for managing unique lists. Here is a comprehensive
overview of all the methods available:

### `List<T> get items;`

- **Description**: Retrieve items as an unmodifiable list.

### `List<T> get data;`

- **Description**: Retrieve items as a modifiable list.

### `T operator [](int index);`

- **Description**: The object at the given [index] in the list.

### `bool add(T item);`

- **Description**: Add a single item.

### `int addAll(List<T> newItems);`

- **Description**: Add multiple items.
- **Returns**: The number of items that were successfully added.

### `bool insert(int index, T item);`

- **Description**: Insert an item at the specified index.
- **Returns**: True if the item was inserted successfully, false if the item already exists.

### `int insertAll(int index, Iterable<T> newItems);`

- **Description**: Insert multiple items at the specified index.
- **Returns**: The number of items that were successfully inserted.

### `bool remove(T item);`

- **Description**: Remove a single item.

### `bool removeOneWhere(bool Function(T) test);`

- **Description**: Remove a single item based on a condition.
- **Returns**: True if an item was removed, false otherwise.

### `void removeWhere(bool Function(T e) test);`

- **Description**: Remove items based on a condition.

### `bool replaceOne(T newItem);`

- **Description**: Replace an existing item with a new item based on unique condition.

### `bool replaceOneWhere(T newItem, bool Function(T) test);`

- **Description**: Replace item that matches a condition with a new item.

### `void sort([int Function(T a, T b)? compare]);`

- **Description**: Sort the list in place using the provided [compare] function. If no [compare]
  function is provided, the list is sorted in natural order.

### `List<T> where(bool Function(T) test);`

- **Description**: Method to filter items based on a condition.

### `T? firstWhere(bool Function(T) test);`

- **Description**: Retrieve a single item based on a condition.

### `int indexWhere(bool Function(T) test);`

- **Description**: Returns the index of the first item that satisfies the provided [test] function.
- **Returns**: -1 if no such item is found.

### `int indexOf(T item);`

- **Description**: Returns the index of the first occurrence of [item] in the list.
- **Returns**: -1 if the item is not found.

### `bool contains(T item);`

- **Description**: Check if the list contains an item based on the unique condition.

### `int get length;`

- **Description**: Get the length of the list.

### `bool get isEmpty;`

- **Description**: Check if the list is empty.

### `bool get isNotEmpty;`

- **Description**: Check if the list is not empty.

### `void clear();`

- **Description**: Clear all items from the list and set.

## 🔜 Next Steps

### Adding Helper Methods

In future updates, we plan to introduce additional helper methods to further enhance the
functionality of the `XUniqueList` class.

## 📄 License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.