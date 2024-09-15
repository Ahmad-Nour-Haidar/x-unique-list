import 'package:x_unique_list/x_unique_list.dart';
import 'package:test/test.dart';

void main() {
  group('UniqueList Tests', () {
    late XUniqueList<int> xUniqueList;

    setUp(() {
      // Initialize before each test
      xUniqueList = XUniqueList<int>(
          (item) => item); // uniqueCondition: item itself is unique
    });

    test('add() adds a new item to the list', () {
      final added = xUniqueList.add(1);
      expect(added, isTrue);
      expect(xUniqueList.items, contains(1));
    });

    test('add() does not add duplicate items', () {
      xUniqueList.add(1);
      final added = xUniqueList.add(1); // Attempt to add duplicate
      expect(added, isFalse);
      expect(xUniqueList.items.length, 1); // Ensure list still has only 1 item
    });

    test('addAll() adds multiple items', () {
      final count = xUniqueList.addAll([1, 2, 3]);
      expect(count, 3);
      expect(xUniqueList.items.length, 3);
    });

    test('insert() inserts item at specific index', () {
      xUniqueList.add(1);
      final inserted = xUniqueList.insert(0, 2);
      expect(inserted, isTrue);
      expect(xUniqueList.items[0], 2);
    });

    test('remove() removes an item', () {
      xUniqueList.add(1);
      final removed = xUniqueList.remove(1);
      expect(removed, isTrue);
      expect(xUniqueList.items, isEmpty);
    });

    test('removeOneWhere() removes the first item that matches a condition',
        () {
      xUniqueList.addAll([1, 2, 3]);
      final removed = xUniqueList.removeOneWhere((item) => item == 2);
      expect(removed, isTrue);
      expect(xUniqueList.items, isNot(contains(2)));
    });

    test('contains() returns true if the item exists', () {
      xUniqueList.add(1);
      expect(xUniqueList.contains(1), isTrue);
    });

    test('replaceOneWhere() replaces an item based on a condition', () {
      xUniqueList.addAll([1, 2, 3]);
      final replaced = xUniqueList.replaceOneWhere(4, (item) => item == 2);
      expect(replaced, isTrue);
      expect(xUniqueList.items, contains(4));
      expect(xUniqueList.items, isNot(contains(2)));
    });

    test('clear() clears all items', () {
      xUniqueList.addAll([1, 2, 3]);
      xUniqueList.clear();
      expect(xUniqueList.items, isEmpty);
    });
  });
}
