import 'dart:math';

extension ListExtension<T> on List<T> {
  List<T> get shuffled => [...this]..shuffle();

  T randomSingle() {
    final random = Random();
    final index = random.nextInt(length);
    return this[index];
  }
}
