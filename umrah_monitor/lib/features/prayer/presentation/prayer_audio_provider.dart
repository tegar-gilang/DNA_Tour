import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/prayer_model.dart';

class PrayerAudioState {
  final String? activePrayerId;
  final String? activePrayerTitle;
  final bool isPlaying;
  final bool isMutawifBroadcasting;
  final double progress;
  final String durationText;
  final String positionText;

  const PrayerAudioState({
    this.activePrayerId,
    this.activePrayerTitle,
    this.isPlaying = false,
    this.isMutawifBroadcasting = false,
    this.progress = 0.35,
    this.durationText = '03:30',
    this.positionText = '01:14',
  });

  PrayerAudioState copyWith({
    String? activePrayerId,
    String? activePrayerTitle,
    bool? isPlaying,
    bool? isMutawifBroadcasting,
    double? progress,
    String? durationText,
    String? positionText,
    bool clearActive = false,
  }) {
    return PrayerAudioState(
      activePrayerId: clearActive ? null : (activePrayerId ?? this.activePrayerId),
      activePrayerTitle: clearActive ? null : (activePrayerTitle ?? this.activePrayerTitle),
      isPlaying: isPlaying ?? this.isPlaying,
      isMutawifBroadcasting: isMutawifBroadcasting ?? this.isMutawifBroadcasting,
      progress: progress ?? this.progress,
      durationText: durationText ?? this.durationText,
      positionText: positionText ?? this.positionText,
    );
  }
}

class PrayerAudioNotifier extends StateNotifier<PrayerAudioState> {
  PrayerAudioNotifier() : super(const PrayerAudioState());

  void playPrayer(PrayerModel prayer, {bool isBroadcasting = false}) {
    if (state.activePrayerId == prayer.id) {
      state = state.copyWith(
        isPlaying: !state.isPlaying,
        isMutawifBroadcasting: isBroadcasting ? true : state.isMutawifBroadcasting,
      );
    } else {
      state = PrayerAudioState(
        activePrayerId: prayer.id,
        activePrayerTitle: prayer.title,
        isPlaying: true,
        isMutawifBroadcasting: isBroadcasting,
        progress: 0.35,
        positionText: '01:14',
        durationText: '03:30',
      );
    }
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void stop() {
    state = const PrayerAudioState();
  }
}

final prayerAudioProvider = StateNotifierProvider<PrayerAudioNotifier, PrayerAudioState>((ref) {
  return PrayerAudioNotifier();
});
