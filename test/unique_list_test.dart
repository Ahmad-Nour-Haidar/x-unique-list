import 'package:flutter_test/flutter_test.dart';
import 'package:unique_list/src/unique_list_impl.dart';

void main() {
  group('UniqueList Tests', () {
    late UniqueList<int> uniqueList;

    setUp(() {
      // Initialize before each test
      uniqueList = UniqueList<int>(
          (item) => item); // uniqueCondition: item itself is unique
    });

    test('add() adds a new item to the list', () {
      final added = uniqueList.add(1);
      expect(added, isTrue);
      expect(uniqueList.items, contains(1));
    });

    test('add() does not add duplicate items', () {
      uniqueList.add(1);
      final added = uniqueList.add(1); // Attempt to add duplicate
      expect(added, isFalse);
      expect(uniqueList.items.length, 1); // Ensure list still has only 1 item
    });

    test('addAll() adds multiple items', () {
      final count = uniqueList.addAll([1, 2, 3]);
      expect(count, 3);
      expect(uniqueList.items.length, 3);
    });

    test('insert() inserts item at specific index', () {
      uniqueList.add(1);
      final inserted = uniqueList.insert(0, 2);
      expect(inserted, isTrue);
      expect(uniqueList.items[0], 2);
    });

    test('remove() removes an item', () {
      uniqueList.add(1);
      final removed = uniqueList.remove(1);
      expect(removed, isTrue);
      expect(uniqueList.items, isEmpty);
    });

    test('removeOneWhere() removes the first item that matches a condition',
        () {
      uniqueList.addAll([1, 2, 3]);
      final removed = uniqueList.removeOneWhere((item) => item == 2);
      expect(removed, isTrue);
      expect(uniqueList.items, isNot(contains(2)));
    });

    test('contains() returns true if the item exists', () {
      uniqueList.add(1);
      expect(uniqueList.contains(1), isTrue);
    });

    test('replaceOneWhere() replaces an item based on a condition', () {
      uniqueList.addAll([1, 2, 3]);
      final replaced = uniqueList.replaceOneWhere(4, (item) => item == 2);
      expect(replaced, isTrue);
      expect(uniqueList.items, contains(4));
      expect(uniqueList.items, isNot(contains(2)));
    });

    test('clear() clears all items', () {
      uniqueList.addAll([1, 2, 3]);
      uniqueList.clear();
      expect(uniqueList.items, isEmpty);
    });
  });
}
