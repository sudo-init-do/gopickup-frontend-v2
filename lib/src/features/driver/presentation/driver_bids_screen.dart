import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';

class DriverBidsScreen extends ConsumerStatefulWidget {
  const DriverBidsScreen({super.key});

  @override
  ConsumerState<DriverBidsScreen> createState() => _DriverBidsScreenState();
}

class _DriverBidsScreenState extends ConsumerState<DriverBidsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabs(
              _selectedTabIndex,
              (index) => setState(() => _selectedTabIndex = index),
            ),
            Expanded(
              child: _buildBidsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bids & Negotiations', style: AppTextStyles.displayLg),
          SizedBox(height: AppSpacing.xs),
          Text('Manage your job bids', style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildTabs(int selectedIndex, Function(int) onSelect) {
    final tabs = ['My Bids', 'Won', 'Lost'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: index == tabs.length - 1 ? 0 : AppSpacing.sm,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.driverAccent : AppColors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: AppTextStyles.label.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBidsList() {
    const bids = []; // Bidding system is replaced by direct assignment

    if (bids.isEmpty) {
      return const AppEmptyState(
        icon: Icons.gavel_outlined,
        title: 'Bidding currently disabled',
        message: 'Bidding systems are currently disabled.\nCheck "New Jobs" for assigned tasks.',
      );
    }
    return const SizedBox.shrink();
  }
}
