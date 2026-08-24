import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../domain/umrah_guide_model.dart';

class UmrahGuideNotifier extends StateNotifier<List<UmrahGuideModel>> {
  UmrahGuideNotifier()
      : super(const [
          UmrahGuideModel(
            id: 'g1',
            stepNumber: 1,
            title: 'Niat Ihram di Miqat',
            arabicText: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً',
            transliteration: 'Labbaikallahumma \'Umratan',
            translation: 'Aku penuhi panggilan-Mu Ya Allah untuk menunaikan ibadah Umrah.',
            explanation: 'Mandi sunnah ihram, mengenakan pakaian ihram serba putih tanpa jahitan (bagi pria), dan mengucap niat saat melintasi batas Miqat.',
            icon: LucideIcons.userCheck,
            isCompleted: true,
          ),
          UmrahGuideModel(
            id: 'g2',
            stepNumber: 2,
            title: 'Thawaf 7 Putaran mengelilingi Ka\'bah',
            arabicText: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
            transliteration: 'Subhanallah walhamdulillah wa laa ilaha illallah wallahu akbar',
            translation: 'Maha Suci Allah, segala puji bagi Allah, tiada Tuhan selain Allah, dan Allah Maha Besar.',
            explanation: 'Mengelilingi Ka\'bah sebanyak 7 putaran berlawanan arah jarum jam diawali dari Hajar Aswad dan berakhir di Hajar Aswad.',
            icon: LucideIcons.compass,
            isCompleted: true,
          ),
          UmrahGuideModel(
            id: 'g3',
            stepNumber: 3,
            title: 'Shalat Sunnah 2 Rakaat di Maqam Ibrahim',
            arabicText: 'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى',
            transliteration: 'Wattakhidzuu mim maqaami Ibraahiima mushalla',
            translation: 'Dan jadikanlah sebagian Maqam Ibrahim sebagai tempat shalat.',
            explanation: 'Melakukan shalat sunnah Thawaf 2 rakaat di belakang Maqam Ibrahim jika memungkinkan, atau di mana pun di area Masjidil Haram.',
            icon: LucideIcons.bookOpen,
            isCompleted: false,
          ),
          UmrahGuideModel(
            id: 'g4',
            stepNumber: 4,
            title: 'Sa\'i 7 Kali Antara Bukit Shafa & Marwah',
            arabicText: 'إِنَّ الصَّفَا وَالْمَروَةَ مِنْ شَعَائِرِ اللَّهِ',
            transliteration: 'Innash Shafaa wal Marwata min sya\'aa\'irillah',
            translation: 'Sesungguhnya Shafa dan Marwah adalah sebagian dari syiar Allah.',
            explanation: 'Berjalan dan berlari-lari kecil 7 kali dari Bukit Shafa ke Bukit Marwah dan berakhir di Bukit Marwah.',
            icon: LucideIcons.arrowRightCircle,
            isCompleted: false,
          ),
          UmrahGuideModel(
            id: 'g5',
            stepNumber: 5,
            title: 'Tahallul (Mencukur / Memotong Rambut)',
            arabicText: 'مُحَلِّقِينَ رُءُوسَكُمْ وَمُقَصِّرِينَ',
            transliteration: 'Muhalliqiina ru\'uusakum wa muqashshiriina',
            translation: 'Dengan mencukur gundul kepalamu dan memendekkannya.',
            explanation: 'Memotong sedikitnya 3 helai rambut atau mencukur gundul (bagi pria) sebagai tanda berakhirnya larangan ihram.',
            icon: LucideIcons.checkCircle2,
            isCompleted: false,
          ),
        ]);

  void toggleStepCompletion(String id) {
    state = state.map((step) {
      if (step.id == id) {
        return step.copyWith(isCompleted: !step.isCompleted);
      }
      return step;
    }).toList();
  }
}

final umrahGuideProvider =
    StateNotifierProvider<UmrahGuideNotifier, List<UmrahGuideModel>>((ref) {
  return UmrahGuideNotifier();
});
