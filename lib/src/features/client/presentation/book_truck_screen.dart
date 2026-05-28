import 'package:flutter/material.dart';
import '../../../common/config/app_config.dart';
import '../../../common/utils/launch_url.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';

/// Lets a client request a truck for a scheduled move. There is no backend
/// booking endpoint yet, so the collected details are sent to GoPickup support
/// over WhatsApp (single source of truth: [AppConfig.supportPhone]).
class BookTruckScreen extends StatefulWidget {
  const BookTruckScreen({super.key});

  @override
  State<BookTruckScreen> createState() => _BookTruckScreenState();
}

class _BookTruckScreenState extends State<BookTruckScreen> {
  static const List<String> _truckTypes = [
    'Tricycle',
    'Van',
    'Truck',
    'Flatbed',
    'Trailer',
  ];

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _cargoController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _truckType;
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _cargoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _dateLabel {
    final d = _date;
    if (d == null) return 'Select date';
    return '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String get _timeLabel => _time == null ? 'Select time' : _time!.format(context);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String? _firstMissingField() {
    if (_pickupController.text.trim().isEmpty) return 'Enter a pickup address';
    if (_dropoffController.text.trim().isEmpty) return 'Enter a drop-off address';
    if (_truckType == null) return 'Select a truck type';
    if (_date == null) return 'Select a date';
    if (_time == null) return 'Select a time';
    if (_cargoController.text.trim().isEmpty) return 'Describe the cargo';
    if (_phoneController.text.trim().isEmpty) return 'Enter a contact phone number';
    return null;
  }

  String _buildMessage() {
    return 'Truck Booking Request\n\n'
        'Truck type: $_truckType\n'
        'Pickup: ${_pickupController.text.trim()}\n'
        'Drop-off: ${_dropoffController.text.trim()}\n'
        'Date: $_dateLabel\n'
        'Time: $_timeLabel\n'
        'Cargo: ${_cargoController.text.trim()}\n'
        'Contact: ${_phoneController.text.trim()}';
  }

  Future<void> _submit() async {
    final missing = _firstMissingField();
    if (missing != null) {
      _showSnack(missing);
      return;
    }

    setState(() => _submitting = true);
    try {
      final ok = await openExternalUrl(AppConfig.supportWhatsappUrl(_buildMessage()));
      if (!ok && mounted) {
        _showSnack('Could not open WhatsApp. Please contact support directly.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Book Truck', style: AppTextStyles.headingMd),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            // Intro
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.vendorAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.vendorAccent.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_rounded,
                    color: AppColors.vendorAccent,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Tell us what you need to move. We\'ll confirm your truck '
                      'and price over WhatsApp.',
                      style: AppTextStyles.bodySm.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('Truck type'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _truckTypes.map(_buildTruckChip).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('Pickup address'),
            const SizedBox(height: AppSpacing.sm),
            _textField(
              controller: _pickupController,
              hint: 'Where should we collect from?',
              icon: Icons.my_location_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('Drop-off address'),
            const SizedBox(height: AppSpacing.sm),
            _textField(
              controller: _dropoffController,
              hint: 'Where are we delivering to?',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('When do you need it?'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _pickerTile(
                    icon: Icons.calendar_today_rounded,
                    text: _dateLabel,
                    isPlaceholder: _date == null,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _pickerTile(
                    icon: Icons.access_time_rounded,
                    text: _timeLabel,
                    isPlaceholder: _time == null,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('Cargo details'),
            const SizedBox(height: AppSpacing.sm),
            _textField(
              controller: _cargoController,
              hint: 'What are you moving? (e.g. 50 bags of cement)',
              icon: Icons.inventory_2_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('Contact phone'),
            const SizedBox(height: AppSpacing.sm),
            _textField(
              controller: _phoneController,
              hint: 'Phone number we can call',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.xxl),

            PrimaryButton(
              label: 'Send booking request',
              icon: Icons.send_rounded,
              isLoading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
      );

  Widget _buildTruckChip(String type) {
    final selected = _truckType == type;
    return GestureDetector(
      onTap: () => setState(() => _truckType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Text(
          type,
          style: AppTextStyles.label.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
        prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 22),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required bool isPlaceholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySm.copyWith(
                  color: isPlaceholder
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
