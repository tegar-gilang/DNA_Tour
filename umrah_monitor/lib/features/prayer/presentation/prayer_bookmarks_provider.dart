import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/prayer_model.dart';

class PrayerBookmarksNotifier extends StateNotifier<Set<String>> {
  PrayerBookmarksNotifier()
      : super(
          PrayerModel.masterCollection
              .where((p) => p.isBookmarked)
              .map((p) => p.id)
              .toSet(),
        );

  void toggleBookmark(String prayerId) {
    if (state.contains(prayerId)) {
      state = Set.from(state)..remove(prayerId);
    } else {
      state = Set.from(state)..add(prayerId);
    }
  }

  bool isBookmarked(String prayerId) {
    return state.contains(prayerId);
  }
}

final prayerBookmarksProvider = StateNotifierProvider<PrayerBookmarksNotifier, Set<String>>((ref) {
  return PrayerBookmarksNotifier();
});
