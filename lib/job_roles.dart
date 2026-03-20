import 'package:flutter/material.dart';
import 'package:rojgar/careear_hub.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color headerTop = Color(0xFF0000DD);
  static const Color headerBottom = Color(0xFF2828FF);
  static const Color background = Color(0xFFF0F0F5);
  static const Color white = Colors.white;
  static const Color yellow = Color(0xFFFFCC00);
  static const Color iconBg = Color(0xFFDDDDF8);
  static const Color iconColor = Color(0xFF1A1ACD);
  static const Color cardShadow = Color(0x12000000);
  static const Color titleText = Color(0xFF111133);
  static const Color metaText = Color(0xFF888899);
  static const Color tabInactiveText = Color(0xFF555577);
  static const Color activeTabText = Color(0xFF1A1ACD);
  static const Color departmentLabel = Color(0xAAFFFFFF);
}

class JobItem {
  final IconData icon;
  final String title;
  final String meta;
  const JobItem(this.icon, this.title, this.meta);
}

class EngineeringRolesScreen extends StatefulWidget {
  const EngineeringRolesScreen({super.key});

  @override
  State<EngineeringRolesScreen> createState() => _EngineeringRolesScreenState();
}

class _EngineeringRolesScreenState extends State<EngineeringRolesScreen> {
  int _selectedTab = 0;

  static const List<String> tabs = ['All Roles', 'Frontend', 'Backend'];

  static const List<JobItem> jobs = [
    JobItem(
      Icons.terminal_rounded,
      'Senior Frontend Architect',
      'Remote • \$140k – \$180k',
    ),
    JobItem(
      Icons.storage_rounded,
      'Backend Engineer (Go)',
      'New York • Full-time',
    ),
    JobItem(
      Icons.cloud_rounded,
      'Site Reliability Engineer',
      'Hybrid • London, UK',
    ),
    JobItem(
      Icons.phone_iphone_rounded,
      'iOS Developer (SwiftUI)',
      'Remote • Contract',
    ),
    JobItem(Icons.shield_rounded, 'Security Engineer', 'On-site • Berlin'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              child: Column(
                children: jobs
                    .map(
                      (job) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CareerHubScreen(),
                              ),
                            );
                          },
                          child: _buildJobCard(job),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0000CC), Color(0xFF2222FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topPadding + 8),
          // App bar row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _headerIconButton(Icons.arrow_back_rounded),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Engineering Roles',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                _headerIconButton(Icons.search_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Department label + title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'DEPARTMENT',
                  style: TextStyle(
                    color: AppColors.departmentLabel,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Software\nEngineering',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          // Tab row — overlaps into light bg
          SizedBox(
            height: 48,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CareerHubScreen(),
                  ),
                );
              },
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
                itemCount: tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _buildTab(i),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon) {
    return Icon(icon, color: Colors.white, size: 24);
  }

  Widget _buildTab(int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.yellow : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? AppColors.yellow : Colors.white,
            width: 1.5,
          ),
        ),
        child: Text(
          tabs[index],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isActive
                ? AppColors.activeTabText
                : AppColors.tabInactiveText,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(JobItem job) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(job.icon, color: AppColors.iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleText,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  job.meta,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.metaText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Arrow button
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.iconColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
