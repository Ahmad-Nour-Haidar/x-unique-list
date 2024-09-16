import 'package:x_unique_list/x_unique_list.dart';

// A simple class to represent a user
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
  // Create an XUniqueList of Users, where uniqueness is based on the 'id' field
  final XUniqueList<User> uniqueUsers = XUniqueList((user) => user.id);

  // Add some users
  uniqueUsers.add(User(1, 'Ahmad'));
  uniqueUsers.add(User(2, 'John'));
  uniqueUsers.add(User(3, 'Alice'));

  // Try to add a user with the same 'id' (will not be added due to uniqueness condition)
  uniqueUsers.add(User(1, 'Duplicate Ahmad'));

  // Print the list of users
  print('Users in the list:');
  for (final user in uniqueUsers.items) {
    print(user);
  }

  // Check if a user exists in the list (based on the unique condition, i.e., 'id')
  bool exists = uniqueUsers.contains(User(1, 'Ahmad'));
  print('\nDoes user with id 1 exist? $exists');

  // Replace a user
  uniqueUsers.replaceOne(User(1, 'Updated Ahmad'));

  // Remove a user by object comparison
  uniqueUsers.remove(User(2, 'John'));

  // ⚠️ Note: This won't work unless the User class supports equality (== operator).
  // If you override the == operator and hashCode in the User class, this method will work.
  // Otherwise, you should use the "removeOneWhere" method to remove an item based on a condition:

  // Correct way: use removeOneWhere to remove a user based on a condition
  uniqueUsers.removeOneWhere((user) => user.id == 2);

  // Print the updated list of users
  print('\nUsers after updates:');
  for (final user in uniqueUsers.items) {
    print(user);
  }
}

/// Output:
// Users in the list:
// User(id: 1, name: Ahmad)
// User(id: 2, name: John)
// User(id: 3, name: Alice)
//
// Does user with id 1 exist? true
//
// Users after updates:
// User(id: 1, name: Updated Ahmad)
// User(id: 3, name: Alice)
