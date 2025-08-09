import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../widgets/product_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    // Remove listener to prevent memory leaks
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.removeListener(_onProductsChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Listen to product changes and reset category filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.addListener(_onProductsChanged);
    });
  }

  void _onProductsChanged() {
    if (mounted) {
      setState(() {
        _selectedCategory = 'All';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, CartProvider>(
      builder: (context, productProvider, cartProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B73FF), Color(0xFF9FACE6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelola menu kafe Anda',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      FontAwesomeIcons.mugHot,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari makanan atau minuman...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: Colors.grey,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    productProvider.searchProducts(value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All', productProvider),
                    ...productProvider.getFoodTypes().map((type) => 
                        _buildCategoryChip(type, productProvider)),
                    ...productProvider.getDrinkTypes().map((type) => 
                        _buildCategoryChip(type, productProvider)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // All Products Section
              Text(
                'Semua Menu',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),

              // Products Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: productProvider.foods.length + productProvider.drinks.length,
                itemBuilder: (context, index) {
                    if (index < productProvider.foods.length) {
                      final food = productProvider.foods[index];
                      return ProductCard(
                        name: food.name,
                        price: food.price,
                        stock: food.stock,
                        type: food.type,
                        imagePath: food.imagePath,
                        onAddToCart: () => _addToCart(food, true, cartProvider),
                      );
                    } else {
                      final drinkIndex = index - productProvider.foods.length;
                      final drink = productProvider.drinks[drinkIndex];
                      return ProductCard(
                        name: drink.name,
                        price: drink.price,
                        stock: drink.stock,
                        type: drink.type,
                        imagePath: drink.imagePath,
                        onAddToCart: () => _addToCart(drink, false, cartProvider),
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category, ProductProvider productProvider) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          category,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B73FF),
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
          productProvider.filterByType(category);
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF6B73FF),
        checkmarkColor: Colors.white,
        side: const BorderSide(color: Color(0xFF6B73FF)),
      ),
    );
  }

  void _addToCart(dynamic item, bool isFood, CartProvider cartProvider) {
    if (item.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} sedang tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartItem = CartItem(
      itemName: item.name,
      itemType: isFood ? 'food' : 'drink',
      itemId: item.id!,
      quantity: 1,
      price: item.price,
      totalPrice: item.price,
    );

    cartProvider.addToCart(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ditambahkan ke keranjang'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
