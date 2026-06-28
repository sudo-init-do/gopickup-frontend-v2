import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_spacing.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../common/utils/location_service.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../state/load_provider.dart';

/// Step 1 of the live "Book Driver" flow: the client describes the trip and we
/// create an open Load. Drivers then bid on it (step 2: matching).
class BookDriverRequestScreen extends ConsumerStatefulWidget {
  const BookDriverRequestScreen({super.key});

  @override
  ConsumerState<BookDriverRequestScreen> createState() =>
      _BookDriverRequestScreenState();
}

class _BookDriverRequestScreenState
    extends ConsumerState<BookDriverRequestScreen> {
  static const List<String> _goodsTypes = [
    'Parcel',
    'Cement',
    'Sand / Gravel',
    'Blocks',
    'Furniture',
    'Equipment',
    'Other',
  ];

  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _budgetController = TextEditingController();

  String? _goodsType;
  double? _pickupLat;
  double? _pickupLng;
  bool _locating = false;
  bool _submitting = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final pos = await LocationService.currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (pos == null) {
      _showSnack(
        'Couldn\'t get your location. Please type the pickup address.',
      );
      return;
    }
    setState(() {
      _pickupLat = pos.latitude;
      _pickupLng = pos.longitude;
      if (_pickupController.text.trim().isEmpty) {
        _pickupController.text = 'My current location '
            '(${pos.latitude.toStringAsFixed(4)}, '
            '${pos.longitude.toStringAsFixed(4)})';
      }
    });
  }

  String? _firstMissingField() {
    if (_goodsType == null) return 'Select what you are sending';
    if (_pickupController.text.trim().isEmpty) return 'Enter a pickup address';
    if (_dropoffController.text.trim().isEmpty) return 'Enter a drop-off address';
    return null;
  }

  Future<void> _submit() async {
    final missing = _firstMissingField();
    if (missing != null) {
      _showSnack(missing);
      return;
    }
    setState(() => _submitting = true);
    try {
      final load = await ref.read(loadsApiProvider).createLoad(
            title: _goodsType!,
            goodsType: _goodsType!,
            pickupAddress: _pickupController.text.trim(),
            deliveryAddress: _dropoffController.text.trim(),
            budgetAmount: double.tryParse(_budgetController.text.trim()),
            pickupLat: _pickupLat,
            pickupLng: _pickupLng,
          );
      if (mounted) {
        context.pushReplacement('/client/book-driver/matching', extra: load.id);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
        setState(() => _submitting = false);
      }
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
        title: const Text('Book Driver', style: AppTextStyles.headingMd),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.vendorAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border:
                    Border.all(color: AppColors.vendorAccent.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.vendorAccent, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Request a driver now. Nearby drivers will send you offers '
                      'in real time — accept one and track them live.',
                      style: AppTextStyles.bodySm.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('What are you sending?'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _goodsTypes.map(_buildChip).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Pickup'),
                TextButton.icon(
                  onPressed: _locating ? null : _useCurrentLocation,
                  icon: _locating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 16),
                  label: Text(_pickupLat != null
                      ? 'Location set'
                      : 'Use my location'),
                  style: TextButton.styleFrom(
                    foregroundColor: _pickupLat != null
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _textField(
              controller: _pickupController,
              hint: 'Pickup address',
              icon: Icons.trip_origin_rounded,
              onChanged: (_) {
                // Typing a new address invalidates the GPS pin.
                if (_pickupLat != null) {
                  setState(() {
                    _pickupLat = null;
                    _pickupLng = null;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('Drop-off'),
            const SizedBox(height: AppSpacing.sm),
            _textField(
              controller: _dropoffController,
              hint: 'Drop-off address',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSpacing.xl),

            _label('Your budget (₦)'),
            const SizedBox(height: AppSpacing.sm),
            _textField(
              controller: _budgetController,
              hint: 'Optional — helps drivers price the trip',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.xxl),

            PrimaryButton(
              label: 'Find a driver',
              icon: Icons.search_rounded,
              isLoading: _submitting,
              color: AppColors.vendorAccent,
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

  Widget _buildChip(String type) {
    final selected = _goodsType == type;
    return GestureDetector(
      onTap: () => setState(() => _goodsType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.vendorAccent : AppColors.card,
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
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
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
}
