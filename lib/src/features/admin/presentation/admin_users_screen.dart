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

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider(_selectedRole));
    final isMobile = MediaQuery.of(context).size.width < 768;
    final padding = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: isMobile ? 22 : null,
                  ),
            ),
            const SizedBox(height: 16),

            // Filter Tabs - scrollable on mobile
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterTab(label: 'All', isSelected: _selectedRole == null, onTap: () => setState(() => _selectedRole = null)),
                  _FilterTab(label: 'Clients', isSelected: _selectedRole == 'client', onTap: () => setState(() => _selectedRole = 'client')),
                  _FilterTab(label: 'Drivers', isSelected: _selectedRole == 'driver', onTap: () => setState(() => _selectedRole = 'driver')),
                  _FilterTab(label: 'Vendors', isSelected: _selectedRole == 'vendor', onTap: () => setState(() => _selectedRole = 'vendor')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User List
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: usersAsync.when(
                data: (users) {
                  if (users.isEmpty) return _buildEmptyState();

                  if (isMobile) {
                    // Mobile: Card-based list
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => _buildUserCard(context, users[index]),
                    );
                  }

                  // Desktop: DataTable
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: users.map((user) => _buildUserRow(context, user)).toList(),
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()),
                ),
                error: (e, stack) => Center(
                  child: Padding(padding: const EdgeInsets.all(40.0), child: Text('Error: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final role = user['role'] as String;
    final email = user['email'] as String;
    final id = user['id'] as String;
    final bool isApproved = user['is_approved'] ?? true;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: 20,
                child: const Icon(Icons.person, size: 22, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRoleBadge(role),
                        const SizedBox(width: 8),
                        if (role != 'client') _buildStatusBadge(role, isApproved),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_shouldShowApprove(role, isApproved)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _approveUser(id, role),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  DataRow _buildUserRow(BuildContext context, Map<String, dynamic> user) {
    final role = user['role'] as String;
    final email = user['email'] as String;
    final id = user['id'] as String;
    final bool isApproved = user['is_approved'] ?? true;

    return DataRow(
      cells: [
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: 16,
              child: const Icon(Icons.person, size: 20, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(email.split('@').first),
          ],
        )),
        DataCell(Text(email)),
        DataCell(_buildRoleBadge(role)),
        DataCell(_buildStatusBadge(role, isApproved)),
        DataCell(
          _shouldShowApprove(role, isApproved)
              ? ElevatedButton(
                  onPressed: () => _approveUser(id, role),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Approve'),
                )
              : const Text('-'),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getRoleColor(role)),
      ),
    );
  }

  Widget _buildStatusBadge(String role, bool isApproved) {
    if (role == 'client') return const Text('N/A', style: TextStyle(color: Colors.grey));
    final color = isApproved ? Colors.green : Colors.amber;
    final label = isApproved ? 'APPROVED' : 'PENDING';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  bool _shouldShowApprove(String role, bool isApproved) {
    return (role == 'driver' || role == 'vendor') && !isApproved;
  }

  Future<void> _approveUser(String userId, String role) async {
    try {
      if (role == 'driver') {
        await ref.read(adminApiProvider).approveDriver(userId);
      } else {
        await ref.read(adminApiProvider).approveVendor(userId);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${role.toUpperCase()} approved!'), backgroundColor: Colors.green),
      );
      ref.invalidate(adminUsersProvider);
      ref.invalidate(adminStatsProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'client': return Colors.blue;
      case 'driver': return Colors.green;
      case 'vendor': return Colors.orange;
      case 'admin': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(60.0),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No users found', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? Colors.black87 : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
