import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/order_models.dart';
import '../data/job_repository.dart';

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
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kGreenColor = Color(0xFF45A225);
    const kDisabledColor = Color(0xFFA5C498);

    final isFormValid = _checkIfFormValid();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: kDarkTextColor),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: const Text(
          'Submit Bid',
          style: TextStyle(
            color: kDarkTextColor,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobSummary(widget.job, kDarkTextColor, kMidTextColor),
            const SizedBox(height: 32),
            _buildInputLabel('Your Bid Amount (₦)', kDarkTextColor),
            const SizedBox(height: 12),
            _buildCustomInput(
              controller: _amountController,
              hint: 'Enter amount',
              prefix: Icons.attach_money,
              activeColor: kGreenColor,
              keyboardType: TextInputType.number,
              suffix: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _adjustAmount(100),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _adjustAmount(-100),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInputLabel('Estimated Delivery Time', kDarkTextColor),
            const SizedBox(height: 12),
            _buildCustomInput(
              controller: _timeController,
              hint: 'e.g., 45 minutes',
              prefix: Icons.access_time,
              activeColor: kGreenColor,
            ),
            const SizedBox(height: 24),
            _buildInputLabel('Message to Client (Optional)', kDarkTextColor),
            const SizedBox(height: 12),
            _buildCustomInput(
              controller: _messageController,
              hint:
                  'Introduce yourself and explain why you\'re the best choice...',
              activeColor: kGreenColor,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(
              isFormValid ? kGreenColor : kDisabledColor,
              isFormValid,
            ),
            const SizedBox(height: 24),
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: controller.text.trim().isNotEmpty
              ? activeColor
              : const Color(0xFFF1F5F9),
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
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 20, right: 12),
                  child: Icon(prefix, color: const Color(0xFF94A3B8)),
                )
              : null,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildJobSummary(Order job, Color darkText, Color midText) {
    final title = job.items.isNotEmpty
        ? job.items.first.name ?? 'Item'
        : 'Bulk Delivery';
    final from = 'Vendor Depot';
    final to = job.id.substring(0, 8);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            job.id.substring(0, 8),
            style: TextStyle(
              fontSize: 14,
              color: midText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          _buildLocationRow(Icons.location_on_outlined, from, Colors.green),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on_outlined, 'Near $to', Colors.red),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${job.items.length} items',
                style: TextStyle(
                  color: midText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₦${job.totalProductAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label, Color darkText) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: darkText,
      ),
    );
  }

  Widget _buildSubmitButton(Color bgColor, bool isEnabled) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () async {
                final amount = double.tryParse(_amountController.text) ?? 0;

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                final success = await ref
                    .read(jobRepositoryProvider)
                    .submitBid(orderId: widget.job.id, amount: amount);

                if (mounted) {
                  Navigator.pop(context); // Close loading

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bid submitted successfully!'),
                        backgroundColor: Color(0xFF45A225),
                      ),
                    );
                    context.go('/driver');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to submit bid.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 20),
            SizedBox(width: 12),
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
