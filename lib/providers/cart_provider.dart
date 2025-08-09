import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../database/database_helper.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<CartItem> get items => _items;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> loadCartItems() async {
    _items = await _databaseHelper.getCartItems();
    notifyListeners();
  }

  Future<void> addToCart(CartItem item) async {
    await _databaseHelper.addToCart(item);
    await loadCartItems();
  }

  Future<void> updateCartItem(CartItem item) async {
    await _databaseHelper.updateCartItem(item);
    await loadCartItems();
  }

  Future<void> removeFromCart(int id) async {
    await _databaseHelper.removeFromCart(id);
    await loadCartItems();
  }

  Future<void> clearCart() async {
    await _databaseHelper.clearCart();
    _items.clear();
    notifyListeners();
  }

  Future<void> increaseQuantity(int cartItemId) async {
    final itemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (itemIndex != -1) {
      final item = _items[itemIndex];
      final updatedItem = item.copyWith(
        quantity: item.quantity + 1,
        totalPrice: (item.quantity + 1) * item.price,
      );
      await updateCartItem(updatedItem);
    }
  }

  Future<void> decreaseQuantity(int cartItemId) async {
    final itemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (itemIndex != -1) {
      final item = _items[itemIndex];
      if (item.quantity > 1) {
        final updatedItem = item.copyWith(
          quantity: item.quantity - 1,
          totalPrice: (item.quantity - 1) * item.price,
        );
        await updateCartItem(updatedItem);
      } else {
        await removeFromCart(cartItemId);
      }
    }
  }
}
