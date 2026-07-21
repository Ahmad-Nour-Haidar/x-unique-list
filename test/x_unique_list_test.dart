import 'package:test/test.dart';
import 'package:x_unique_list/x_unique_list.dart';

import 'test_utils.dart';

void main() {
  group('construction', () {
    test('starts empty', () {
      final list = userList();
      expect(list, isEmpty);
      expect(list.length, 0);
      expectInvariants(list);
    });

    test('from() keeps the first element of each duplicated key', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(1, 'shadowed'),
      ]);
      expect(list.items, [const User(1, 'a'), const User(2, 'b')]);
      expectInvariants(list);
    });

    test('copy() is independent but shares the key function', () {
      final original = userList([const User(1, 'a')]);
      final duplicate = original.copy()..add(const User(2, 'b'));

      expect(original.length, 1);
      expect(duplicate.length, 2);
      expect(duplicate.keyOf(const User(9, 'x')), 9);
      expectInvariants(original);
      expectInvariants(duplicate);
    });
  });

  group('add', () {
    test('appends a new key and rejects a taken one', () {
      final list = userList();
      expect(list.add(const User(1, 'a')), isTrue);
      expect(list.add(const User(1, 'different name')), isFalse);
      expect(list.items, [const User(1, 'a')]);
      expectInvariants(list);
    });

    test('addAll counts only what it appended', () {
      final list = userList([const User(1, 'a')]);
      final added = list.addAll([
        const User(1, 'dup'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);
      expect(added, 2);
      expect(list.length, 3);
      expectInvariants(list);
    });
  });

  group('insert', () {
    test('places the element at the requested index', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(list.insert(0, const User(3, 'c')), isTrue);
      expect(list.items.map((u) => u.id), [3, 1, 2]);
      expectInvariants(list);
    });

    test('rejects a taken key without shifting anything', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(list.insert(0, const User(2, 'dup')), isFalse);
      expect(list.items.map((u) => u.id), [1, 2]);
      expectInvariants(list);
    });

    test('rejects an out-of-range index', () {
      final list = userList([const User(1, 'a')]);
      expect(() => list.insert(5, const User(2, 'b')), throwsRangeError);
      expectInvariants(list);
    });

    test('insertAll skips taken keys and de-duplicates its own input', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      final inserted = list.insertAll(1, [
        const User(3, 'c'),
        const User(1, 'dup'),
        const User(3, 'self dup'),
        const User(4, 'd'),
      ]);
      expect(inserted, 2);
      expect(list.items.map((u) => u.id), [1, 3, 4, 2]);
      expectInvariants(list);
    });
  });

  group('addOrReplace', () {
    test('adds when the key is absent', () {
      final list = userList();
      expect(list.addOrReplace(const User(1, 'a')), isTrue);
      expectInvariants(list);
    });

    test('replaces in place, keeping the position', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);
      expect(list.addOrReplace(const User(2, 'updated')), isTrue);
      expect(list.items, [
        const User(1, 'a'),
        const User(2, 'updated'),
        const User(3, 'c'),
      ]);
      expectInvariants(list);
    });

    test('is a no-op for an equal element', () {
      final list = userList([const User(1, 'a')]);
      expect(list.addOrReplace(const User(1, 'a')), isFalse);
      expectInvariants(list);
    });

    test('addAllOrReplace reports adds and updates separately', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      final result = list.addAllOrReplace([
        const User(1, 'a'), // equal, ignored
        const User(2, 'changed'), // updated
        const User(3, 'c'), // added
      ]);
      expect(result.added, 1);
      expect(result.updated, 1);
      expectInvariants(list);
    });
  });

  group('putIfAbsent', () {
    test('returns the stored element without calling ifAbsent', () {
      final list = userList([const User(1, 'a')]);
      var called = false;
      final result = list.putIfAbsent(1, () {
        called = true;
        return const User(1, 'fresh');
      });
      expect(result, const User(1, 'a'));
      expect(called, isFalse);
      expectInvariants(list);
    });

    test('inserts and returns the produced element', () {
      final list = userList();
      expect(list.putIfAbsent(1, () => const User(1, 'a')), const User(1, 'a'));
      expectInvariants(list);
    });

    test('rejects an element whose key is not the requested one', () {
      final list = userList();
      expect(
        () => list.putIfAbsent(1, () => const User(2, 'wrong')),
        throwsArgumentError,
      );
      expectInvariants(list);
    });
  });

  group('replace', () {
    test('replaceOne swaps the element sharing the key', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(list.replaceOne(const User(2, 'updated')), isTrue);
      expect(list[1], const User(2, 'updated'));
      expectInvariants(list);
    });

    test('replaceOne returns false for an absent key or an equal element', () {
      final list = userList([const User(1, 'a')]);
      expect(list.replaceOne(const User(9, 'absent')), isFalse);
      expect(list.replaceOne(const User(1, 'a')), isFalse);
      expectInvariants(list);
    });

    // Regression: before 2.0.0 this silently produced two elements sharing a
    // key, permanently corrupting the collection.
    test('replaceOneWhere refuses to introduce a duplicate key', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);

      final replaced = list.replaceOneWhere(
        const User(2, 'collides'),
        (u) => u.id == 1,
      );

      expect(replaced, isFalse, reason: 'the key 2 is already taken');
      expect(list.items, [const User(1, 'a'), const User(2, 'b')]);
      expectInvariants(list);
    });

    test('replaceOneWhere may change the key when it is free', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(
          list.replaceOneWhere(const User(9, 'z'), (u) => u.id == 1), isTrue);
      expect(list.items, [const User(9, 'z'), const User(2, 'b')]);
      expect(list.containsKey(1), isFalse);
      expect(list.indexOfKey(9), 0);
      expectInvariants(list);
    });

    test('replaceOneWhere allows replacing an element with its own key', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(
          list.replaceOneWhere(const User(1, 'a2'), (u) => u.id == 1), isTrue);
      expect(list[0], const User(1, 'a2'));
      expectInvariants(list);
    });

    test('replaceOneWhere returns false when nothing matches', () {
      final list = userList([const User(1, 'a')]);
      expect(
          list.replaceOneWhere(const User(5, 'e'), (u) => u.id == 99), false);
      expectInvariants(list);
    });

    test('update rewrites the element under a key', () {
      final list = userList([const User(1, 'a')]);
      expect(list.update(1, (u) => User(u.id, u.name.toUpperCase())), isTrue);
      expect(list[0], const User(1, 'A'));
      expect(list.update(9, (u) => u), isFalse);
      expectInvariants(list);
    });

    test('update rejects a change of key', () {
      final list = userList([const User(1, 'a')]);
      expect(
        () => list.update(1, (u) => const User(2, 'moved')),
        throwsArgumentError,
      );
      expectInvariants(list);
    });

    test('operator []= rejects a key owned by another element', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(() => list[0] = const User(2, 'collides'), throwsArgumentError);
      expect(list[0] = const User(7, 'g'), const User(7, 'g'));
      expect(list.indexOfKey(7), 0);
      expectInvariants(list);
    });
  });

  group('remove', () {
    test('remove matches by key, not by equality', () {
      final list = userList([const User(1, 'a')]);
      // A different name, so `==` would say no; the key says yes.
      expect(list.remove(const User(1, 'totally different')), isTrue);
      expect(list, isEmpty);
      expectInvariants(list);
    });

    test('removeKey returns the element it removed', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(list.removeKey(1), const User(1, 'a'));
      expect(list.removeKey(1), isNull);
      expect(list.indexOfKey(2), 0, reason: 'indices must shift down');
      expectInvariants(list);
    });

    test('removeAt and removeLast', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);
      expect(list.removeAt(0), const User(1, 'a'));
      expect(list.removeLast(), const User(3, 'c'));
      expect(list.items, [const User(2, 'b')]);
      expectInvariants(list);
      expect(() => list.removeAt(9), throwsRangeError);
      list.clear();
      expect(list.removeLast, throwsStateError);
    });

    test('removeAll and removeKeys', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);
      expect(list.removeAll([const User(1, 'x'), const User(9, 'absent')]), 1);
      expectInvariants(list);
      expect(list.removeKeys([2, 3, 4]), 2);
      expect(list, isEmpty);
      expectInvariants(list);
    });

    test('removeOneWhere removes only the first match', () {
      final list = userList([
        const User(1, 'keep'),
        const User(2, 'drop'),
        const User(3, 'drop'),
      ]);
      expect(list.removeOneWhere((u) => u.name == 'drop'), isTrue);
      expect(list.items.map((u) => u.id), [1, 3]);
      expect(list.removeOneWhere((u) => u.name == 'missing'), isFalse);
      expectInvariants(list);
    });

    test('removeWhere returns the count and keeps the index in sync', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
        const User(4, 'd'),
      ]);
      expect(list.removeWhere((u) => u.id.isEven), 2);
      expect(list.items.map((u) => u.id), [1, 3]);
      expect(list.containsKey(2), isFalse);
      expectInvariants(list);
    });

    test('retainWhere and retainKeys', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);
      expect(list.retainWhere((u) => u.id != 2), 1);
      expectInvariants(list);
      expect(list.retainKeys([3]), 1);
      expect(list.items, [const User(3, 'c')]);
      expectInvariants(list);
    });

    test('clear empties the collection and frees the keys', () {
      final list = userList([const User(1, 'a')]);
      list.clear();
      expect(list, isEmpty);
      expect(list.containsKey(1), isFalse);
      expect(list.add(const User(1, 'reused')), isTrue);
      expectInvariants(list);
    });
  });

  group('syncWith', () {
    test('adds, updates and removes to mirror the source', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);

      final result = list.syncWith([
        const User(1, 'a'), // unchanged
        const User(3, 'c changed'), // updated
        const User(4, 'd'), // added
      ]); // 2 is absent -> removed

      expect(result, (added: 1, updated: 1, removed: 1));
      expect(list.items, [
        const User(1, 'a'),
        const User(3, 'c changed'),
        const User(4, 'd'),
      ]);
      expectInvariants(list);
    });

    test('preserveOrder keeps survivors in place and appends newcomers', () {
      final list = userList([const User(3, 'c'), const User(1, 'a')]);
      list.syncWith(
          [const User(1, 'a'), const User(2, 'b'), const User(3, 'c')]);
      expect(list.items.map((u) => u.id), [3, 1, 2]);
      expectInvariants(list);
    });

    test('preserveOrder: false adopts the order of the source', () {
      final list = userList([const User(3, 'c'), const User(1, 'a')]);
      list.syncWith(
        [const User(1, 'a'), const User(2, 'b'), const User(3, 'c')],
        preserveOrder: false,
      );
      expect(list.items.map((u) => u.id), [1, 2, 3]);
      expectInvariants(list);
    });

    test('the last element wins when the source repeats a key', () {
      final list = userList();
      list.syncWith([const User(1, 'first'), const User(1, 'last')]);
      expect(list.items, [const User(1, 'last')]);
      expectInvariants(list);
    });

    test('an empty source empties the collection', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(list.syncWith([]), (added: 0, updated: 0, removed: 2));
      expect(list, isEmpty);
      expectInvariants(list);
    });
  });

  group('ordering', () {
    test('sort is stable', () {
      // Same sort key, distinct identities: a stable sort keeps 1,2,3.
      final list = userList([
        const User(1, 'same'),
        const User(2, 'same'),
        const User(3, 'same'),
      ]);
      list.sort((a, b) => a.name.compareTo(b.name));
      expect(list.items.map((u) => u.id), [1, 2, 3]);
      expectInvariants(list);
    });

    test('sort reorders and reindexes', () {
      final list = userList([
        const User(3, 'c'),
        const User(1, 'a'),
        const User(2, 'b'),
      ]);
      list.sort((a, b) => a.id.compareTo(b.id));
      expect(list.items.map((u) => u.id), [1, 2, 3]);
      expectInvariants(list);
    });

    test('sort with no comparator uses Comparable', () {
      final numbers = XUniqueList<int, int>.from([3, 1, 2], (n) => n)..sort();
      expect(numbers.items, [1, 2, 3]);
      expectInvariants(numbers);
    });

    test('reorder moves an element', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);
      list.reorder(0, 2);
      expect(list.items.map((u) => u.id), [2, 3, 1]);
      expectInvariants(list);
      list.reorder(2, 0);
      expect(list.items.map((u) => u.id), [1, 2, 3]);
      expectInvariants(list);
    });

    test('swap exchanges two positions', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'c'),
      ]);
      list.swap(0, 2);
      expect(list.items.map((u) => u.id), [3, 2, 1]);
      expectInvariants(list);
    });

    test('shuffle keeps every element and the index consistent', () {
      final list = userList([
        for (var i = 0; i < 30; i++) User(i, 'user $i'),
      ])
        ..shuffle();
      expect(list.length, 30);
      expect(list.keys.toSet(), {for (var i = 0; i < 30; i++) i});
      expectInvariants(list);
    });
  });

  group('set algebra', () {
    final a = [const User(1, 'a'), const User(2, 'b')];
    final b = [const User(2, 'b2'), const User(3, 'c')];

    test('union keeps the receiver on conflict', () {
      final result = userList(a).union(b);
      expect(result.items, [const User(1, 'a'), const User(2, 'b'), b.last]);
      expectInvariants(result);
    });

    test('operator + is union', () {
      expect((userList(a) + b).items, userList(a).union(b).items);
    });

    test('intersection and difference', () {
      expect(userList(a).intersection(b).items, [const User(2, 'b')]);
      expect(userList(a).difference(b).items, [const User(1, 'a')]);
    });
  });

  group('Iterable conformance', () {
    test('iterates, maps and spreads directly', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);

      expect([for (final u in list) u.id], [1, 2]);
      expect(list.map((u) => u.name).toList(), ['a', 'b']);
      expect([...list], list.items);
      expect(list.any((u) => u.id == 2), isTrue);
      expect(list.every((u) => u.id > 0), isTrue);
      expect(list.fold<int>(0, (sum, u) => sum + u.id), 3);
      expect(list.where((u) => u.id.isOdd).single, const User(1, 'a'));
      expect(list.first, const User(1, 'a'));
      expect(list.last, const User(2, 'b'));
      expect(list.reversed.first, const User(2, 'b'));
      expect(list.sublist(1), [const User(2, 'b')]);
    });

    test('contains compares by key, not by ==', () {
      final list = userList([const User(1, 'a')]);
      expect(list.contains(const User(1, 'a different name')), isTrue);
      expect(list.contains(const User(9, 'a')), isFalse);
      // ignore: collection_methods_unrelated_type
      expect(list.contains('not a user'), isFalse);
    });

    test('firstWhere throws like Iterable, firstWhereOrNull does not', () {
      final list = userList([const User(1, 'a')]);
      expect(() => list.firstWhere((u) => u.id == 9), throwsStateError);
      expect(list.firstWhereOrNull((u) => u.id == 9), isNull);
      expect(list.firstWhereOrNull((u) => u.id == 1), const User(1, 'a'));
      expect(list.lastWhereOrNull((u) => u.id == 1), const User(1, 'a'));
      expect(list.lastWhereOrNull((u) => u.id == 9), isNull);
    });

    test('indexWhere and indexOf honour start', () {
      final list = userList([
        const User(1, 'a'),
        const User(2, 'b'),
        const User(3, 'a'),
      ]);
      expect(list.indexWhere((u) => u.name == 'a'), 0);
      expect(list.indexWhere((u) => u.name == 'a', 1), 2);
      expect(list.indexOf(const User(1, 'a')), 0);
      expect(list.indexOf(const User(1, 'a'), 1), -1);
      expect(list.indexOf(const User(9, 'absent')), -1);
      expect(list.indexOfKey(9), -1);
      expect(() => list.indexOf(const User(1, 'a'), -1), throwsRangeError);
    });
  });

  group('views', () {
    test('items cannot be modified', () {
      final list = userList([const User(1, 'a')]);
      expect(
        () => list.items.add(const User(1, 'smuggled')),
        throwsUnsupportedError,
      );
      expect(() => list.keys.toList().first, returnsNormally);
    });

    test('items is a live view, toList is a snapshot', () {
      final list = userList([const User(1, 'a')]);
      final view = list.items;
      final snapshot = list.toList();

      list.add(const User(2, 'b'));

      expect(view, hasLength(2), reason: 'items is a view');
      expect(snapshot, hasLength(1), reason: 'toList is a copy');
    });

    test('the view still tracks the collection after clear', () {
      final list = userList([const User(1, 'a')]);
      final view = list.items;
      list.clear();
      expect(view, isEmpty, reason: 'clear must not detach existing views');
    });

    test('toMap maps key to element', () {
      final list = userList([const User(1, 'a'), const User(2, 'b')]);
      expect(list.toMap(), {1: const User(1, 'a'), 2: const User(2, 'b')});
    });
  });

  group('value semantics', () {
    test('equality is element-wise and order-sensitive', () {
      final a = userList([const User(1, 'a'), const User(2, 'b')]);
      final b = userList([const User(1, 'a'), const User(2, 'b')]);
      final c = userList([const User(2, 'b'), const User(1, 'a')]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(userList([const User(1, 'a')])));
    });

    test('toString shows the elements', () {
      expect(
        userList([const User(1, 'a')]).toString(),
        'XUniqueList<User, int>[User(1, a)]',
      );
    });
  });

  group('batch', () {
    test('returns the value of the action and supports nesting', () {
      final list = userList();
      final result = list.batch(() {
        list.add(const User(1, 'a'));
        return list.batch(() => list.addAll([const User(2, 'b')]));
      });
      expect(result, 1);
      expect(list.length, 2);
      expectInvariants(list);
    });

    test('a throwing action still closes the batch', () {
      final list = userList();
      expect(
          () => list.batch(() => throw StateError('boom')), throwsStateError);
      expect(list.add(const User(1, 'a')), isTrue);
      expectInvariants(list);
    });
  });

  group('keys of other types', () {
    test('records make good composite keys', () {
      final list = XUniqueList<User, (int, String)>((u) => (u.id, u.name));
      expect(list.add(const User(1, 'a')), isTrue);
      expect(list.add(const User(1, 'b')), isTrue, reason: 'name differs');
      expect(list.add(const User(1, 'a')), isFalse);
      expect(list.lookup((1, 'b')), const User(1, 'b'));
      expectInvariants(list);
    });

    test('string keys', () {
      final list = XUniqueList<User, String>((u) => u.name.toLowerCase());
      list.addAll([const User(1, 'Ahmad'), const User(2, 'AHMAD')]);
      expect(list.length, 1);
      expectInvariants(list);
    });
  });
}
