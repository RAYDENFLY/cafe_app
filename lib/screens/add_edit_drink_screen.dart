import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/drink.dart';
import '../services/image_picker_helper.dart';

class AddEditDrinkScreen extends StatefulWidget {
  final Drink? drink;

  const AddEditDrinkScreen({super.key, this.drink});

  @override
  State<AddEditDrinkScreen> createState() => _AddEditDrinkScreenState();
}

class _AddEditDrinkScreenState extends State<AddEditDrinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _typeController = TextEditingController();

  String? _selectedImagePath;
  bool get isEditing => widget.drink != null;

  final List<String> _drinkTypes = [
    'Hot Drink',
    'Cold Drink',
    'Fresh Juice',
    'Smoothie',
    'Coffee',
    'Tea',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.drink!.name;
      _priceController.text = widget.drink!.price.toString();
      _stockController.text = widget.drink!.stock.toString();
      _typeController.text = widget.drink!.type;
      _selectedImagePath = widget.drink!.imagePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Minuman' : 'Tambah Minuman'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveDrink,
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gambar Minuman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          ImagePickerHelper.showImagePickerDialog(context, (imagePath) {
                            if (imagePath != null) {
                              setState(() {
                                _selectedImagePath = imagePath;
                              });
                            }
                          });
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: _selectedImagePath != null && _selectedImagePath!.isNotEmpty
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _selectedImagePath!.startsWith('/') || _selectedImagePath!.contains('\\')
                                          ? Image.file(
                                              File(_selectedImagePath!),
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 150,
                                                  height: 150,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Icon(Icons.error, size: 50, color: Colors.grey),
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              _selectedImagePath!,
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 150,
                                                  height: 150,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Icon(Icons.error, size: 50, color: Colors.grey),
                                                );
                                              },
                                            ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                          onPressed: () {
                                            ImagePickerHelper.showImagePickerDialog(context, (imagePath) {
                                              if (imagePath != null) {
                                                setState(() {
                                                  _selectedImagePath = imagePath;
                                                });
                                              }
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambah Gambar',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Form Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Minuman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Minuman *',
                        prefixIcon: Icon(Icons.local_drink),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama minuman harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _drinkTypes.contains(_typeController.text) ? _typeController.text : null,
                      decoration: const InputDecoration(
                        labelText: 'Kategori *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _drinkTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _typeController.text = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Harga *',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harga harus diisi';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Harga harus berupa angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stok *',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                        suffix: Text('pcs'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Stok harus diisi';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock < 0) {
                          return 'Stok harus berupa angka non-negatif';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDrink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final type = _typeController.text;
    final price = double.parse(_priceController.text);
    final stock = int.parse(_stockController.text);

    final drink = Drink(
      id: isEditing ? widget.drink!.id : null,
      name: name,
      type: type,
      price: price,
      stock: stock,
      imagePath: _selectedImagePath,
    );

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    try {
      if (isEditing) {
        await productProvider.updateDrink(drink);
      } else {
        await productProvider.addDrink(drink);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                ? 'Minuman berhasil diupdate' 
                : 'Minuman berhasil ditambahkan'
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                ? 'Gagal mengupdate minuman' 
                : 'Gagal menambahkan minuman'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _typeController.dispose();
    super.dispose();
  }
}
