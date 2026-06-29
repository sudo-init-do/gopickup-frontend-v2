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
import '../shared/load_form_fields.dart';

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
  final _pickupCity = TextEditingController();
  final _pickupPin = TextEditingController();
  final _dropoffCity = TextEditingController();
  final _dropoffPin = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  String? _goodsType;
  String? _equipment;
  String _loadReq = 'full';
  String? _pickupState;
  String? _dropoffState;
  double? _pickupLat;
  double? _pickupLng;
  bool _locating = false;
  bool _submitting = false;

  @override
  void dispose() {
    _pickupCity.dispose();
    _pickupPin.dispose();
    _dropoffCity.dispose();
    _dropoffPin.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final pos = await LocationService.currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (pos == null) {
      _showSnack('Couldn\'t get your location. Please type the address + pin.');
      return;
    }
    setState(() {
      _pickupLat = pos.latitude;
      _pickupLng = pos.longitude;
      // Fill the pickup pin with a tappable Google Maps link for the driver.
      _pickupPin.text =
          'https://www.google.com/maps?q=${pos.latitude},${pos.longitude}';
    });
    _showSnack('Pickup location pinned.');
  }

  String? _firstMissingField() {
    if (_goodsType == null) return 'Select what you are sending';
    if (_equipment == null) return 'Select an equipment type';
    if (_pickupCity.text.trim().isEmpty || _pickupState == null) {
      return 'Enter pickup city and state';
    }
    if (_dropoffCity.text.trim().isEmpty || _dropoffState == null) {
      return 'Enter drop-off city and state';
    }
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
            equipmentType: _equipment,
            loadRequirement: _loadReq,
            pickupAddress: '${_pickupCity.text.trim()}, $_pickupState',
            deliveryAddress: '${_dropoffCity.text.trim()}, $_dropoffState',
            budgetAmount: double.tryParse(_budgetController.text.trim()),
            pickupLat: _pickupLat,
            pickupLng: _pickupLng,
            pickupPin: _pickupPin.text.trim(),
            dropoffPin: _dropoffPin.text.trim(),
            description: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
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
                      'Request a driver now. Nearby drivers send you offers in '
                      'real time — accept one and track them live.',
                      style: AppTextStyles.bodySm.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            fieldLabel('What are you sending?'),
            const SizedBox(height: AppSpacing.sm),
            ChipSelector(
              options: kGoodsTypes,
              selected: _goodsType,
              accent: AppColors.vendorAccent,
              onSelected: (v) => setState(() => _goodsType = v),
            ),
            const SizedBox(height: AppSpacing.xl),

            fieldLabel('Equipment type'),
            const SizedBox(height: AppSpacing.sm),
            ChipSelector(
              options: kEquipmentTypes,
              selected: _equipment,
              accent: AppColors.vendorAccent,
              onSelected: (v) => setState(() => _equipment = v),
            ),
            const SizedBox(height: AppSpacing.xl),

            fieldLabel('Load requirement'),
            const SizedBox(height: AppSpacing.sm),
            LoadRequirementSelector(
              selectedKey: _loadReq,
              accent: AppColors.vendorAccent,
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
              trailing: TextButton.icon(
                onPressed: _locating ? null : _useCurrentLocation,
                icon: _locating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location_rounded, size: 16),
                label: Text(_pickupLat != null ? 'Pinned' : 'Use my location'),
                style: TextButton.styleFrom(
                  foregroundColor:
                      _pickupLat != null ? AppColors.success : AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
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

            fieldLabel('Your budget (₦)'),
            const SizedBox(height: AppSpacing.sm),
            _simpleField(
              controller: _budgetController,
              hint: 'Optional — helps drivers price the trip',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.xl),

            fieldLabel('Extra details'),
            const SizedBox(height: AppSpacing.sm),
            _simpleField(
              controller: _notesController,
              hint: 'Anything the driver should know? (e.g. 20 bags, call on arrival)',
              icon: Icons.notes_rounded,
              maxLines: 3,
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

  Widget _simpleField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
}
