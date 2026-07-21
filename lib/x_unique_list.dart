/// An ordered collection in which no two elements share the same key, where
/// the key is derived by a function you supply rather than by `==`.
///
/// ```dart
/// import 'package:x_unique_list/x_unique_list.dart';
///
/// final users = XUniqueList<User, int>((u) => u.id);
///
/// users.add(User(1, 'Ahmad'));       // true
/// users.add(User(1, 'Impostor'));    // false — id 1 is taken
/// users.addOrReplace(User(1, 'Ahmad Nour')); // true — replaced in place
///
/// users.lookup(1);        // O(1)
/// users.containsKey(1);   // O(1)
/// users.removeKey(1);     // O(n), but located in O(1)
/// ```
///
/// See [XUniqueList] for the main type, [XObservableUniqueList] for a variant
/// that notifies listeners on change, and [XUniqueListBase] for the interface
/// to depend on when faking the collection in tests.
library;

export 'src/x_observable_unique_list.dart';
export 'src/x_unique_list.dart';
export 'src/x_unique_list_base.dart';
