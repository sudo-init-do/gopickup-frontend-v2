import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../state/load_provider.dart';

/// "Post Load" — lets a client schedule a delivery. The request is saved to the
/// backend as an open Load that the GoPickup team confirms manually (and that
/// drivers can bid on). This is the scheduled counterpart to the live
/// "Book Driver" flow.
class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  static const List<String> _goodsTypes = [
    'Cement',
    'Sand / Gravel',
    'Blocks',
    'Furniture',
    'Equipment',
    'Food items',
    'Other',
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
  final _weightController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  String? _goodsType;
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;
  bool _done = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _weightController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
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
    if (_goodsType == null) return 'Select what you are moving';
    if (_pickupController.text.trim().isEmpty) return 'Enter a pickup address';
    if (_dropoffController.text.trim().isEmpty) return 'Enter a drop-off address';
    if (_date == null) return 'Select a date';
    if (_time == null) return 'Select a time';
    return null;
  }

  DateTime? get _scheduledAt {
    if (_date == null || _time == null) return null;
    return DateTime(
      _date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute,
    );
  }

  Future<void> _submit() async {
    final missing = _firstMissingField();
    if (missing != null) {
      _showSnack(missing);
      return;
    }

    setState(() => _submitting = true);
    try {
      final weight = double.tryParse(_weightController.text.trim());
      final budget = double.tryParse(_budgetController.text.trim());
      final scheduled = _scheduledAt;
      final notes = _notesController.text.trim();
      final description = [
        if (scheduled != null) 'Requested for $_dateLabel at $_timeLabel.',
        if (notes.isNotEmpty) notes,
      ].join(' ');

      await ref.read(loadsApiProvider).createLoad(
            title: _goodsType!,
            goodsType: _goodsType!,
            pickupAddress: _pickupController.text.trim(),
            deliveryAddress: _dropoffController.text.trim(),
            description: description.isEmpty ? null : description,
            weight: weight,
            budgetAmount: budget,
            scheduledAt: scheduled,
          );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
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
        title: const Text('Post Load', style: AppTextStyles.headingMd),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _done ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 56),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Delivery scheduled', style: AppTextStyles.headingLg),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We\'ve received your request and will confirm the driver and '
              'price with you shortly. You can track it from your orders.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Done',
              icon: Icons.home_rounded,
              onPressed: () => context.go('/client'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        // Intro
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.warning.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available_rounded,
                  color: AppColors.warning, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Schedule a delivery ahead of time. We\'ll confirm the driver '
                  'and price with you before pickup.',
                  style: AppTextStyles.bodySm.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        _label('What are you moving?'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _goodsTypes.map(_buildGoodsChip).toList(),
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

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Weight (kg)'),
                  const SizedBox(height: AppSpacing.sm),
                  _textField(
                    controller: _weightController,
                    hint: 'Optional',
                    icon: Icons.scale_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Budget (₦)'),
                  const SizedBox(height: AppSpacing.sm),
                  _textField(
                    controller: _budgetController,
                    hint: 'Optional',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        _label('Extra details'),
        const SizedBox(height: AppSpacing.sm),
        _textField(
          controller: _notesController,
          hint: 'Anything the driver should know? (e.g. 50 bags, 3rd floor)',
          icon: Icons.notes_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.xxl),

        PrimaryButton(
          label: 'Schedule delivery',
          icon: Icons.send_rounded,
          isLoading: _submitting,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
      );

  Widget _buildGoodsChip(String type) {
    final selected = _goodsType == type;
    return GestureDetector(
      onTap: () => setState(() => _goodsType = type),
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
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
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
