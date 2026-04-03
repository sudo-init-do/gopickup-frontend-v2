import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: March 2026',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1.1 Platform Description',
              'GO Pickup is a web and mobile application-based platform accessible at https://app.gopickup.com.ng/ which connects individuals or organizations requiring logistics and haulage services (“Senders”) with verified logistics professionals or vehicle owners (“Pilots”). Pilots can provide the following types of delivery services:\n'
              'On-Demand Jobs Delivery Service: Immediate or grouped order delivery.\n'
              'Scheduled Delivery Service: Future or recurring order delivery services.\n'
              'These services are collectively referred to as the “Services.”',
            ),
            _buildSection(
              '1.2 Operator',
              'The platform is operated by GO Pickup Logistics Ltd. (“GO Pickup”). Access to and use of the platform or any of its associated features is governed by these General Terms and Conditions (the “General Terms”), which may be updated from time to time. By using the Application or accepting the Terms, you agree to be bound by the General Terms and any applicable Additional Terms. If you disagree, you must discontinue use immediately.',
            ),
            _buildSection(
              '1.3 Additional Terms',
              'Some features may be governed by additional terms (“Additional Terms”). In the event of a conflict between General and Additional Terms, the Additional Terms will prevail.',
            ),
            _buildSection(
              '1.4 Changes to Terms',
              'GO Pickup reserves the right to amend these General and Additional Terms. Continued use after such changes constitutes acceptance.',
            ),
            _buildSection(
              '1.5 Privacy',
              'Personal data is handled per the GO Pickup Privacy Policy.',
            ),
            const Divider(height: 40),
            _buildSection(
              '2. ACCOUNT REGISTRATION',
              '2.1 Required Information\n'
              'To register an account (“Account”), you must provide:\n'
              '• Full name, phone number, email address, location\n'
              '• Username and password\n'
              '• Nigerian Identity Number (NIN)\n'
              '• For companies: CAC Registration Number\n'
              '• Vehicle type/model\n'
              '• Valid driver’s license\n\n'
              '2.2 Representation and Updates\n'
              'You agree that the information provided is accurate and will be updated as necessary.\n\n'
              '2.3 Communication Consent\n'
              'You consent to receive communications via SMS, email, phone, or in-app notifications related to service use.\n\n'
              '2.4 Eligibility\n'
              'You may not use the platform if you:\n'
              '• Are under legal contracting age\n'
              '• Are legally restricted from using the service\n\n'
              '2.5 User Warranties\n'
              'By registering, you warrant that:\n'
              '• You meet the legal age requirement\n'
              '• You’re authorized to act on behalf of your business (if applicable)\n'
              '• You possess the skills, licenses, and equipment to perform services\n'
              '• You comply with Nigerian law and GO Pickup standards',
            ),
            const Divider(height: 40),
            _buildSection(
              '3. RELATIONSHIP',
              '• GO Pickup is a facilitator and not a logistics provider.\n'
              '• Pilot are independent contractors, not employees.\n'
              '• GO Pickup does not provide delivery services directly.',
            ),
            const Divider(height: 40),
            _buildSection(
              '4. PERFORMANCE OF SERVICES',
              'Pilots must:\n'
              '• Deliver services lawfully, professionally, and diligently\n'
              '• Follow road safety and product-specific delivery rules\n'
              '• Enable GPS tracking during deliveries\n'
              '• Notify GO Pickup of delays, incidents, or dispute stage',
            ),
            const Divider(height: 40),
            _buildSection(
              '5. PILOT OBLIGATIONS',
              'Pilots must:\n'
              '• Maintain account confidentiality\n'
              '• Use the platform legally and ethically\n'
              '• Avoid impersonation or inappropriate conduct\n'
              '• Not reverse-engineer or exploit the platform\n'
              '• Avoid disparaging GO Pickup or its users',
            ),
            const Divider(height: 40),
            _buildSection(
              '6. INSURANCE',
              'Pilots must maintain:\n'
              '• Vehicle and third-party insurance\n'
              '• Workers compensation (if applicable)\n'
              '• Other relevant coverages as required by law',
            ),
            const Divider(height: 40),
            _buildSection(
              '7. RISK',
              'Pilots bear all risks associated with service delivery.',
            ),
            const Divider(height: 40),
            _buildSection(
              '8. VERIFICATION',
              'GO Pickup may verify your identity, vehicle registration, and other submitted information.',
            ),
            const Divider(height: 40),
            _buildSection(
              '9. EQUIPMENT & EXPENSES',
              'Pilots must supply and maintain their own vehicles and tools.',
            ),
            const Divider(height: 40),
            _buildSection(
              '10. INVOICING & PAYMENTS',
              '• GO Pickup acts as an agent to collect payments from Senders\n'
              '• Payouts to Pilots are processed within 48 hours of job completion\n'
              '• Tax invoices are issued by GO Pickup on behalf of the Pilot',
            ),
            const Divider(height: 40),
            _buildSection(
              '11. REVIEW AND RATING',
              '• Senders may rate Pilots as Good, Neutral, or Bad\n'
              '• Reviews affect visibility and credibility of Pilots on the platform\n'
              '• GO Pickup may moderate content based on its Review Policy',
            ),
            const Divider(height: 40),
            _buildSection(
              '12. GRANT OF LICENSE',
              'The Platform and its entire contents, features, and functionality (including but not limited to all information, software, text, displays, images, video and audio, and the design, selection, and arrangement thereof), are owned by us, our licensors or other providers of such material and are protected under Nigerian copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.\n'
              'These Terms permit you to use the Platform for your personal use only. You must not reproduce, decompile, reverse engineer, distribute, modify, create derivative works of, publicly display, republish, download, store or transmit any of the material on our Platform, without our written permission and/or the express, authorized written permission of the intellectual property right owner.',
            ),
            const Divider(height: 40),
            _buildSection(
              '13. NON-SOLICITATION',
              '• Pilots must not bypass the platform to work directly with Senders for 12 months after introduction',
            ),
            const Divider(height: 40),
            _buildSection(
              '14. USER CONTENT AND THIRD-PARTY LINKS',
              '• User content remains your responsibility\n'
              '• GO Pickup is not liable for third-party site content',
            ),
            const Divider(height: 40),
            _buildSection(
              '15. INTELLECTUAL PROPERTY',
              '• GO Pickup owns all intellectual property on the platform\n'
              '• Users are granted limited, non-transferable rights to use the platform',
            ),
            const Divider(height: 40),
            _buildSection(
              '16. GENERAL DISCLAIMER',
              'GO Pickup:\n'
              '• Provides the platform “as is”\n'
              '• Disclaims liability for indirect or consequential damages\n'
              '• Is not liable for user conduct or third-party content',
            ),
            const Divider(height: 40),
            _buildSection(
              '17. LIMITATION OF LIABILITY',
              '• Liability is limited to the most recent commission fee earned\n'
              '• GO Pickup is not liable for losses due to external events or force majeure',
            ),
            const Divider(height: 40),
            _buildSection(
              '18. INDEMNITY',
              'Pilots indemnify GO Pickup against claims arising from their actions or omissions, except where GO Pickup is directly at fault.',
            ),
            const Divider(height: 40),
            _buildSection(
              '19. DISPUTE RESOLUTION',
              '• Disputes must be reported in writing within 72 hours of delivery\n'
              '• GO Pickup may mediate and freeze accounts pending resolution\n'
              '• Legal proceedings can only commence after good-faith mediation efforts',
            ),
            const Divider(height: 40),
            _buildSection(
              '20. TERMINATION',
              '• Users may terminate by giving 2 weeks’ notice\n'
              '• GO Pickup may terminate accounts for breaches, inactivity, or at its discretion',
            ),
            const Divider(height: 40),
            _buildSection(
              '21. JURISDICTION AND VENUE',
              'Disputes shall be resolved exclusively in the courts of Abuja, Nigeria.',
            ),
            const Divider(height: 40),
            _buildSection(
              '22. GOVERNING LAW',
              'These Terms are governed by Nigerian law, with jurisdiction in Abuja.',
            ),
            const Divider(height: 40),
            _buildSection(
              '23. SEVERABILITY',
              'If any part of the Terms is found unenforceable, the rest remains valid.',
            ),
            const Divider(height: 40),
            _buildSection(
              '24. WAIVER',
              'No waiver is valid unless in writing.',
            ),
            const Divider(height: 40),
            _buildSection(
              '25. CONTACT INFORMATION',
              'You may reach GO Pickup at:\n📧 Email: support@gopickup.com',
            ),
            const Divider(height: 40),
            _buildSection(
              '26. ASSIGNMENT',
              '• GO Pickup may assign its rights to affiliates or successors\n'
              '• Pilots must obtain written consent before assigning their rights',
            ),
            const Divider(height: 40),
            _buildSection(
              '27. SUBCONTRACTORS',
              '• Subcontractors must register independently and be verified\n'
              '• Pilots remain fully liable for subcontractor actions',
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text('I Understand'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
