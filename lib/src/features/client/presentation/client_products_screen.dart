import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/constants/app_constants.dart';
import '../../../common/config/app_config.dart';
import '../../../models/product_models.dart';
import '../../../state/product_provider.dart';
import '../data/cart_provider.dart';

class ClientProductsScreen extends ConsumerStatefulWidget {
  final String? initialSearchQuery;
  const ClientProductsScreen({super.key, this.initialSearchQuery});

  @override
  ConsumerState<ClientProductsScreen> createState() =>
      _ClientProductsScreenState();
}

class _ClientProductsScreenState extends ConsumerState<ClientProductsScreen> {
  bool _hasAddress = false;
  bool _isInit = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? '';
    _searchController = TextEditingController(text: _searchQuery);

    _checkAddressStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).fetchProducts();
    });
  }

  Future<void> _checkAddressStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hasAddress = prefs.getBool('has_selected_address') ?? false;
        _isInit = false;
      });
    }
  }

  Future<void> _setAddressSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_address', true);
    if (mounted) {
      setState(() => _hasAddress = true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_hasAddress) {
      return _buildAddressSelection();
    }
    return _buildProductList(context);
  }

  Widget _buildAddressSelection() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location Icon in circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF3B7D23),
                  size: 40,
                ),
              ),
              const SizedBox(height: 40),
              // Heading
              const Text(
                'Where should we deliver?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subheading
              Text(
                'Enter your delivery address to see available\nproducts and shipping costs',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Text Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter delivery address',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Use this address button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _setAddressSelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.location_on_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Use this address',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Use current location button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _setAddressSelected,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F2937),
                    side: const BorderSide(color: Color(0xFFF3F4F6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Use current location',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return Builder(
      builder: (context) {
        final productState = ref.watch(productProvider);

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                // Custom App Bar (Keep as is)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 24),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('has_selected_address');
                            if (mounted) {
                              setState(() => _hasAddress = false);
                            }
                          },
                        ),
                      ),
                      const Text(
                        'Go-Market',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/client/cart'),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B7D23),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            if (ref.watch(cartProvider).isNotEmpty)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '${ref.watch(cartProvider).length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey[400],
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }
                                    _debounce = Timer(const Duration(milliseconds: 500), () {
                                      ref
                                          .read(productProvider.notifier)
                                          .fetchProducts(
                                            category: _selectedCategory == 'All'
                                                ? null
                                                : _selectedCategory,
                                            search: _searchQuery.isNotEmpty
                                                ? _searchQuery
                                                : null,
                                          );
                                    });
                                  },
                                  onSubmitted: (_) {
                                    ref
                                        .read(productProvider.notifier)
                                        .fetchProducts(
                                          category: _selectedCategory == 'All'
                                              ? null
                                              : _selectedCategory,
                                          search: _searchQuery.isNotEmpty
                                              ? _searchQuery
                                              : null,
                                        );
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 15,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _searchController.clear();
                                                _searchQuery = '';
                                              });
                                              ref
                                                  .read(
                                                    productProvider.notifier,
                                                  )
                                                  .fetchProducts(
                                                    category:
                                                        _selectedCategory ==
                                                            'All'
                                                        ? null
                                                        : _selectedCategory,
                                                  );
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF1F2937),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: AppConstants.productCategories.map((category) {
                      return _buildCategoryChip(
                        category,
                        _selectedCategory == category,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Product Grid
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (productState.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (productState.error != null) {
                        return Center(
                          child: Text('Error: ${productState.error}'),
                        );
                      }

                      final filteredProducts = productState.products;

                      if (filteredProducts.isEmpty) {
                        return const Center(child: Text('No products found'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: filteredProducts[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
        ref.read(productProvider.notifier).fetchProducts(
          category: label == 'All' ? null : label,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B7D23) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart[product.id];
    final isInCart = cartItem != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    image: product.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imageUrl.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.grey[300],
                          ),
                        )
                      : null,
                ),
              ),
              // Content Area
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.vendorName,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 10, color: Colors.blueAccent.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.vendorAddress,
                              style: TextStyle(
                                color: Colors.blueAccent.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF111827),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' (124)',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Price and Stock
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₦${product.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '/piece',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${product.stock} in',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const Text(
                                'stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Add Button or Quantity Selector
                      if (!isInCart)
                        GestureDetector(
                          onTap: () =>
                              ref.read(cartProvider.notifier).addItem(product),
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B7D23),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Add (1 min)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => ref
                                    .read(cartProvider.notifier)
                                    .removeItem(product.id),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 20,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(cartProvider.notifier)
                                    .addItem(product),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3B7D23),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // MOQ Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B7D23),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'MOQ: 1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
