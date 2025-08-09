import 'package:flutter/material.dart';
import '../models/transaction.dart' as app_transaction;
import '../database/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<app_transaction.Transaction> _transactions = [];
  bool _isLoading = false;

  List<app_transaction.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseHelper.instance.getTransactions();
    } catch (e) {
      print('Error loading transactions: $e');
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(app_transaction.Transaction transaction) async {
    try {
      final id = await DatabaseHelper.instance.insertTransaction(transaction);
      final newTransaction = transaction.copyWith(id: id);
      _transactions.insert(0, newTransaction); // Insert at beginning for newest first
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(app_transaction.Transaction transaction) async {
    try {
      await DatabaseHelper.instance.updateTransaction(transaction);
      final index = _transactions.indexWhere((trans) => trans.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((transaction) => transaction.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  List<app_transaction.Transaction> getTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return _transactions.where((transaction) {
      final transactionDate = transaction.createdAt;
      return transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transactionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<app_transaction.Transaction> getTransactionsByMember(int memberId) {
    return _transactions.where((transaction) => transaction.memberId == memberId).toList();
  }

  double getTotalSalesForPeriod(DateTime startDate, DateTime endDate) {
    final periodTransactions = getTransactionsByDateRange(startDate, endDate);
    return periodTransactions.fold(0.0, (sum, transaction) => sum + transaction.totalAmount);
  }

  double getTotalSalesToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return getTotalSalesForPeriod(startOfDay, endOfDay);
  }

  double getTotalSalesThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTotalSalesForPeriod(startOfMonth, endOfMonth);
  }

  int getTransactionCountToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return getTransactionsByDateRange(startOfDay, endOfDay).length;
  }
}
