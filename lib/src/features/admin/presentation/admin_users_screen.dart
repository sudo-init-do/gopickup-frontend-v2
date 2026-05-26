import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String? _selectedRole;
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final Set<String> _deletedIds = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredUsers(List<Map<String, dynamic>> users) {
    var filtered = users.where((u) => !_deletedIds.contains(u['id'])).toList();
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      filtered = filtered.where((u) {
        final email = (u['email'] ?? '').toString().toLowerCase();
        return email.contains(q);
      }).toList();
    }
    return filtered;
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _bulkApprove(List<Map<String, dynamic>> allUsers) async {
    setState(() => _isLoading = true);
    int successCount = 0;

    for (final id in _selectedIds) {
      final user = allUsers.firstWhere((u) => u['id'] == id, orElse: () => {});
      final role = user['role'] as String?;
      final isApproved = user['is_approved'] == true;

      if (role != null && !isApproved && (role == 'driver' || role == 'vendor')) {
        try {
          if (role == 'driver') {
            await ref.read(adminApiProvider).approveDriver(id);
          } else {
            await ref.read(adminApiProvider).approveVendor(id);
          }
          successCount++;
        } catch (_) {}
      }
    }

    setState(() {
      _isLoading = false;
      _selectedIds.clear();
    });

    if (context.mounted && successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully approved $successCount users'),
        backgroundColor: AppColors.success,
      ));
      ref.invalidate(adminUsersProvider);
      ref.invalidate(adminStatsProvider);
    }
  }

  Future<void> _confirmDeleteUser(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text(
          'Warning: Deleting this user will permanently erase their profile and all associated data from the system.',
          style: TextStyle(color: AppColors.destructive, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await ref.read(adminApiProvider).deleteUser(id);
        setState(() => _deletedIds.add(id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User permanently deleted'),
            backgroundColor: AppColors.success,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: AppColors.destructive,
          ));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider(_selectedRole));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ECOSYSTEM',
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('User Management', style: AppTextStyles.titleMd),
          ],
        ),
      ),
      body: usersAsync.when(
        data: (users) {
          final filtered = _getFilteredUsers(users);
          return Column(
            children: [
              // Search & Filters
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.borderStrong),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, or ID...',
                          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRoleTab('All', null),
                          const SizedBox(width: AppSpacing.sm),
                          _buildRoleTab('Clients', 'client'),
                          const SizedBox(width: AppSpacing.sm),
                          _buildRoleTab('Drivers', 'driver'),
                          const SizedBox(width: AppSpacing.sm),
                          _buildRoleTab('Vendors', 'vendor'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bulk Action Bar
              if (_selectedIds.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.adminAccent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: const Border(
                      left: BorderSide(color: AppColors.adminAccent, width: 4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.adminAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_selectedIds.length}',
                          style: AppTextStyles.label.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Text(
                          'Users selected from current view',
                          style: AppTextStyles.bodySm,
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.adminAccent,
                          ),
                        )
                      else ...[
                        TextButton(
                          onPressed: () => _bulkApprove(users),
                          child: Text(
                            'Bulk Approve',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.adminAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Bulk Deactivate',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.destructive,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _selectedIds.clear()),
                      ),
                    ],
                  ),
                ),

              // List Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 24), // Checkbox spacing
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        'USER IDENTITY',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      'ROLE',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Users List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
                      .copyWith(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: filtered.isEmpty
                            ? const AppEmptyState(
                                icon: Icons.people_outline,
                                title: 'No users found',
                                message: 'Try adjusting your search or role filter.',
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: AppColors.border,
                                ),
                                itemBuilder: (context, index) =>
                                    _buildUserRow(filtered[index]),
                              ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      // Pagination Footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filtered.length} ${filtered.length == 1 ? 'result' : 'results'}',
                              style: AppTextStyles.bodySm,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.chevron_left, color: AppColors.textTertiary),
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.adminAccent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '1',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Text('2', style: AppTextStyles.bodySm),
                                const SizedBox(width: AppSpacing.sm),
                                const Text('3', style: AppTextStyles.bodySm),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (e, stack) => AppErrorState(message: 'Error: $e'),
      ),
    );
  }

  /// A role filter tab. Tapping it sets [_selectedRole], which the build method
  /// passes to adminUsersProvider so the list re-fetches just that role
  /// (null = all users).
  Widget _buildRoleTab(String label, String? roleValue) {
    final isActive = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () {
        if (_selectedRole == roleValue) return;
        setState(() {
          _selectedRole = roleValue;
          _selectedIds.clear(); // selections don't carry across role views
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.adminAccent : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isActive ? AppColors.adminAccent : AppColors.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySm.copyWith(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    final id = user['id'] as String;
    final role = user['role'] as String;
    final email = user['email'] as String;
    final name = (user['full_name'] as String?) ?? email.split('@').first;
    final isSelected = _selectedIds.contains(id);

    // Role badge colors per design system spec
    Color badgeBg;
    Color badgeFg;
    if (role == 'driver') {
      badgeBg = AppColors.success.withOpacity(0.12);
      badgeFg = AppColors.success;
    } else if (role == 'vendor') {
      badgeBg = AppColors.vendorAccent.withOpacity(0.12);
      badgeFg = AppColors.vendorAccent;
    } else if (role == 'admin') {
      badgeBg = AppColors.adminAccent.withOpacity(0.12);
      badgeFg = AppColors.adminAccent;
    } else {
      // client
      badgeBg = AppColors.info.withOpacity(0.12);
      badgeFg = AppColors.info;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSelection(id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.adminAccent : AppColors.card,
                border: Border.all(
                  color: isSelected ? AppColors.adminAccent : AppColors.borderStrong,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          const CircleAvatar(
            backgroundColor: AppColors.backgroundSubtle,
            child: Icon(Icons.person, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.label),
                Text(email, style: AppTextStyles.bodySm),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      (user['vendor_profile']?['phone_number'] ??
                              user['client_profile']?['phone_number'] ??
                              user['driver_profile']?['phone_number'] ??
                              'No phone')
                          .toString(),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        (user['vendor_profile']?['address'] ??
                                user['client_profile']?['address'] ??
                                user['driver_profile']?['address'] ??
                                'No address')
                            .toString(),
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: badgeFg.withOpacity(0.3)),
            ),
            child: Text(
              role.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: badgeFg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.destructive, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _confirmDeleteUser(id),
          ),
        ],
      ),
    );
  }
}
