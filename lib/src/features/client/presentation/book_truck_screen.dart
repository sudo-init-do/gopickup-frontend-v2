import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookTruckScreen extends StatefulWidget {
  const BookTruckScreen({super.key});

  @override
  State<BookTruckScreen> createState() => _BookTruckScreenState();
}

class _BookTruckScreenState extends State<BookTruckScreen> {
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedVehicle = 'Tricycle';

  final List<String> _vehicles = [
    'Tricycle',
    'Van',
    'Canter',
    'Truck',
    'Flatbed',
    'Tipper',
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B7D23),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B7D23),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!context.mounted) return;
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
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
          'Book a Truck',
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

            _buildSectionLabel('Select Vehicle', kDarkTextColor),
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
                      _buildSectionLabel('Date', kDarkTextColor),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            _dateController,
                            'Select Date',
                            Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Time', kDarkTextColor),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            _timeController,
                            'Select Time',
                            Icons.access_time_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('Note to Driver', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField(
              _noteController,
              'Any special instructions...',
              null,
              maxLines: 3,
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
              content: Text('Truck booked successfully!'),
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
          'Confirm Booking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
