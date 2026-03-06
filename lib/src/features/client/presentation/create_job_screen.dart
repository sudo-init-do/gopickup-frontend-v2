import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedVehicle = 'Truck';

  final List<String> _vehicles = [
    'Bicycle',
    'Motorcycle',
    'Car',
    'Van',
    'Truck',
    'Large Truck',
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF64748B);
    const kBrandGreen = Color(0xFF3B7D23);

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
              backgroundColor: const Color(0xFFF9FAFB),
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: const Text(
          'Post a Load',
          style: TextStyle(
            color: kDarkTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Pickup Location', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField(
              _pickupController,
              'Enter pickup address',
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('Delivery Destination', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField(
              _deliveryController,
              'Enter delivery address',
              Icons.flag_outlined,
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('Vehicle Requirement', kDarkTextColor),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _vehicles.map((v) {
                final isSelected = _selectedVehicle == v;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVehicle = v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kBrandGreen : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? kBrandGreen
                            : const Color(0xFFF1F5F9),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      v,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kMidTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Est. Weight (kg)', kDarkTextColor),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _weightController,
                        '0',
                        Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Budget (₦)', kDarkTextColor),
                      const SizedBox(height: 12),
                      _buildTextField(
                        TextEditingController(),
                        'Optional',
                        Icons.attach_money_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('Load Description', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField(
              _descriptionController,
              'Describe what you are moving...',
              null,
              maxLines: 4,
            ),

            const SizedBox(height: 48),
            _buildSubmitButton(kBrandGreen),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData? icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF94A3B8), size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job posted successfully! Bids will appear soon.'),
              backgroundColor: Color(0xFF3B7D23),
            ),
          );
          context.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: const Text(
          'Post Job',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
