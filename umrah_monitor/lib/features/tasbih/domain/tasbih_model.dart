class TasbihModel {
  final int counter;
  final int target;
  final String selectedDzikir;
  final List<String> dzikirList;
  final List<int> targetOptions;

  const TasbihModel({
    this.counter = 0,
    this.target = 33,
    this.selectedDzikir = 'Subhanallah (سُبْحَانَ ٱللَّٰهِ)',
    this.dzikirList = const [
      'Subhanallah (سُبْحَانَ ٱللَّٰهِ)',
      'Alhamdulillah (ٱلْحَمْدُ لِلَّٰهِ)',
      'Allahu Akbar (ٱللَّٰهُ أَكْبَرُ)',
      'Laa Ilaaha Illallah (لَا إِلَٰهَ إِلَّا ٱللَّٰهُ)',
      'Astaghfirullah (أَسْتَغْفِرُ ٱللَّٰهَ)',
      'Shalawat Nabi (اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ)',
      'Custom / Bebas',
    ],
    this.targetOptions = const [33, 99, 100, 500, 1000],
  });

  TasbihModel copyWith({
    int? counter,
    int? target,
    String? selectedDzikir,
    List<String>? dzikirList,
    List<int>? targetOptions,
  }) {
    return TasbihModel(
      counter: counter ?? this.counter,
      target: target ?? this.target,
      selectedDzikir: selectedDzikir ?? this.selectedDzikir,
      dzikirList: dzikirList ?? this.dzikirList,
      targetOptions: targetOptions ?? this.targetOptions,
    );
  }

  double get progress => target > 0 ? (counter / target).clamp(0.0, 1.0) : 0.0;
  bool get isTargetReached => counter >= target;
}
