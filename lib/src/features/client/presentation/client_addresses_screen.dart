import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';

class ClientAddressesScreen extends StatefulWidget {
  const ClientAddressesScreen({super.key});

  @override
  State<ClientAddressesScreen> createState() => _ClientAddressesScreenState();
}

class _ClientAddressesScreenState extends State<ClientAddressesScreen> {
  static const _prefsKey = 'saved_addresses';

  List<Map<String, String>> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final list = raw == null
        ? <Map<String, String>>[]
        : (jsonDecode(raw) as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
    if (mounted) {
      setState(() {
        _addresses = list;
        _loading = false;
      });
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_addresses));
  }

  Future<void> _addAddress() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddAddressSheet(),
    );
    if (result != null) {
      setState(() => _addresses.add(result));
      await _persist();
    }
  }

  Future<void> _deleteAddress(int index) async {
    setState(() => _addresses.removeAt(index));
    await _persist();
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'work':
        return Icons.work_outline;
      case 'other':
        return Icons.location_on_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.background,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'Saved Addresses',
          style: AppTextStyles.headingLg.copyWith(fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _addresses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          final addr = _addresses[index];
                          return _buildAddressCard(addr, index);
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: PrimaryButton(
              label: 'Add New Address',
              icon: Icons.add_rounded,
              height: 64,
              onPressed: _addAddress,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'No saved addresses yet',
              style: AppTextStyles.headingMd,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add an address to speed up checkout and delivery.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, String> addr, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(addr['type'] ?? 'home'),
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addr['label'] ?? '',
                  style: AppTextStyles.titleMd.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(addr['address'] ?? '', style: AppTextStyles.body),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.borderStrong),
            onSelected: (value) {
              if (value == 'delete') _deleteAddress(index);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        color: AppColors.destructive, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet form for adding a new address. Returns
/// `{label, address, type}` via Navigator.pop, or null if cancelled.
class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  static const _typeOptions = [
    {'type': 'home', 'label': 'Home'},
    {'type': 'work', 'label': 'Office'},
    {'type': 'other', 'label': 'Other'},
  ];

  final _addressController = TextEditingController();
  String _type = 'home';
  String _label = 'Home';
  bool _showError = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (_addressController.text.trim().isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.pop(context, {
      'label': _label,
      'address': _addressController.text.trim(),
      'type': _type,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Add New Address', style: AppTextStyles.headingLg.copyWith(fontSize: 22)),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'LABEL',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _typeOptions.map((opt) {
                final selected = _type == opt['type'];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _type = opt['type']!;
                      _label = opt['label']!;
                    }),
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
                        opt['label']!,
                        style: AppTextStyles.label.copyWith(
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'ADDRESS',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressController,
              maxLines: 2,
              autofocus: true,
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Street, area, city',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.location_on_outlined,
                    color: AppColors.textTertiary, size: 22),
                filled: true,
                fillColor: AppColors.backgroundSubtle,
                errorText: _showError ? 'Please enter an address' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Save Address',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
