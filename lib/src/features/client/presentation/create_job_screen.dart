import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../state/load_provider.dart';
import 'shared/load_form_fields.dart';

/// "Post Load" — lets a client schedule a delivery. The request is saved to the
/// backend as an open Load that the GoPickup team confirms manually (and that
/// drivers can bid on). Scheduled counterpart to the live "Book Driver" flow.
class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _pickupCity = TextEditingController();
  final _pickupPin = TextEditingController();
  final _dropoffCity = TextEditingController();
  final _dropoffPin = TextEditingController();
  final _weightController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  String? _goodsType;
  String? _equipment;
  String _loadReq = 'full';
  String? _pickupState;
  String? _dropoffState;
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;
  bool _done = false;

  @override
  void dispose() {
    _pickupCity.dispose();
    _pickupPin.dispose();
    _dropoffCity.dispose();
    _dropoffPin.dispose();
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
    if (_equipment == null) return 'Select an equipment type';
    if (_pickupCity.text.trim().isEmpty || _pickupState == null) {
      return 'Enter pickup city and state';
    }
    if (_dropoffCity.text.trim().isEmpty || _dropoffState == null) {
      return 'Enter drop-off city and state';
    }
    if (_date == null) return 'Select a date';
    if (_time == null) return 'Select a time';
    return null;
  }

  DateTime? get _scheduledAt {
    if (_date == null || _time == null) return null;
    return DateTime(
        _date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
  }

  Future<void> _submit() async {
    final missing = _firstMissingField();
    if (missing != null) {
      _showSnack(missing);
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(loadsApiProvider).createLoad(
            title: _goodsType!,
            goodsType: _goodsType!,
            equipmentType: _equipment,
            loadRequirement: _loadReq,
            pickupAddress: '${_pickupCity.text.trim()}, $_pickupState',
            deliveryAddress: '${_dropoffCity.text.trim()}, $_dropoffState',
            pickupPin: _pickupPin.text.trim(),
            dropoffPin: _dropoffPin.text.trim(),
            weight: double.tryParse(_weightController.text.trim()),
            budgetAmount: double.tryParse(_budgetController.text.trim()),
            scheduledAt: _scheduledAt,
            description: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) _showSnack(e.toString().replaceFirst('Exception: ', ''));
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
      body: SafeArea(child: _done ? _buildSuccess() : _buildForm()),
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
                  shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 56),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Delivery scheduled', style: AppTextStyles.headingLg),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We\'ve received your request and will confirm the driver and '
              'price with you shortly. Watch your notifications for updates.',
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

        fieldLabel('What are you moving?'),
        const SizedBox(height: AppSpacing.sm),
        ChipSelector(
          options: kGoodsTypes,
          selected: _goodsType,
          onSelected: (v) => setState(() => _goodsType = v),
        ),
        const SizedBox(height: AppSpacing.xl),

        fieldLabel('Equipment type'),
        const SizedBox(height: AppSpacing.sm),
        ChipSelector(
          options: kEquipmentTypes,
          selected: _equipment,
          onSelected: (v) => setState(() => _equipment = v),
        ),
        const SizedBox(height: AppSpacing.xl),

        fieldLabel('Load requirement'),
        const SizedBox(height: AppSpacing.sm),
        LoadRequirementSelector(
          selectedKey: _loadReq,
          onSelected: (v) => setState(() => _loadReq = v),
        ),
        const SizedBox(height: AppSpacing.xl),

        CityStateLocation(
          title: 'Pickup',
          icon: Icons.trip_origin_rounded,
          iconColor: AppColors.primary,
          cityController: _pickupCity,
          state: _pickupState,
          onStateChanged: (v) => setState(() => _pickupState = v),
          pinController: _pickupPin,
        ),
        const SizedBox(height: AppSpacing.xl),

        CityStateLocation(
          title: 'Drop-off',
          icon: Icons.location_on_outlined,
          iconColor: AppColors.destructive,
          cityController: _dropoffCity,
          state: _dropoffState,
          onStateChanged: (v) => setState(() => _dropoffState = v),
          pinController: _dropoffPin,
        ),
        const SizedBox(height: AppSpacing.xl),

        fieldLabel('When do you need it?'),
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
                  fieldLabel('Weight (kg)'),
                  const SizedBox(height: AppSpacing.sm),
                  _simpleField(
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
                  fieldLabel('Budget (₦)'),
                  const SizedBox(height: AppSpacing.sm),
                  _simpleField(
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

        fieldLabel('Extra details'),
        const SizedBox(height: AppSpacing.sm),
        _simpleField(
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

  Widget _simpleField({
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
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
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
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
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
