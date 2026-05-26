import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/order_models.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_card.dart';

class SubmitBidScreen extends ConsumerStatefulWidget {
  final Order job;

  const SubmitBidScreen({super.key, required this.job});

  @override
  ConsumerState<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends ConsumerState<SubmitBidScreen> {
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default bid amount could be based on order total or some calculation
    _amountController.text = (widget.job.totalProductAmount * 0.1)
        .toInt()
        .toString();
  }

  void _adjustAmount(int delta) {
    setState(() {
      final current = int.tryParse(_amountController.text) ?? 100;
      final newValue = current + delta;
      if (newValue >= 0) {
        _amountController.text = newValue.toString();
      }
    });
  }

  bool _checkIfFormValid() {
    return _amountController.text.trim().isNotEmpty &&
        _timeController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _timeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Disabled color for the bid button (intentionally disabled per business rules)
    const kDisabledColor = Color(0xFFA5C498);

    final isFormValid = _checkIfFormValid();

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.backgroundSubtle,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: const Text(
          'Submit Bid',
          style: AppTextStyles.headingLg,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobSummary(widget.job),
            const SizedBox(height: AppSpacing.xxl),
            _buildInputLabel('Your Bid Amount (₦)'),
            const SizedBox(height: AppSpacing.md),
            _buildCustomInput(
              controller: _amountController,
              hint: 'Enter amount',
              prefix: Icons.attach_money,
              activeColor: AppColors.primary,
              keyboardType: TextInputType.number,
              suffix: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _adjustAmount(100),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _adjustAmount(-100),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildInputLabel('Estimated Delivery Time'),
            const SizedBox(height: AppSpacing.md),
            _buildCustomInput(
              controller: _timeController,
              hint: 'e.g., 45 minutes',
              prefix: Icons.access_time,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildInputLabel('Message to Client (Optional)'),
            const SizedBox(height: AppSpacing.md),
            _buildCustomInput(
              controller: _messageController,
              hint:
                  'Introduce yourself and explain why you\'re the best choice...',
              activeColor: AppColors.primary,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _buildSubmitButton(
              // Intentionally-disabled bid button — keeps disabled behavior per business rules
              isFormValid ? kDisabledColor : kDisabledColor,
              isFormValid,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInput({
    required TextEditingController controller,
    required String hint,
    IconData? prefix,
    required Color activeColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: controller.text.trim().isNotEmpty
              ? activeColor
              : AppColors.backgroundSubtle,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 20, right: AppSpacing.md),
                  child: Icon(prefix, color: AppColors.textTertiary),
                )
              : null,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.lg),
        ),
      ),
    );
  }

  Widget _buildJobSummary(Order job) {
    final title = job.items.isNotEmpty
        ? job.items.first.name ?? 'Item'
        : 'Bulk Delivery';
    const from = 'Vendor Depot';
    final to = job.id.substring(0, 8);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headingMd.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            job.id.substring(0, 8),
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildLocationRow(Icons.location_on_outlined, from, AppColors.success),
          const SizedBox(height: AppSpacing.md),
          _buildLocationRow(Icons.location_on_outlined, 'Near $to', AppColors.destructive),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.backgroundSubtle),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${job.items.length} items',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '₦${job.totalProductAmount.toStringAsFixed(2)}',
                style: AppTextStyles.headingMd.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildSubmitButton(Color bgColor, bool isEnabled) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () async {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // final success = await ref
                //     .read(jobRepositoryProvider)
                //     .submitBid(orderId: widget.job.id, amount: amount);
                // ignore: unused_local_variable
                const success = false;

                if (mounted) {
                  Navigator.pop(context); // Close loading

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bidding is currently disabled for this task. Please check assigned jobs.'),
                      backgroundColor: AppColors.driverAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go('/driver');
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 20),
            SizedBox(width: AppSpacing.md),
            Text(
              'Submit Bid',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
