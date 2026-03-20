import 'package:flutter/material.dart';
import 'package:rojgar/job_detail.dart';
import 'package:rojgar/localization/app_localizations.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color background = Color(0xFFF2F2F7);
  static const Color white = Colors.white;
  static const Color primaryBlue = Color(0xFF1A1AE6);
  static const Color jobTitleBlue = Color(0xFF1A1AE6);
  static const Color darkText = Color(0xFF111122);
  static const Color greyText = Color(0xFF888899);
  static const Color lightGreyText = Color(0xFFAAABBB);
  static const Color searchBg = Color(0xFFEEEEF4);
  static const Color tagBg = Color(0xFFEEEEF8);
  static const Color tagText = Color(0xFF3333CC);
  static const Color salaryTagBg = Color(0xFFEEEEF4);
  static const Color salaryTagText = Color(0xFF444455);
  static const Color cardShadow = Color(0x10000000);
  static const Color borderGrey = Color(0xFFDDDDE8);
  static const Color inactiveTabText = Color(0xFF444455);
  static const Color bookmarkActive = Color(0xFF1A1AE6);
  static const Color bookmarkInactive = Color(0xFF9999AA);
  static const Color appBarText = Color(0xFF111122);
}

class JobListing {
  final Color logoColor;
  final String logoLabel;
  final String title;
  final String company;
  final String location;
  final String jobType;
  final String salary;
  final String postedAgo;
  final bool bookmarked;

  const JobListing({
    required this.logoColor,
    required this.logoLabel,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.postedAgo,
    this.bookmarked = false,
  });
}

class CareerHubScreen extends StatefulWidget {
  const CareerHubScreen({super.key});

  @override
  State<CareerHubScreen> createState() => _CareerHubScreenState();
}

class _CareerHubScreenState extends State<CareerHubScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All Jobs', 'Remote', 'Full-time', 'Salary'];

  final List<JobListing> _jobs = const [
    JobListing(
      logoColor: Color(0xFFEEEEEE),
      logoLabel: 'TECHFLOW',
      title: 'Senior Frontend Engineer',
      company: 'TechFlow Solutions',
      location: 'New York, NY',
      jobType: 'Full-time',
      salary: '\$140k - \$180k',
      postedAgo: 'Posted 2 days ago',
      bookmarked: false,
    ),
    JobListing(
      logoColor: Color(0xFFF5A623),
      logoLabel: 'CP',
      title: 'Product Designer',
      company: 'Creative Pulse',
      location: 'Remote',
      jobType: 'Contract',
      salary: '\$120k - \$160k',
      postedAgo: 'Posted 5 hours ago',
      bookmarked: true,
    ),
    JobListing(
      logoColor: Color(0xFFEEEEEE),
      logoLabel: 'LOGICORE',
      title: 'Backend Architect',
      company: 'LogiCore',
      location: 'Austin, TX',
      jobType: 'Full-time',
      salary: '\$160k - \$210k',
      postedAgo: 'Posted 1 day ago',
      bookmarked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── App Bar + Search (white section) ──────────────────────────────
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 0),
            child: Column(
              children: [
                _buildAppBar(l10n),
                const SizedBox(height: 18),
                _buildSearchBar(l10n),
                const SizedBox(height: 18),
                _buildFilterTabs(l10n),
                const SizedBox(height: 4),
              ],
            ),
          ),
          // ── Job List ──────────────────────────────────────────────────────
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobDetailScreen(),
                  ),
                );
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                itemCount: _jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobDetailScreen(),
                      ),
                    );
                  },
                  child: _buildJobCard(_jobs[i], context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return Row(
      children: [
        // Logo + name
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.work_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.text('careerhub_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.appBarText,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_rounded,
            color: AppColors.appBarText,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.searchBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded,
              color: AppColors.greyText, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.text('careerhub_search_hint'),
              style: const TextStyle(
                  color: AppColors.greyText, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final isActive = i == _selectedTab;
          final key = switch (i) {
            0 => 'careerhub_tab_all',
            1 => 'careerhub_tab_remote',
            2 => 'careerhub_tab_fulltime',
            3 => 'careerhub_tab_salary',
            _ => 'careerhub_tab_all',
          };
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryBlue
                      : AppColors.borderGrey,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.text(key),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : AppColors.inactiveTabText,
                    ),
                  ),
                  if (i != 0) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isActive ? Colors.white : AppColors.greyText,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(JobListing job, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: logo + bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(job),
              const Spacer(),
              Icon(
                job.bookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: job.bookmarked
                    ? AppColors.bookmarkActive
                    : AppColors.bookmarkInactive,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Job title
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.jobTitleBlue,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          // Company + location
          Text(
            '${job.company} • ${job.location}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.greyText,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          // Tag pills
          Row(
            children: [
              _buildTag(job.jobType, isType: true),
              const SizedBox(width: 10),
              _buildTag(job.salary, isType: false),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom row: posted + apply button
          Row(
            children: [
              Text(
                job.postedAgo,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.lightGreyText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _buildApplyButton(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobDetailScreen(),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(JobListing job) {
    final isTextOnly = job.logoColor == const Color(0xFFEEEEEE);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: job.logoColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: isTextOnly
          ? Center(
              child: Text(
                job.company.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greyText,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : Center(
              child: Text(
                job.logoLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
    );
  }

  Widget _buildTag(String label, {required bool isType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isType ? AppColors.tagBg : AppColors.salaryTagBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isType ? AppColors.tagText : AppColors.salaryTagText,
        ),
      ),
    );
  }

  Widget _buildApplyButton(VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            child: Text(
              'Apply Now',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
