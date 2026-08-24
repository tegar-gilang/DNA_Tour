import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';

class GuideSectionModel {
  final String id;
  final String stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String content;
  final List<String> checklist;

  const GuideSectionModel({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.content,
    required this.checklist,
  });
}

class UmrahGuideScreen extends StatefulWidget {
  const UmrahGuideScreen({super.key});

  @override
  State<UmrahGuideScreen> createState() => _UmrahGuideScreenState();
}

class _UmrahGuideScreenState extends State<UmrahGuideScreen> {
  final Set<String> _checkedItems = {};

  final List<GuideSectionModel> _sections = const [
    GuideSectionModel(
      id: 'step_1',
      stepNumber: 'Tahap 1',
      title: 'Persiapan Sebelum Berangkat (Di Hotel / Tanah Air)',
      subtitle: 'Kesunahan kebersihan fisik, pakaian Ihram, dan sholat sunnah safar.',
      icon: LucideIcons.sparkles,
      iconColor: AppColors.primary,
      content: 'Sebelum menuju batas Miqat atau meninggalkan penginapan, jamaah disunnahkan membersihkan diri secara sempurna. Amalan sunnah sebelum niat Ihram meliputi memotong kuku, merapikan kumis, mencukur bulu ketiak & kemaluan, mandi sunnah Ihram dengan niat membersihkan diri untuk ibadah, serta memakai wangi-wangian di tubuh (bukan pada kain Ihram bagi laki-laki). Setelah mandi, kenakan pakaian Ihram yang bersih.',
      checklist: [
        'Memotong kuku tangan dan kaki serta merapikan kumis/jenggot',
        'Mandi sunnah Ihram dengan niat membersihkan diri untuk ibadah',
        'Memakai wangi-wangian di tubuh (khusus sebelum niat Ihram diucapkan)',
        'Mengenakan 2 helai kain Ihram putih tanpa jahitan (Laki-laki)',
        'Mengenakan pakaian menutup aurat sempurna tanpa sarung tangan & cadar (Wanita)',
        'Melakukan sholat sunnah Ihram 2 rakaat di hotel atau masjid Miqat',
      ],
    ),
    GuideSectionModel(
      id: 'step_2',
      stepNumber: 'Tahap 2',
      title: 'Niat Ihram di Miqat (Bir Ali / Yalamlam / Tan\'im)',
      subtitle: 'Memasuki batas suci Miqat, mengucapkan niat Umrah, dan mulai berlakunya larangan.',
      icon: LucideIcons.mapPin,
      iconColor: AppColors.secondaryDark,
      content: 'Ketika tiba di batas Miqat (seperti Masjid Bir Ali bagi jamaah dari Madinah, atau ketika pesawat melewati atas Yalamlam/Qarnul Manazil), jamaah wajib berniat Ihram Umrah. Niat diucapkan di dalam hati dan dilafazkan dengan jelas: "Labbaikallahumma \'Umratan" (Ya Allah, aku penuhi panggilan-Mu untuk melaksanakan Umrah). Sejak saat niat diucapkan, maka seluruh larangan Ihram resmi berlaku hingga prosesi Tahallul selesai.',
      checklist: [
        'Memastikan posisi tepat di batas Miqat atau sebelum melewati garis Miqat',
        'Mengucapkan lafaz niat Umrah: Labbaikallahumma \'Umratan',
        'Membaca doa setelah niat memohon kemudahan dan penerimaan dari Allah SWT',
        'Menjaga ketat seluruh larangan Ihram (larangan potong rambut/kuku, wangi-wangian, bertengkar, dll)',
      ],
    ),
    GuideSectionModel(
      id: 'step_3',
      stepNumber: 'Tahap 3',
      title: 'Perjalanan Menuju Makkah & Perbanyak Talbiyah',
      subtitle: 'Menggemakan ucapan tauhid sepanjang perjalanan menuju Kota Suci Makkah.',
      icon: LucideIcons.mic,
      iconColor: AppColors.infoBlue,
      content: 'Selama perjalanan dari Miqat menuju Kota Suci Makkah dan Masjidil Haram, jamaah sangat dianjurkan untuk terus-menerus menggemakan kalimat Talbiyah. Bagi jamaah laki-laki disunnahkan mengeraskan suara dengan penuh semangat tauhid, sedangkan bagi jamaah wanita cukup dengan suara yang terdengar oleh dirinya sendiri: "Labbaikallahumma labbaik, labbaika laa syariika laka labbaik, innal hamda wanni\'mata laka wal mulk, laa syariika lak". Perbanyak pula istighfar, sholawat, dan doa kebaikan.',
      checklist: [
        'Melafazkan Talbiyah secara terus-menerus di dalam bus/kendaraan',
        'Jamaah laki-laki mengeraskan suara Talbiyah dengan penuh ketundukan',
        'Memperbanyak zikir, sholawat nabi, dan doa kebaikan dunia akhirat',
        'Menghentikan bacaan Talbiyah saat mulai melihat Ka\'bah atau hendak memulai Thawaf',
      ],
    ),
    GuideSectionModel(
      id: 'step_4',
      stepNumber: 'Tahap 4',
      title: 'Memasuki Masjidil Haram & Adab Melihat Ka\'bah',
      subtitle: 'Kesunahan, adab kesopanan, dan doa mustajab saat melangkah ke Baitullah.',
      icon: LucideIcons.heartHandshake,
      iconColor: AppColors.successGreen,
      content: 'Saat memasuki Masjidil Haram, disunnahkan masuk melalui pintu mana saja (diutamakan Babussalam jika memungkinkan) dengan mendahulukan kaki kanan sambil membaca doa masuk masjid: "Allahummaftah lii abwaaba rahmatik". Ketika pandangan mata pertama kali melihat Ka\'bah, berhentilah sejenak, angkat kedua tangan, dan berdoalah dengan penuh keharuan serta keikhlasan karena doa saat melihat Ka\'bah termasuk salah satu doa yang sangat mustajab.',
      checklist: [
        'Memastikan kesucian wudhu terjaga dengan baik sebelum memasuki gerbang masjid',
        'Melangkah masuk mendahulukan kaki kanan dan membaca doa masuk masjid',
        'Berdoa dengan khusyuk dan penuh pengharapan saat pertama kali memandang Ka\'bah',
        'Menuju ke pelataran Thawaf (Mataf) dengan tertib, tenang, dan tidak berdesakan',
      ],
    ),
    GuideSectionModel(
      id: 'step_5',
      stepNumber: 'Tahap 5',
      title: 'Thawaf Mengelilingi Ka\'bah (7 Putaran)',
      subtitle: 'Berjalan mengelilingi Ka\'bah berlawanan arah jarum jam dimulai sejajar Hajar Aswad.',
      icon: LucideIcons.rotateCw,
      iconColor: AppColors.primaryDark,
      content: 'Thawaf dimulai dari garis lurus pilar lampu hijau yang sejajar dengan Hajar Aswad. Bagi jamaah laki-laki disunnahkan melakukan Idhtiba\' (membuka bahu kanan) pada putaran ke-1 hingga ke-3, serta berlari kecil (Ramal). Setiap melewati garis sejajar Hajar Aswad, hadapkan badan sejenak sambil mengangkat tangan kanan dan mengucapkan Istilam: "Bismillahi Allahu Akbar". Berjalanlah berlawanan arah jarum jam di luar Hijir Ismail. Di antara Rukun Yamani dan Hajar Aswad, bacalah doa Sapu Jagat: "Rabbana aatinaa fiddunyaa hasanah wa fil aakhirati hasanah wa qinaa \'adzaabannaar". genapkan tepat 7 putaran.',
      checklist: [
        'Membuka bahu kanan (Idhtiba\') bagi jamaah laki-laki pada putaran 1 hingga 3',
        'Memulai setiap putaran tepat di garis sejajar Hajar Aswad dengan Istilam (Bismillahi Allahu Akbar)',
        'Berjalan mengelilingi Ka\'bah di luar lingkaran dinding Hijir Ismail berlawanan arah jarum jam',
        'Membaca doa Sapu Jagat di antara Rukun Yamani dan Hajar Aswad pada setiap putaran',
        'Menyelesaikan tepat 7 putaran sempurna dan menutup kembali bahu kanan setelah Thawaf selesai',
      ],
    ),
    GuideSectionModel(
      id: 'step_6',
      stepNumber: 'Tahap 6',
      title: 'Sholat Sunnah Thawaf & Minum Air Zamzam',
      subtitle: 'Sholat 2 rakaat di belakang Maqam Ibrahim, memohon doa, dan keberkahan air Zamzam.',
      icon: LucideIcons.coffee,
      iconColor: AppColors.secondaryLight,
      content: 'Setelah selesai 7 putaran Thawaf, menuju ke area belakang Maqam Ibrahim (atau tempat yang aman dari arus jamaah) untuk melaksanakan sholat sunnah Thawaf 2 rakaat (rakaat pertama membaca surat Al-Kafirun, rakaat kedua membaca surat Al-Ikhlas). Setelah sholat, pergilah ke kran air Zamzam, minumlah dengan puas sambil menghadap Ka\'bah dan berdoa: "Allahumma inni as-aluka \'ilman naafi\'an wa rizqan waasi\'an wa syifa-an min kulli daa-in". Jika situasi memungkinkan dan aman, berdoalah di area Multazam (antara pintu Ka\'bah dan Hajar Aswad).',
      checklist: [
        'Melaksanakan sholat sunnah Thawaf 2 rakaat di belakang Maqam Ibrahim atau area sekitarnya',
        'Berdoa dengan khusyuk memohon ampunan dan hajat setelah sholat Thawaf',
        'Minum air Zamzam sambil berdiri/duduk menghadap Ka\'bah disertai doa berkah Zamzam',
        'Mengusap wajah serta mendoakan kebaikan diri, orang tua, dan keluarga di Tanah Air',
      ],
    ),
    GuideSectionModel(
      id: 'step_7',
      stepNumber: 'Tahap 7',
      title: 'Sa\'i Antara Bukit Shafa dan Marwah (7 Perjalanan)',
      subtitle: 'Meneladani pengorbanan Ibunda Hajar dengan berjalan bolak-balik sebanyak 7 lintasan.',
      icon: LucideIcons.footprints,
      iconColor: AppColors.primary,
      content: 'Ibadah Sa\'i dimulai dari bukit Shafa. Naiklah ke bukit Shafa, menghadap ke Ka\'bah, bertakbir 3 kali, dan membaca zikir Shafa: "Innas shafaa wal marwata min sya\'aairillah...". Berjalanlah menuju bukit Marwah (dihitung 1 kali lintasan perjalanan). Di area antara dua pilar lampu hijau, bagi jamaah laki-laki disunnahkan berlari-lari kecil (Harwalah). Setibanya di bukit Marwah, naiklah, menghadap Ka\'bah dan berdoa (ini akhir lintasan ke-1). Kemudian berjalan kembali dari Marwah ke Shafa (dihitung lintasan ke-2). Genapkan hingga tepat 7 kali lintasan, sehingga lintasan ke-7 berakhir di puncak bukit Marwah.',
      checklist: [
        'Memulai dari bukit Shafa dengan membaca ayat: Innas shafaa wal marwata min sya\'aairillah',
        'Menghadap ke arah Ka\'bah dari atas bukit Shafa, bertakbir, dan memanjatkan doa',
        'Berlari kecil di antara area pilar lampu hijau (khusus bagi jamaah laki-laki)',
        'Menghitung dengan teliti setiap 1 lintasan (Shafa ke Marwah = 1, Marwah ke Shafa = 2)',
        'Berakhir tepat pada lintasan ke-7 di puncak bukit Marwah dengan doa syukur',
      ],
    ),
    GuideSectionModel(
      id: 'step_8',
      stepNumber: 'Tahap 8',
      title: 'Tahallul (Mencukur atau Memotong Rambut)',
      subtitle: 'Penghalalan kembali seluruh larangan Ihram dan tanda sempurna ibadah Umrah.',
      icon: LucideIcons.scissors,
      iconColor: AppColors.emergencyRed,
      content: 'Setibanya di bukit Marwah pada akhir putaran ke-7 Sa\'i, lakukanlah Tahallul sebagai penutup rangkaian ibadah Umrah. Bagi jamaah laki-laki, sangat diutamakan mencukur habis seluruh rambut kepala (Halq) karena mendapat doa ampunan khusus dari Rasulullah SAW sebanyak 3 kali, atau memotong minimal 3 helai rambut secara merata (Taqshir). Bagi jamaah wanita, cukup memotong ujung rambut sepanjang ruas jari (sekitar 1-2 cm) yang dilakukan oleh mahram atau sesama jamaah wanita. Dengan selesainya Tahallul ini, maka sempurna sudah ibadah Umrah Anda dan seluruh larangan Ihram telah halal kembali.',
      checklist: [
        'Mencukur gundul kepala (Laki-laki sangat diutamakan) atau memotong minimal 3 helai merata',
        'Memotong ujung rambut sepanjang ruas jari (khusus Wanita, dipotong oleh mahram/wanita lain)',
        'Mengucapkan Alhamdulillah sebagai bentuk syukur atas karunia selesainya ibadah Umrah',
        'Melepaskan kain Ihram dan kembali mengenakan pakaian biasa yang bersih dan rapi',
      ],
    ),
  ];

  int get _totalChecklistCount {
    int count = 0;
    for (var sec in _sections) {
      count += sec.checklist.length;
    }
    return count;
  }

  double get _progressPercentage {
    if (_totalChecklistCount == 0) return 0.0;
    return _checkedItems.length / _totalChecklistCount;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panduan Lengkap Umrah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Header Progress Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kemajuan Langkah Umrah Anda:',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '(${_checkedItems.length}/$_totalChecklistCount)',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressPercentage,
                    minHeight: 8,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Sections
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final sec = _sections[index];
                final isLast = index == _sections.length - 1;

                // Check if all items in this section are checked
                bool isAllChecked = sec.checklist.isNotEmpty;
                for (var item in sec.checklist) {
                  if (!_checkedItems.contains('${sec.id}_$item')) {
                    isAllChecked = false;
                    break;
                  }
                }

                return _ExpandableStepCard(
                  sec: sec,
                  isLast: isLast,
                  isAllChecked: isAllChecked,
                  checkedItems: _checkedItems,
                  onToggleCheck: (key) {
                    setState(() {
                      if (_checkedItems.contains(key)) {
                        _checkedItems.remove(key);
                      } else {
                        _checkedItems.add(key);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableStepCard extends StatefulWidget {
  final GuideSectionModel sec;
  final bool isLast;
  final bool isAllChecked;
  final Set<String> checkedItems;
  final ValueChanged<String> onToggleCheck;

  const _ExpandableStepCard({
    required this.sec,
    required this.isLast,
    required this.isAllChecked,
    required this.checkedItems,
    required this.onToggleCheck,
  });

  @override
  State<_ExpandableStepCard> createState() => _ExpandableStepCardState();
}

class _ExpandableStepCardState extends State<_ExpandableStepCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Roadmap Timeline vertical line & circle indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.isAllChecked
                      ? AppColors.successGreen
                      : widget.sec.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isAllChecked ? AppColors.successGreen : widget.sec.iconColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.isAllChecked ? LucideIcons.check : widget.sec.icon,
                  size: 16,
                  color: widget.isAllChecked ? Colors.white : widget.sec.iconColor,
                ),
              ),
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: widget.isAllChecked
                        ? AppColors.successGreen.withValues(alpha: 0.6)
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Step Card content (Clean Column inside AppleCard without ListTile/ExpansionTile overflow)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: AppleCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clickable Header to toggle expansion
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.sec.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.sec.subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                              size: 20,
                              color: AppColors.textSecondaryLight,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expandable Body
                    if (_isExpanded) ...[
                      Divider(
                        height: 1,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.primary.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Text(
                                widget.sec.content,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  height: 1.6,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Icon(LucideIcons.checkSquare, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Daftar Periksa Amalan & Sunnah:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...widget.sec.checklist.map((item) {
                              final key = '${widget.sec.id}_$item';
                              final isChecked = widget.checkedItems.contains(key);
                              return InkWell(
                                onTap: () => widget.onToggleCheck(key),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: isChecked ? AppColors.successGreen : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isChecked
                                                ? AppColors.successGreen
                                                : AppColors.textSecondaryLight.withValues(alpha: 0.5),
                                            width: 1.8,
                                          ),
                                        ),
                                        child: isChecked
                                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                                            color: isChecked
                                                ? AppColors.primary
                                                : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
