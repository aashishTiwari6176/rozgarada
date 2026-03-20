import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/controllers/explore_screen_controller.dart';
import 'package:rojgar/job_roles.dart';
import 'package:rojgar/localization/app_localizations.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color background = Color(0xFFF2F2F7);
  static const Color white = Colors.white;
  static const Color primaryBlue = Color(0xFF1A18D6);
  static const Color categoryBlue = Color(0xFF1A18D6);
  static const Color iconBg = Color(0xFFE0DEFC);
  static const Color pillYellow = Color(0xFFF5F1A0);
  static const Color pillText = Color(0xFF1A18D6);
  static const Color decorYellow = Color(0xFFF9F7C0);
  static const Color grey = Color(0xFF8E8E93);
  static const Color darkText = Color(0xFF1C1C1E);
  static const Color navUnselected = Color(0xFF8E8E93);
  static const Color navSelected = Color(0xFF1A18D6);
  static const Color bannerGradientStart = Color(0xFF1A18D6);
  static const Color bannerGradientEnd = Color(0xFF3B39FF);
  static const Color cardShadow = Color(0x14000000);
}

class ExploreCareerScreen extends StatelessWidget {
  const ExploreCareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = Get.put(DashboardController(), permanent: true);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildOpportunitiesPill(l10n),
                    const SizedBox(height: 10),
                    Text(
                      l10n.text('explore_job_categories'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.text('explore_job_categories_subtitle'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.grey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryGrid(controller),
                    const SizedBox(height: 20),
                    _buildCustomSearchBanner(l10n),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar: _buildBottomNav(),
      // floatingActionButton: _buildFab(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _circleButton(Icons.arrow_back_ios_new_rounded),
          Expanded(
            child: Center(
              child: Text(
                l10n.text('explore_careers_title'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ),
          _circleButton(Icons.search_rounded),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.darkText),
    );
  }

  Widget _buildOpportunitiesPill(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pillYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.text('explore_opportunities_pill').toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.pillText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(DashboardController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        );
      }

      if (controller.error.value != null && controller.categories.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.error.value!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: controller.fetchDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.categories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No categories found',
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
        );
      }

      final items = controller.categories;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EngineeringRolesScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: _buildCategoryCard(items[i].name, items[i].imageUrl),
        ),
      );
    });
  }

  Widget _buildCategoryCard(String name, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Decorative yellow curve top-right
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.decorYellow,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.iconBg,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.work_outline_rounded,
                              color: AppColors.primaryBlue,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.categoryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSearchBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bannerGradientStart, AppColors.bannerGradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('explore_custom_search'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.text('explore_custom_search_sub'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFFFFE234),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.white,
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'HOME', false),
            _navItem(Icons.grid_view_rounded, 'EXPLORE', true),
            const SizedBox(width: 48), // FAB space
            _navItem(Icons.bookmark_outline_rounded, 'SAVED', false),
            _navItem(Icons.person_outline_rounded, 'PROFILE', false),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    final color = selected ? AppColors.navSelected : AppColors.navUnselected;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColors.primaryBlue,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
