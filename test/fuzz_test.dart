import 'dart:math';

import 'package:test/test.dart';

import 'test_utils.dart';

/// A deliberately naive reference implementation: a plain list kept unique by
/// linear scan. It is obviously correct and obviously slow, which is exactly
/// what a reference model should be.
class ReferenceList {
  final List<User> items = [];

  int indexOfKey(int id) => items.indexWhere((u) => u.id == id);

  bool add(User u) {
    if (indexOfKey(u.id) >= 0) return false;
    items.add(u);
    return true;
  }

  bool addOrReplace(User u) {
    final i = indexOfKey(u.id);
    if (i < 0) {
      items.add(u);
      return true;
    }
    if (items[i] == u) return false;
    items[i] = u;
    return true;
  }

  bool insert(int index, User u) {
    if (indexOfKey(u.id) >= 0) return false;
    items.insert(index, u);
    return true;
  }

  bool removeKey(int id) {
    final i = indexOfKey(id);
    if (i < 0) return false;
    items.removeAt(i);
    return true;
  }

  bool replaceOneWhere(User u, bool Function(User) test) {
    final at = items.indexWhere(test);
    if (at < 0) return false;
    final owner = indexOfKey(u.id);
    if (owner >= 0 && owner != at) return false;
    items[at] = u;
    return true;
  }

  void syncWith(List<User> source) {
    final incoming = <int, User>{};
    for (final u in source) {
      incoming[u.id] = u;
    }
    items.removeWhere((u) => !incoming.containsKey(u.id));
    for (var i = 0; i < items.length; i++) {
      items[i] = incoming[items[i].id]!;
    }
    for (final entry in incoming.entries) {
      if (indexOfKey(entry.key) < 0) items.add(entry.value);
    }
  }
}

void main() {
  test('matches a reference implementation over 20k random operations', () {
    // Fixed seed: a failure is reproducible rather than a flake.
    final random = Random(20260721);
    final subject = userList();
    final reference = ReferenceList();

    User randomUser() => User(random.nextInt(25), 'n${random.nextInt(4)}');

    for (var step = 0; step < 20000; step++) {
      final user = randomUser();

      switch (random.nextInt(9)) {
        case 0:
          expect(subject.add(user), reference.add(user), reason: 'add @$step');
        case 1:
          expect(
            subject.addOrReplace(user),
            reference.addOrReplace(user),
            reason: 'addOrReplace @$step',
          );
        case 2:
          final index =
              subject.isEmpty ? 0 : random.nextInt(subject.length + 1);
          expect(
            subject.insert(index, user),
            reference.insert(index, user),
            reason: 'insert @$step',
          );
        case 3:
          expect(
            subject.removeKey(user.id) != null,
            reference.removeKey(user.id),
            reason: 'removeKey @$step',
          );
        case 4:
          final name = 'n${random.nextInt(4)}';
          expect(
            subject.replaceOneWhere(user, (u) => u.name == name),
            reference.replaceOneWhere(user, (u) => u.name == name),
            reason: 'replaceOneWhere @$step',
          );
        case 5:
          final threshold = random.nextInt(25);
          final before = subject.length;
          subject.removeWhere((u) => u.id < threshold);
          reference.items.removeWhere((u) => u.id < threshold);
          expect(subject.length, lessThanOrEqualTo(before));
        case 6:
          final source = [
            for (var i = random.nextInt(6); i > 0; i--) randomUser()
          ];
          subject.syncWith(source);
          reference.syncWith(source);
        case 7:
          subject.sort((a, b) => a.id.compareTo(b.id));
          reference.items.sort((a, b) => a.id.compareTo(b.id));
        case 8:
          if (subject.length >= 2) {
            final from = random.nextInt(subject.length);
            final to = random.nextInt(subject.length);
            subject.reorder(from, to);
            final moved = reference.items.removeAt(from);
            reference.items.insert(to, moved);
          }
      }

      expect(
        subject.items,
        reference.items,
        reason: 'diverged from the reference at step $step',
      );
      expectInvariants(subject, reason: 'step $step');
    }
  });

  test('survives a long run of interleaved bulk operations', () {
    final random = Random(7);
    final list = userList();

    for (var step = 0; step < 2000; step++) {
      final batchOfUsers = [
        for (var i = random.nextInt(8); i > 0; i--)
          User(random.nextInt(40), 'v${random.nextInt(3)}'),
      ];

      switch (step % 5) {
        case 0:
          list.addAll(batchOfUsers);
        case 1:
          list.addAllOrReplace(batchOfUsers);
        case 2:
          list.insertAll(
            list.isEmpty ? 0 : random.nextInt(list.length),
            batchOfUsers,
          );
        case 3:
          list.syncWith(batchOfUsers, preserveOrder: random.nextBool());
        case 4:
          list.removeAll(batchOfUsers);
      }

      expectInvariants(list, reason: 'step $step');
    }
  });
}
