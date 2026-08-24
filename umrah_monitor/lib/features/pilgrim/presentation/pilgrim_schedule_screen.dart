import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';

class CheckpointModel {
  final String id;
  final String title;
  final String location;
  final String date;
  final String status; // 'completed', 'in_progress', 'upcoming'
  final String description;
  final bool hasReminder;

  const CheckpointModel({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.description,
    this.hasReminder = false,
  });
}

class PilgrimScheduleScreen extends StatefulWidget {
  final bool isFamilyView;
  const PilgrimScheduleScreen({super.key, this.isFamilyView = false});

  @override
  State<PilgrimScheduleScreen> createState() => _PilgrimScheduleScreenState();
}

class _PilgrimScheduleScreenState extends State<PilgrimScheduleScreen> {
  final List<CheckpointModel> _checkpoints = const [
    CheckpointModel(
      id: 'cp1',
      title: 'Airport Assembly & Briefing',
      location: 'Soekarno-Hatta Airport Terminal 3',
      date: '14 July 2026 - 06:00 AM',
      status: 'completed',
      description: 'Luggage check-in, passport distribution, and group doa before flight.',
    ),
    CheckpointModel(
      id: 'cp2',
      title: 'Departure Flight to Jeddah',
      location: 'Saudia SV 817 (Direct Flight)',
      date: '14 July 2026 - 10:45 AM',
      status: 'completed',
      description: 'Flight duration approximately 9 hours. Ihram intention over Yalamlam.',
    ),
    CheckpointModel(
      id: 'cp3',
      title: 'Arrival & Bus Transfer',
      location: 'King Abdulaziz Airport Jeddah -> Makkah',
      date: '14 July 2026 - 06:30 PM',
      status: 'completed',
      description: 'Immigration clearance and VIP air-conditioned bus transit to Makkah hotel.',
    ),
    CheckpointModel(
      id: 'cp4',
      title: 'Hotel Check-In & Rest',
      location: 'Swissôtel Al Maqam Makkah',
      date: '14 July 2026 - 09:30 PM',
      status: 'completed',
      description: 'Room key card allocation, dinner buffet, and resting before Umrah rituals.',
    ),
    CheckpointModel(
      id: 'cp5',
      title: 'First Umrah Ritual (Tawaf & Sa\'i)',
      location: 'Masjidil Haram & Safa-Marwah',
      date: '15 July 2026 - 02:00 AM',
      status: 'completed',
      description: 'Guided Tawaf 7 rounds around the Kaaba, Sa\'i, and Tahallul hair trimming.',
    ),
    CheckpointModel(
      id: 'cp6',
      title: 'Group Ziyarah Makkah',
      location: 'Jabal Rahmah, Cave Hira, & Mina/Arafah preview',
      date: '16 July 2026 - 07:30 AM',
      status: 'in_progress',
      description: 'Historical tour around holy sites in Makkah via Group Bus #08.',
      hasReminder: true,
    ),
    CheckpointModel(
      id: 'cp7',
      title: 'Tawaf Wada (Farewell Tawaf)',
      location: 'Masjidil Haram',
      date: '19 July 2026 - 08:00 AM',
      status: 'upcoming',
      description: 'Final farewell circumambulation before departing to Madinah Al-Munawwarah.',
      hasReminder: true,
    ),
    CheckpointModel(
      id: 'cp8',
      title: 'Transit to Madinah via High-Speed Haramain Train',
      location: 'Makkah Station -> Madinah Station',
      date: '19 July 2026 - 02:00 PM',
      status: 'upcoming',
      description: 'Comfortable 2-hour high-speed rail transfer.',
      hasReminder: true,
    ),
    CheckpointModel(
      id: 'cp9',
      title: 'Raudhah Visit & Prophet\'s Mosque',
      location: 'Masjid Nabawi (Tasreh Group Entry)',
      date: '21 July 2026 - 09:00 AM',
      status: 'upcoming',
      description: 'Scheduled entry to Raudhah Al-Sharifah with Muthawif accompaniment.',
    ),
    CheckpointModel(
      id: 'cp10',
      title: 'Historical Ziyarah Madinah',
      location: 'Quba Mosque, Uhud Mountain, Date Garden',
      date: '22 July 2026 - 07:30 AM',
      status: 'upcoming',
      description: 'Remember to perform 2 raka\'at at Quba Mosque for the reward of one Umrah.',
    ),
    CheckpointModel(
      id: 'cp11',
      title: 'Return Flight to Jakarta',
      location: 'Prince Mohammad Bin Abdulaziz Airport Madinah',
      date: '24 July 2026 - 04:15 PM',
      status: 'upcoming',
      description: 'Luggage drop-off and return journey home safely.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jadwal Perjalanan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isFamilyView
                              ? 'Kloter 4 Al-Barakah VIP • Jadwal Jamaah Dipantau Keluarga'
                              : 'Kloter 4 Al-Barakah VIP • Rangkaian Ibadah',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Itinerary downloaded as PDF.')),
                        );
                      },
                      icon: Icon(LucideIcons.download, size: 20, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                      tooltip: 'Download PDF',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                itemCount: _checkpoints.length,
                itemBuilder: (context, index) {
                  final cp = _checkpoints[index];
                  final isLast = index == _checkpoints.length - 1;

          Color statusColor;
          String statusLabel;
          IconData statusIcon;

          if (cp.status == 'completed') {
            statusColor = AppColors.successGreen;
            statusLabel = 'Completed';
            statusIcon = LucideIcons.checkCircle2;
          } else if (cp.status == 'in_progress') {
            statusColor = AppColors.infoBlue;
            statusLabel = 'Current Phase';
            statusIcon = LucideIcons.clock;
          } else {
            statusColor = AppColors.textTertiaryLight;
            statusLabel = 'Upcoming';
            statusIcon = LucideIcons.circle;
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator line & dot
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: cp.status == 'upcoming' ? 0.12 : 1.0),
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor, width: 2),
                      ),
                      child: Icon(
                        statusIcon,
                        size: 13,
                        color: cp.status == 'upcoming' ? statusColor : Colors.white,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: cp.status == 'completed' ? AppColors.successGreen.withValues(alpha: 0.6) : AppColors.borderLight,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Checkpoint Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: AppleCard(
                      padding: const EdgeInsets.all(16),
                      border: cp.status == 'in_progress'
                          ? Border.all(color: AppColors.infoBlue, width: 1.5)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge(label: statusLabel, color: statusColor),
                              if (cp.hasReminder)
                                const Icon(LucideIcons.bellRing, size: 15, color: AppColors.secondaryDark),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cp.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, size: 13, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cp.location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 13, color: AppColors.textTertiaryLight),
                              const SizedBox(width: 6),
                              Text(
                                cp.date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cp.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
            ),
          ],
        ),
      ),
    );
  }
}
