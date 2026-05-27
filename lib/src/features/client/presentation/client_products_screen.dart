import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/constants/app_constants.dart';
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
      return const Scaffold(body: AppLoading());
    }
    if (!_hasAddress) {
      return _buildAddressSelection();
    }
    return _buildProductList(context);
  }

  Widget _buildAddressSelection() {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location Icon in circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Heading
              Text(
                'Where should we deliver?',
                style: AppTextStyles.displayLg.copyWith(
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Subheading
              Text(
                'Enter your delivery address to see available\nproducts and shipping costs',
                style: AppTextStyles.body.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Text Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter delivery address',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Use this address button
              PrimaryButton(
                label: 'Use this address',
                onPressed: _setAddressSelected,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Use current location button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _setAddressSelected,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    'Use current location',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
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
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
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
                      Text(
                        'Go-Market',
                        style: AppTextStyles.headingLg.copyWith(fontSize: 22),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/client/cart'),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
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
                                  padding: const EdgeInsets.all(AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.destructive,
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
                                    style: AppTextStyles.caption.copyWith(
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: AppColors.textTertiary,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.md),
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
                                    _debounce = Timer(
                                      const Duration(milliseconds: 500),
                                      () {
                                        ref
                                            .read(productProvider.notifier)
                                            .fetchProducts(
                                              category:
                                                  _selectedCategory == 'All'
                                                      ? null
                                                      : _selectedCategory,
                                              search: _searchQuery.isNotEmpty
                                                  ? _searchQuery
                                                  : null,
                                            );
                                      },
                                    );
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
                                    hintStyle: AppTextStyles.body.copyWith(
                                      color: AppColors.textTertiary,
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
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    children: AppConstants.productCategories.map((category) {
                      return _buildCategoryChip(
                        category,
                        _selectedCategory == category,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Product Grid
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (productState.isLoading) {
                        return const AppLoading();
                      }
                      if (productState.error != null) {
                        return AppErrorState(
                          message: productState.error ?? 'Unknown error',
                          onRetry: () => ref
                              .read(productProvider.notifier)
                              .fetchProducts(),
                        );
                      }

                      final filteredProducts = productState.products;

                      if (filteredProducts.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No products found',
                          message: 'Try adjusting your search or category',
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: AppSpacing.lg,
                              mainAxisSpacing: AppSpacing.lg,
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
        margin: const EdgeInsets.only(right: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                    color: AppColors.backgroundSubtle,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                    image: product.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imageUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.textTertiary,
                          ),
                        )
                      : null,
                ),
              ),
              // Content Area
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.vendorName,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
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
                          Icon(
                            Icons.location_on,
                            size: 10,
                            color: AppColors.info.withOpacity(0.7),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              product.vendorAddress,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.info.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        product.name,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Price and Stock
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₦${product.price}',
                            style: AppTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            '/piece',
                            style: AppTextStyles.caption,
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${product.stock} in',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'stock',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Add Button or Quantity Selector
                      if (!isInCart)
                        GestureDetector(
                          onTap: () =>
                              ref.read(cartProvider.notifier).addItem(product),
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: AppSpacing.xs),
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
                            color: AppColors.backgroundSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
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
                                    color: AppColors.card,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 20,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: AppTextStyles.titleMd.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
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
                                    color: AppColors.primary,
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
        ],
      ),
    );
  }
}
