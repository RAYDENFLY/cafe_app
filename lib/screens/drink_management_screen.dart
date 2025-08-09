import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/drink.dart';
import 'add_edit_drink_screen.dart';

class DrinkManagementScreen extends StatefulWidget {
  const DrinkManagementScreen({super.key});

  @override
  State<DrinkManagementScreen> createState() => _DrinkManagementScreenState();
}

class _DrinkManagementScreenState extends State<DrinkManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                      hintText: 'Cari minuman...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Header dengan tombol tambah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Minuman',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "add_drink_fab",
                      mini: true,
                      backgroundColor: const Color(0xFF6B73FF),
                      onPressed: () => _navigateToAddDrink(),
                      child: const Icon(
                        FontAwesomeIcons.plus,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // List Minuman
                Expanded(
                  child: productProvider.drinks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                FontAwesomeIcons.glassWater,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada minuman',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambahkan minuman pertama Anda',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _getFilteredDrinks(productProvider).length,
                          itemBuilder: (context, index) {
                            final drink = _getFilteredDrinks(productProvider)[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: drink.imagePath != null && drink.imagePath!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            drink.imagePath!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                FontAwesomeIcons.glassWater,
                                                color: Color(0xFF6B73FF),
                                                size: 24,
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(
                                          FontAwesomeIcons.glassWater,
                                          color: Color(0xFF6B73FF),
                                          size: 24,
                                        ),
                                ),
                                title: Text(
                                  drink.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      drink.type,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Rp ${drink.price.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF6B73FF),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Stok: ${drink.stock}',
                                          style: GoogleFonts.poppins(
                                            color: drink.stock > 0 ? Colors.green : Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.penToSquare,
                                        color: Color(0xFF6B73FF),
                                        size: 18,
                                      ),
                                      onPressed: () => _navigateToEditDrink(drink),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.trash,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () => _showDeleteConfirmation(context, drink, productProvider),
                                    ),
                                  ],
                                ),
                              ),
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

  List<Drink> _getFilteredDrinks(ProductProvider productProvider) {
    if (_searchController.text.isEmpty) {
      return productProvider.drinks;
    }
    return productProvider.drinks
        .where((drink) =>
            drink.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            drink.type.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  void _navigateToAddDrink() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditDrinkScreen(),
      ),
    );
  }

  void _navigateToEditDrink(Drink drink) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDrinkScreen(drink: drink),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Drink drink, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hapus Minuman',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${drink.name}?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                await productProvider.deleteDrink(drink.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
