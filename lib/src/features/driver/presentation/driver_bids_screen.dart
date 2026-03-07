import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/job_repository.dart';

class DriverBidsScreen extends ConsumerStatefulWidget {
  const DriverBidsScreen({super.key});

  @override
  ConsumerState<DriverBidsScreen> createState() => _DriverBidsScreenState();
}

class _DriverBidsScreenState extends ConsumerState<DriverBidsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kOrangeColor = Color(0xFFF97316);
    const kRedColor = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(kDarkTextColor, kMidTextColor),
            _buildTabs(
              _selectedTabIndex,
              (index) => setState(() => _selectedTabIndex = index),
              kOrangeColor,
            ),
            Expanded(
              child: _buildBidsList(
                kDarkTextColor,
                kMidTextColor,
                kOrangeColor,
                kRedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color darkText, Color midText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bids & Negotiations',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: darkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your job bids',
            style: TextStyle(
              fontSize: 16,
              color: midText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(int selectedIndex, Function(int) onSelect, Color orange) {
    final tabs = ['My Bids', 'Won', 'Lost'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: index == tabs.length - 1 ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? orange : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBidsList(
    Color darkText,
    Color midText,
    Color orange,
    Color red,
  ) {
    final driverBidsAsync = ref.watch(driverBidsProvider);

    return driverBidsAsync.when(
      data: (bids) {
        // Filter bids by status based on the selected tab
        // Tab 0: My Bids (pending)
        // Tab 1: Won (accepted)
        // Tab 2: Lost (rejected/archived)
        List<dynamic> filteredBids = [];
        if (_selectedTabIndex == 0) {
          filteredBids = bids
              .where((b) => b['status'] == 'pending' || b['status'] == null)
              .toList();
        } else if (_selectedTabIndex == 1) {
          filteredBids = bids.where((b) => b['status'] == 'accepted').toList();
        } else {
          filteredBids = bids.where((b) => b['status'] == 'rejected').toList();
        }

        if (filteredBids.isEmpty) {
          return Center(
            child: Text(
              'No bids here yet',
              style: TextStyle(
                color: midText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          itemCount: filteredBids.length,
          itemBuilder: (context, index) {
            final bid = filteredBids[index] as Map<String, dynamic>;

            // Format data appropriately for _buildBidCard
            final displayBid = {
              'title': bid['title'] ?? 'Load Delivery',
              'time': bid['created_at'] != null ? 'Recently' : 'Now',
              'status': bid['status'] ?? 'Pending',
              'from': bid['pickup_address'] ?? 'Pickup Location',
              'to': bid['delivery_address'] ?? 'Destination Location',
              'yourBid': bid['amount'] != null ? '₦${bid['amount']}' : '₦0',
              'budget': bid['budget'] ?? 'Flexible',
            };

            return _buildBidCard(displayBid, darkText, midText, orange, red);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Failed to load bids', style: TextStyle(color: midText)),
      ),
    );
  }

  Widget _buildBidCard(
    Map<String, dynamic> bid,
    Color darkText,
    Color midText,
    Color orange,
    Color red,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bid['title'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bid['time'],
                    style: TextStyle(
                      fontSize: 14,
                      color: midText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bid['status'],
                  style: TextStyle(
                    color: orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLocationRow(
            Icons.location_on_outlined,
            bid['from'],
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on_outlined, bid['to'], Colors.red),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your bid',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bid['yourBid'],
                    style: TextStyle(
                      color: darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Budget range',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bid['budget'],
                    style: TextStyle(
                      color: midText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Edit Bid',
                    style: TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
