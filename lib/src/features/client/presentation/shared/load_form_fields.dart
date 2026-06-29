import 'package:flutter/material.dart';
import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_spacing.dart';
import '../../../../common/styles/app_text_styles.dart';

/// Shared constants + reusable field widgets for the Post Load and Book Driver
/// forms (equipment type, load requirement, and a city/state + map-pin location
/// section). Keeping them here keeps both screens consistent.

/// Our own equipment list (used to match a request with drivers who run that
/// vehicle). Deliberately Nigeria-oriented rather than DAT's US trailer types.
const List<String> kEquipmentTypes = [
  'Truck',
  'Van',
  'Pickup / Hilux',
  'Tricycle',
  'Bike',
];

const List<String> kGoodsTypes = [
  'Parcel',
  'Cement',
  'Sand / Gravel',
  'Blocks',
  'Furniture',
  'Equipment',
  'Food items',
  'Other',
];

/// Load requirement — our simplified take on DAT's "Full / Partial / All".
/// Value stored on the backend is the lowercase key.
const Map<String, String> kLoadRequirements = {
  'full': 'Full Load',
  'partial': 'Partial Load',
};

const List<String> kNigerianStates = [
  'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue',
  'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu',
  'FCT (Abuja)', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina',
  'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo',
  'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
];

Widget fieldLabel(String text) => Text(
      text,
      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
    );

/// A horizontal wrap of selectable pill chips.
class ChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;
  final Color accent;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((o) {
        final isSel = selected == o;
        return GestureDetector(
          onTap: () => onSelected(o),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isSel ? accent : AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isSel ? Colors.transparent : AppColors.border,
              ),
            ),
            child: Text(
              o,
              style: AppTextStyles.label.copyWith(
                color: isSel ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Full Load / Partial Load segmented selector.
class LoadRequirementSelector extends StatelessWidget {
  final String? selectedKey;
  final ValueChanged<String> onSelected;
  final Color accent;

  const LoadRequirementSelector({
    super.key,
    required this.selectedKey,
    required this.onSelected,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: kLoadRequirements.entries.map((e) {
        final isSel = selectedKey == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(e.key),
            child: Container(
              margin: EdgeInsets.only(
                  right: e.key == kLoadRequirements.keys.first ? AppSpacing.md : 0),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSel ? accent.withOpacity(0.12) : AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: isSel ? accent : AppColors.border,
                    width: isSel ? 1.5 : 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSel
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: isSel ? accent : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(e.value,
                      style: AppTextStyles.label.copyWith(
                          color: isSel ? accent : AppColors.textSecondary,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// City text field + State dropdown + optional Google pin/plus-code field.
/// The parent owns the controllers and the selected state.
class CityStateLocation extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final TextEditingController cityController;
  final String? state;
  final ValueChanged<String?> onStateChanged;
  final TextEditingController pinController;
  final Widget? trailing; // e.g. "Use my location" button

  const CityStateLocation({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.cityController,
    required this.state,
    required this.onStateChanged,
    required this.pinController,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            fieldLabel(title),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _box(
                child: TextField(
                  controller: cityController,
                  style: AppTextStyles.body,
                  decoration: _inputDec('City (e.g. Ikeja)'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: _box(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state,
                    isExpanded: true,
                    hint: Text('State',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textTertiary)),
                    items: kNigerianStates
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySm),
                            ))
                        .toList(),
                    onChanged: onStateChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _box(
          child: TextField(
            controller: pinController,
            style: AppTextStyles.bodySm,
            decoration: _inputDec(
              'Paste Google Maps pin or Plus code (optional)',
              prefix: Icons.pin_drop_outlined,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Helps the driver navigate to the exact spot.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _box({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );

  InputDecoration _inputDec(String hint, {IconData? prefix}) => InputDecoration(
        hintText: hint,
        isDense: true,
        hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
        prefixIcon: prefix != null
            ? Icon(prefix, size: 18, color: AppColors.textTertiary)
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 28, minHeight: 0),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      );
}
