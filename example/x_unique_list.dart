import 'package:x_unique_list/x_unique_list.dart';

class User {
  final int id;
  final String name;

  User(this.id, this.name);

  @override
  String toString() => 'User(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User && id == other.id && name == other.name);

  @override
  int get hashCode => Object.hash(id, name);
}

void main() {
  // Uniqueness based on `id`
  final users = XUniqueList<User>((u) => u.id);

  users.add(User(1, 'Ahmad'));
  users.add(User(2, 'John'));

  // ❌ Same id → will NOT be added
  users.add(User(1, 'Duplicate'));

  // ✅ Replace (same id, different value)
  users.addOrReplace(User(1, 'Updated Ahmad'));

  // ❌ No-op (identical item)
  final result = users.addOrReplace(User(1, 'Updated Ahmad'));
  print('Was added/replaced? $result'); // false

  // Remove by condition (safe)
  users.removeOneWhere((u) => u.id == 2);

  print('\nFinal users:');
  for (final u in users.items) {
    print(u);
  }
}
