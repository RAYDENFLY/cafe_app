import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../database/database_helper.dart';

class IngredientProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];
  bool _isLoading = false;

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;

  List<Ingredient> get lowStockIngredients {
    return _ingredients.where((ingredient) => ingredient.quantity <= ingredient.minStock).toList();
  }

  List<Ingredient> get expiringSoonIngredients {
    final now = DateTime.now();
    final oneWeekFromNow = now.add(const Duration(days: 7));
    return _ingredients.where((ingredient) {
      return ingredient.expiryDate != null && 
             ingredient.expiryDate!.isAfter(now) && 
             ingredient.expiryDate!.isBefore(oneWeekFromNow);
    }).toList();
  }

  List<Ingredient> get expiredIngredients {
    final now = DateTime.now();
    return _ingredients.where((ingredient) {
      return ingredient.expiryDate != null && ingredient.expiryDate!.isBefore(now);
    }).toList();
  }

  Future<void> loadIngredients() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ingredients = await DatabaseHelper.instance.getIngredients();
    } catch (e) {
      print('Error loading ingredients: $e');
      _ingredients = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    try {
      final id = await DatabaseHelper.instance.insertIngredient(ingredient);
      final newIngredient = ingredient.copyWith(id: id);
      _ingredients.add(newIngredient);
      notifyListeners();
    } catch (e) {
      print('Error adding ingredient: $e');
      rethrow;
    }
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    try {
      await DatabaseHelper.instance.updateIngredient(ingredient);
      final index = _ingredients.indexWhere((ing) => ing.id == ingredient.id);
      if (index != -1) {
        _ingredients[index] = ingredient;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating ingredient: $e');
      rethrow;
    }
  }

  Future<void> deleteIngredient(int id) async {
    try {
      await DatabaseHelper.instance.deleteIngredient(id);
      _ingredients.removeWhere((ingredient) => ingredient.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting ingredient: $e');
      rethrow;
    }
  }

  Future<void> updateIngredientStock(int ingredientId, double quantityUsed) async {
    try {
      final index = _ingredients.indexWhere((ing) => ing.id == ingredientId);
      if (index != -1) {
        final ingredient = _ingredients[index];
        final newQuantity = ingredient.quantity - quantityUsed;
        final updatedIngredient = ingredient.copyWith(quantity: newQuantity);
        
        await updateIngredient(updatedIngredient);
      }
    } catch (e) {
      print('Error updating ingredient stock: $e');
      rethrow;
    }
  }
}
