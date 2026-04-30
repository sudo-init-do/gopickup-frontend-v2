import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientAddressesScreen extends StatelessWidget {
  const ClientAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF64748B);
    const kBrandGreen = Color(0xFF3B7D23);

    final List<Map<String, String>> addresses = [
      {
        'label': 'Home',
        'address': '24, Victoria Island, Lagos, Nigeria',
        'type': 'home',
      },
      {
        'label': 'Office',
        'address': '102, Herbert Macaulay Way, Yaba, Lagos',
        'type': 'work',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: kDarkTextColor),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF9FAFB),
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: const Text(
          'Saved Addresses',
          style: TextStyle(
            color: kDarkTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity( 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBrandGreen.withOpacity( 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          addr['type'] == 'home'
                              ? Icons.home_outlined
                              : Icons.work_outline,
                          color: kBrandGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addr['label']!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: kDarkTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addr['address']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: kMidTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFFCBD5E1)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  // Show add address dialog or navigate
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded),
                    SizedBox(width: 8),
                    Text(
                      'Add New Address',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
