import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../data/vendor_repository.dart';
import '../../../common/utils/error_handler.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  int _moq = 1;

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  String _selectedCategory = 'Cement';
  final List<String> _categories = [
    'Cement',
    'Steel',
    'Wood',
    'Paint',
    'Electrical',
    'Quarry Materials',
    'Plumbing',
    'Hardware',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF64748B);
    const kLightBorderColor = Color(0xFFF1F5F9);
    const kBrandGreen = Color(0xFF45A225);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: kDarkTextColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: kDarkTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Product Images', kDarkTextColor),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    final bytes = await pickedFile.readAsBytes();
                    setState(() {
                      _selectedImage = pickedFile;
                      _imageBytes = bytes;
                    });
                  }
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  image: _imageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_imageBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Color(0xFF94A3B8), size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: kMidTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('Product Name', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField(_nameController, 'Enter product name'),
            const SizedBox(height: 32),

            _buildSectionLabel('Description', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField(
              _descriptionController,
              'Describe your product...',
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('Category', kDarkTextColor),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFA855F7)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kMidTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Price (₦)', kDarkTextColor),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _priceController,
                        '0.00',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Stock', kDarkTextColor),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _stockController,
                        '0',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('Minimum Order Quantity (MOQ)', kDarkTextColor),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_moq',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kDarkTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            setState(() => _moq = _moq > 1 ? _moq - 1 : 1),
                        icon: const Icon(Icons.remove, size: 20),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _moq++),
                        icon: const Icon(Icons.add, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customers must order at least this quantity',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kLightBorderColor)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final desc = _descriptionController.text.trim();
                final price = double.tryParse(_priceController.text) ?? 0;
                final stock = int.tryParse(_stockController.text) ?? 0;

                if (name.isEmpty || price <= 0 || stock <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                    ),
                  );
                  return;
                }

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                String? imageUrl;
                if (_imageBytes != null) {
                  final fileName = _selectedImage!.name;
                  imageUrl = await ref
                      .read(vendorRepositoryProvider)
                      .uploadProductImage(_imageBytes!, fileName);
                  
                  if (imageUrl == null && context.mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to upload image. Please check your connection.'),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                }

                final (success, error) = await ref
                    .read(vendorRepositoryProvider)
                    .addProduct(
                      name: name,
                      description: desc,
                      category: _selectedCategory,
                      price: price,
                      stock: stock,
                      moq: _moq,
                      imageUrl: imageUrl,
                    );

                if (context.mounted) {
                   Navigator.pop(context); // Close loading

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product added successfully!'),
                        backgroundColor: Color(0xFF45A225),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ErrorHandler.getMessage(error)),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Add Product',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
