import 'x_unique_list.dart';

/// An [XUniqueList] that notifies listeners whenever its contents change.
///
/// This is deliberately pure Dart — the package depends on no SDK other than
/// Dart itself. The API mirrors Flutter's `ChangeNotifier`, so bridging to
/// `ListenableBuilder`, `Provider` and friends takes a few lines:
///
/// ```dart
/// class UserStore extends ChangeNotifier {
///   final users = XObservableUniqueList<User, int>((u) => u.id);
///   UserStore() {
///     users.addListener(notifyListeners);
///   }
///   @override
///   void dispose() {
///     users.removeListener(notifyListeners);
///     users.dispose();
///     super.dispose();
///   }
/// }
/// ```
///
/// Bulk operations notify once rather than once per element, and [batch] lets
/// you extend that to a group of individual calls:
///
/// ```dart
/// users.batch(() {
///   users.add(a);
///   users.removeKey(7);
///   users.sort((a, b) => a.name.compareTo(b.name));
/// }); // one notification
/// ```
class XObservableUniqueList<T, K extends Object> extends XUniqueList<T, K> {
  final List<void Function()> _listeners = [];
  bool _disposed = false;

  /// Creates an empty observable collection keyed by [key].
  XObservableUniqueList(super.key);

  /// Creates an observable collection keyed by [key] holding those of
  /// [elements] whose keys are distinct; for each repeated key the first
  /// element wins.
  factory XObservableUniqueList.from(
    Iterable<T> elements,
    K Function(T element) key,
  ) =>
      XObservableUniqueList<T, K>(key)..addAll(elements);

  /// Whether [dispose] has been called.
  bool get isDisposed => _disposed;

  /// Whether at least one listener is registered.
  bool get hasListeners => _listeners.isNotEmpty;

  /// Registers [listener], to be called after every change.
  ///
  /// Registering the same closure twice causes it to be called twice.
  void addListener(void Function() listener) {
    _debugAssertNotDisposed();
    _listeners.add(listener);
  }

  /// Removes one registration of [listener].
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Discards every listener.
  ///
  /// The collection must not be used afterwards.
  void dispose() {
    _debugAssertNotDisposed();
    _listeners.clear();
    _disposed = true;
  }

  @override
  void onMutated() {
    if (_disposed || _listeners.isEmpty) return;
    // Iterate a copy so a listener may add or remove listeners safely.
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }

  void _debugAssertNotDisposed() {
    assert(
      !_disposed,
      'A $runtimeType was used after being disposed. '
      'Once dispose() is called it can no longer be used.',
    );
  }

  @override
  XObservableUniqueList<T, K> copy() =>
      XObservableUniqueList<T, K>.from(items, keyOf);
}
