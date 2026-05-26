import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully approved $successCount users'), backgroundColor: Colors.green));
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
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User permanently deleted'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete user: $e'), backgroundColor: Colors.red));
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ECOSYSTEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey.shade600)),
            const Text('User Management', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
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
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 44,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, or ID...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRoleTab('All', null),
                          const SizedBox(width: 8),
                          _buildRoleTab('Clients', 'client'),
                          const SizedBox(width: 8),
                          _buildRoleTab('Drivers', 'driver'),
                          const SizedBox(width: 8),
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(left: BorderSide(color: Colors.indigoAccent, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(4)),
                        child: Text('${_selectedIds.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Users selected from current view', style: TextStyle(fontSize: 12, color: Colors.black87))),
                      if (_isLoading)
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      else ...[
                        TextButton(
                          onPressed: () => _bulkApprove(users),
                          child: const Text('Bulk Approve', style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Bulk Deactivate', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 24), // Checkbox spacing
                    SizedBox(width: 16),
                    Expanded(child: Text('USER IDENTITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                    Text('ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ),

              // Users List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people_outline, size: 40, color: Colors.grey.shade300),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No users found',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) => _buildUserRow(filtered[index]),
                              ),
                      ),
                      const Divider(height: 1),
                      // Pagination Footer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filtered.length} ${filtered.length == 1 ? 'result' : 'results'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.chevron_left, color: Colors.grey),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                const Text('2', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 8),
                                const Text('3', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, color: Colors.black87),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
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
          color: isActive ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.indigo : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontSize: 13,
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

    Color badgeColor = Colors.blueAccent;
    Color badgeText = Colors.blue;
    if (role == 'driver') {
      badgeColor = Colors.greenAccent;
      badgeText = Colors.green.shade700;
    } else if (role == 'vendor') {
      badgeColor = Colors.purpleAccent;
      badgeText = Colors.purple;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSelection(id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo : Colors.white,
                border: Border.all(color: isSelected ? Colors.indigo : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      (user['vendor_profile']?['phone_number'] ?? user['client_profile']?['phone_number'] ?? user['driver_profile']?['phone_number'] ?? 'No phone').toString(),
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        (user['vendor_profile']?['address'] ?? user['client_profile']?['address'] ?? user['driver_profile']?['address'] ?? 'No address').toString(),
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor.withOpacity(0.3)),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(color: badgeText, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _confirmDeleteUser(id),
          ),
        ],
      ),
    );
  }
}
