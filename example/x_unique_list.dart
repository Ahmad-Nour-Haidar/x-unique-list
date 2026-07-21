// ignore_for_file: avoid_print

import 'package:x_unique_list/x_unique_list.dart';

class User {
  final int id;
  final String name;

  const User(this.id, this.name);

  @override
  String toString() => 'User($id, $name)';

  // `==` compares the whole value; uniqueness is decided by `id` alone.
  // That separation is the point of XUniqueList.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

void main() {
  basics();
  keyBasedAccess();
  pagination();
  observing();
}

void basics() {
  print('--- basics ---');

  final users = XUniqueList<User, int>((u) => u.id);

  print(users.add(const User(1, 'Ahmad'))); // true
  print(users.add(const User(2, 'John'))); // true
  print(users.add(const User(1, 'Impostor'))); // false — id 1 is taken

  // Same id, different value: replaced in place, keeping its position.
  print(users.addOrReplace(const User(1, 'Ahmad Nour'))); // true
  print(users.addOrReplace(const User(1, 'Ahmad Nour'))); // false — no change

  // It is an Iterable, so everything you expect just works.
  for (final user in users) {
    print(user);
  }
  print(users.map((u) => u.name).join(', '));
  print([...users].length);
}

void keyBasedAccess() {
  print('\n--- key based access, all O(1) ---');

  final users = XUniqueList<User, int>.from(
    const [User(1, 'Ahmad'), User(2, 'John'), User(3, 'Sara')],
    (u) => u.id,
  );

  print(users.lookup(2)); // User(2, John)
  print(users.containsKey(9)); // false
  print(users.indexOfKey(3)); // 2

  // Edit in place without rebuilding the element yourself.
  users.update(2, (u) => User(u.id, u.name.toUpperCase()));
  print(users.lookup(2)); // User(2, JOHN)

  // No need to fabricate a whole User just to delete one.
  print(users.removeKey(1)); // User(1, Ahmad)
  print(users.items);
}

void pagination() {
  print('\n--- syncWith: reconciling against a server response ---');

  final products = XUniqueList<User, int>.from(
    const [User(1, 'a'), User(2, 'b'), User(3, 'c')],
    (u) => u.id,
  );

  // The server dropped 2, renamed 3, and added 4.
  final result = products.syncWith(const [
    User(1, 'a'),
    User(3, 'c renamed'),
    User(4, 'd'),
  ]);

  print(result); // (added: 1, removed: 1, updated: 1)
  print(products.items); // [User(1, a), User(3, c renamed), User(4, d)]

  // Untouched elements keep their identity, so a UI diffing on `==` will not
  // rebuild them.
}

void observing() {
  print('\n--- observing changes ---');

  final users = XObservableUniqueList<User, int>((u) => u.id)
    ..addListener(() => print('changed!'));

  users.add(const User(1, 'Ahmad')); // changed!

  // A bulk call notifies once, not once per element.
  users.addAll(const [User(2, 'John'), User(3, 'Sara')]); // changed!

  // So does an explicit batch of individual calls.
  users.batch(() {
    users.removeKey(1);
    users.add(const User(4, 'Lina'));
    users.sort((a, b) => a.name.compareTo(b.name));
  }); // changed!

  print(users.items);
  users.dispose();
}
