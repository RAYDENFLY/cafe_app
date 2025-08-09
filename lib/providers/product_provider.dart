import 'package:flutter/foundation.dart';
import '../models/food.dart';
import '../models/drink.dart';
import '../database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Food> _foods = [];
  List<Drink> _drinks = [];
  List<Food> _filteredFoods = [];
  List<Drink> _filteredDrinks = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Food> get foods => _filteredFoods;
  List<Drink> get drinks => _filteredDrinks;
  List<Food> get allFoods => _foods;
  List<Drink> get allDrinks => _drinks;

  Future<void> loadProducts() async {
    _foods = await _databaseHelper.getAllFoods();
    _drinks = await _databaseHelper.getAllDrinks();
    _filteredFoods = List.from(_foods);
    _filteredDrinks = List.from(_drinks);
    notifyListeners();
  }

  // Food operations
  Future<void> addFood(Food food) async {
    await _databaseHelper.insertFood(food);
    await loadProducts();
  }

  Future<void> updateFood(Food food) async {
    await _databaseHelper.updateFood(food);
    await loadProducts();
  }

  Future<void> deleteFood(int id) async {
    await _databaseHelper.deleteFood(id);
    await loadProducts();
  }

  Future<Food?> getFoodById(int id) async {
    return await _databaseHelper.getFoodById(id);
  }

  // Drink operations
  Future<void> addDrink(Drink drink) async {
    await _databaseHelper.insertDrink(drink);
    await loadProducts();
  }

  Future<void> updateDrink(Drink drink) async {
    await _databaseHelper.updateDrink(drink);
    await loadProducts();
  }

  Future<void> deleteDrink(int id) async {
    await _databaseHelper.deleteDrink(id);
    await loadProducts();
  }

  Future<Drink?> getDrinkById(int id) async {
    return await _databaseHelper.getDrinkById(id);
  }

  // Search and filter
  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredFoods = List.from(_foods);
      _filteredDrinks = List.from(_drinks);
    } else {
      _filteredFoods = _foods
          .where((food) =>
              food.name.toLowerCase().contains(query.toLowerCase()) ||
              food.type.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _filteredDrinks = _drinks
          .where((drink) =>
              drink.name.toLowerCase().contains(query.toLowerCase()) ||
              drink.type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByType(String type) {
    if (type.isEmpty || type == 'All') {
      _filteredFoods = List.from(_foods);
      _filteredDrinks = List.from(_drinks);
    } else {
      _filteredFoods = _foods.where((food) => food.type == type).toList();
      _filteredDrinks = _drinks.where((drink) => drink.type == type).toList();
    }
    notifyListeners();
  }

  void resetFilter() {
    _filteredFoods = List.from(_foods);
    _filteredDrinks = List.from(_drinks);
    notifyListeners();
  }

  List<String> getFoodTypes() {
    return _foods.map((food) => food.type).toSet().toList();
  }

  List<String> getDrinkTypes() {
    return _drinks.map((drink) => drink.type).toSet().toList();
  }

  // Stock management
  Future<void> updateFoodStock(int foodId, int newStock) async {
    await _databaseHelper.updateFoodStock(foodId, newStock);
    await loadProducts();
  }

  Future<void> updateDrinkStock(int drinkId, int newStock) async {
    await _databaseHelper.updateDrinkStock(drinkId, newStock);
    await loadProducts();
  }

  // Get new products (added in last 7 days)
  List<Food> getNewFoods() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _foods
        .where((food) =>
            food.createdAt != null && food.createdAt!.isAfter(oneWeekAgo))
        .toList();
  }

  List<Drink> getNewDrinks() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _drinks
        .where((drink) =>
            drink.createdAt != null && drink.createdAt!.isAfter(oneWeekAgo))
        .toList();
  }
}
