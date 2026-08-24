import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tasbih_model.dart';

class TasbihNotifier extends StateNotifier<TasbihModel> {
  TasbihNotifier() : super(const TasbihModel());

  void increment() {
    state = state.copyWith(counter: state.counter + 1);
  }

  void decrement() {
    if (state.counter > 0) {
      state = state.copyWith(counter: state.counter - 1);
    }
  }

  void reset() {
    state = state.copyWith(counter: 0);
  }

  void setSelectedDzikir(String dzikir) {
    state = state.copyWith(selectedDzikir: dzikir, counter: 0);
  }

  void setTarget(int newTarget) {
    state = state.copyWith(target: newTarget, counter: 0);
  }
}

final tasbihProvider =
    StateNotifierProvider<TasbihNotifier, TasbihModel>((ref) {
  return TasbihNotifier();
});
