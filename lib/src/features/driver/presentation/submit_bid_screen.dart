import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SubmitBidScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> job;

  const SubmitBidScreen({super.key, required this.job});

  @override
  ConsumerState<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends ConsumerState<SubmitBidScreen> {
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateForm);
    _timeController.addListener(_validateForm);
    _messageController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _amountController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        _messageController.text.isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _adjustAmount(int delta) {
    final current = int.tryParse(_amountController.text) ?? 100;
    final newValue = current + delta;
    if (newValue >= 0) {
      _amountController.text = newValue.toString();
    }
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
            _buildOtherBidsSection(kMidTextColor, kDarkTextColor),
            const SizedBox(height: 32),
            _buildInputLabel('Your Bid Amount', kDarkTextColor),
            const SizedBox(height: 12),
            _buildBidAmountInput(kGreenColor),
            const SizedBox(height: 24),
            _buildInputLabel('Estimated Delivery Time', kDarkTextColor),
            const SizedBox(height: 12),
            _buildDeliveryTimeInput(),
            const SizedBox(height: 24),
            _buildInputLabel('Message to Client (Optional)', kDarkTextColor),
            const SizedBox(height: 12),
            _buildMessageInput(),
            const SizedBox(height: 40),
            _buildSubmitButton(_isFormValid ? kGreenColor : kDisabledColor),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSummary(Map<String, dynamic> job, Color darkText, Color midText) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job['title'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: darkText),
          ),
          const SizedBox(height: 20),
          _buildLocationRow(Icons.location_on_outlined, job['from'], Colors.green),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on_outlined, job['to'], Colors.red),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${job['dist']}   ${job['weight']}',
                style: TextStyle(color: midText, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                job['price'],
                style: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.w800),
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
            style: const TextStyle(color: Color(0xFF475569), fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOtherBidsSection(Color midText, Color darkText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Bids',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: midText),
        ),
        const SizedBox(height: 16),
        _buildOtherBidItem('Mike T.', '4.8', '\$100', '45 mins', darkText, midText),
        const SizedBox(height: 12),
        _buildOtherBidItem('Sarah L.', '4.6', '\$95', '50 mins', darkText, midText),
      ],
    );
  }

  Widget _buildOtherBidItem(String name, String rating, String amount, String time, Color darkText, Color midText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, size: 20, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: darkText)),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(rating, style: TextStyle(color: midText, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkText)),
              Text(time, style: TextStyle(color: midText, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, Color darkText) {
    return Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkText));
  }

  Widget _buildBidAmountInput(Color activeBorder) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _amountController.text.isNotEmpty ? activeBorder : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Enter amount',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 20, right: 12),
            child: Icon(Icons.attach_money, color: Color(0xFF94A3B8)),
          ),
          suffixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _adjustAmount(5),
                child: const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF94A3B8), size: 18),
              ),
              GestureDetector(
                onTap: () => _adjustAmount(-5),
                child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 18),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _timeController.text.isNotEmpty ? const Color(0xFFF1F5F9) : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _timeController,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          hintText: 'e.g., 45 minutes',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20, right: 12),
            child: Icon(Icons.access_time, color: Color(0xFF94A3B8)),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: TextField(
        controller: _messageController,
        onChanged: (_) => setState(() {}),
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Introduce yourself and explain why you\'re the\nbest choice...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400, height: 1.5),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color bgColor) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isFormValid
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bid submitted successfully!'), backgroundColor: Color(0xFF45A225)),
                );
                context.pop();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 20),
            SizedBox(width: 12),
            Text(
              'Submit Bid',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
