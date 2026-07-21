import 'package:test/test.dart';
import 'package:x_unique_list/x_unique_list.dart';

import 'test_utils.dart';

void main() {
  late XObservableUniqueList<User, int> list;
  late int notifications;

  void listener() => notifications++;

  setUp(() {
    notifications = 0;
    list = XObservableUniqueList<User, int>((u) => u.id)..addListener(listener);
  });

  test('notifies once per effective mutation', () {
    list.add(const User(1, 'a'));
    expect(notifications, 1);

    list.addOrReplace(const User(1, 'updated'));
    expect(notifications, 2);

    list.removeKey(1);
    expect(notifications, 3);
    expectInvariants(list);
  });

  test('does not notify when nothing changed', () {
    list.add(const User(1, 'a'));
    notifications = 0;

    expect(list.add(const User(1, 'duplicate')), isFalse);
    expect(list.addOrReplace(const User(1, 'a')), isFalse);
    expect(list.replaceOne(const User(1, 'a')), isFalse);
    expect(list.remove(const User(9, 'absent')), isFalse);
    expect(list.removeWhere((u) => u.id == 99), 0);
    expect(
        list.replaceOneWhere(const User(2, 'x'), (u) => u.id == 99), isFalse);
    list.clear();
    list.clear(); // already empty

    expect(notifications, 1, reason: 'only the first clear did anything');
  });

  test('bulk operations notify once, not once per element', () {
    list.addAll([const User(1, 'a'), const User(2, 'b'), const User(3, 'c')]);
    expect(notifications, 1);

    notifications = 0;
    list.addAllOrReplace([const User(1, 'a2'), const User(4, 'd')]);
    expect(notifications, 1);

    notifications = 0;
    list.syncWith([const User(1, 'a2'), const User(9, 'i')]);
    expect(notifications, 1);
    expectInvariants(list);
  });

  test('batch coalesces a group of calls into one notification', () {
    list.batch(() {
      list.add(const User(1, 'a'));
      list.add(const User(2, 'b'));
      list.removeKey(1);
      list.sort((a, b) => a.id.compareTo(b.id));
    });
    expect(notifications, 1);
    expectInvariants(list);
  });

  test('an empty batch notifies nothing', () {
    list.batch(() {});
    expect(notifications, 0);
  });

  test('listeners can be removed, and duplicates are counted separately', () {
    list.addListener(listener);
    list.add(const User(1, 'a'));
    expect(notifications, 2);

    list.removeListener(listener);
    list.add(const User(2, 'b'));
    expect(notifications, 3);
  });

  test('a listener may remove itself while being notified', () {
    late void Function() once;
    var calls = 0;
    once = () {
      calls++;
      list.removeListener(once);
    };
    list.addListener(once);

    list.add(const User(1, 'a'));
    list.add(const User(2, 'b'));

    expect(calls, 1);
  });

  test('dispose drops the listeners and stops notifications', () {
    list.dispose();
    expect(list.isDisposed, isTrue);
    expect(list.hasListeners, isFalse);
  });

  test('hasListeners reflects registrations', () {
    expect(list.hasListeners, isTrue);
    list.removeListener(listener);
    expect(list.hasListeners, isFalse);
  });

  test('copy() produces an observable without the original listeners', () {
    list.add(const User(1, 'a'));
    final duplicate = list.copy();

    expect(duplicate, isA<XObservableUniqueList<User, int>>());
    expect(duplicate.hasListeners, isFalse);
    expect(duplicate.items, list.items);

    notifications = 0;
    duplicate.add(const User(2, 'b'));
    expect(notifications, 0, reason: 'the copy is independent');
    expectInvariants(duplicate);
  });
}
