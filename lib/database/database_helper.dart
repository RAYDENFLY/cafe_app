import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food.dart';
import '../models/drink.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/stock_movement.dart';
import '../models/member.dart';
import '../models/ingredient.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cafe_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create foods table
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        stock INTEGER NOT NULL,
        type TEXT NOT NULL,
        price REAL NOT NULL,
        imagePath TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Create drinks table
    await db.execute('''
      CREATE TABLE drinks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        stock INTEGER NOT NULL,
        type TEXT NOT NULL,
        price REAL NOT NULL,
        imagePath TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Create members table
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        loyaltyPoints INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Create cart_items table
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemName TEXT NOT NULL,
        itemType TEXT NOT NULL,
        itemId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        totalPrice REAL NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        cashAmount REAL,
        change REAL,
        bankAccount TEXT,
        qrisCode TEXT,
        invoiceNumber TEXT,
        memberId INTEGER,
        memberName TEXT,
        FOREIGN KEY (memberId) REFERENCES members (id)
      )
    ''');

    // Create transaction_items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        itemName TEXT NOT NULL,
        itemType TEXT NOT NULL,
        itemId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        totalPrice REAL NOT NULL,
        FOREIGN KEY (transactionId) REFERENCES transactions (id)
      )
    ''');

    // Create stock_movements table
    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemType TEXT NOT NULL,
        itemId INTEGER NOT NULL,
        itemName TEXT NOT NULL,
        movementType TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        reason TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Create ingredients table
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        min_stock REAL NOT NULL,
        expiry_date INTEGER,
        price_per_unit REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add members table
      await db.execute('''
        CREATE TABLE members (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          email TEXT,
          address TEXT,
          loyaltyPoints INTEGER DEFAULT 0,
          createdAt TEXT,
          updatedAt TEXT
        )
      ''');

      // Add member fields to transactions table
      await db.execute('ALTER TABLE transactions ADD COLUMN memberId INTEGER');
      await db.execute('ALTER TABLE transactions ADD COLUMN memberName TEXT');
    }
  }

  Future<void> _insertSampleData(Database db) async {
    // Sample foods
    final sampleFoods = [
      {'name': 'Nasi Goreng', 'stock': 20, 'type': 'Main Course', 'price': 25000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Ayam Bakar', 'stock': 15, 'type': 'Main Course', 'price': 30000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Gado-gado', 'stock': 10, 'type': 'Appetizer', 'price': 20000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Sate Ayam', 'stock': 25, 'type': 'Main Course', 'price': 35000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Pisang Goreng', 'stock': 30, 'type': 'Dessert', 'price': 15000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
    ];

    for (var food in sampleFoods) {
      await db.insert('foods', food);
    }

    // Sample drinks
    final sampleDrinks = [
      {'name': 'Es Teh Manis', 'stock': 50, 'type': 'Cold Drink', 'price': 8000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Kopi Hitam', 'stock': 40, 'type': 'Hot Drink', 'price': 12000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Jus Jeruk', 'stock': 30, 'type': 'Fresh Juice', 'price': 15000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Es Campur', 'stock': 25, 'type': 'Cold Drink', 'price': 18000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Cappuccino', 'stock': 35, 'type': 'Hot Drink', 'price': 20000.0, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
    ];

    for (var drink in sampleDrinks) {
      await db.insert('drinks', drink);
    }

    // Sample members
    final sampleMembers = [
      {'name': 'John Doe', 'phone': '081234567890', 'email': 'john@example.com', 'loyaltyPoints': 100, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Jane Smith', 'phone': '081987654321', 'email': 'jane@example.com', 'loyaltyPoints': 50, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
      {'name': 'Ahmad Sulaiman', 'phone': '081122334455', 'email': 'ahmad@example.com', 'loyaltyPoints': 75, 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
    ];

    for (var member in sampleMembers) {
      await db.insert('members', member);
    }
  }

  // Food operations
  Future<int> insertFood(Food food) async {
    final db = await database;
    food.createdAt = DateTime.now();
    food.updatedAt = DateTime.now();
    return await db.insert('foods', food.toMap());
  }

  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    return List.generate(maps.length, (i) => Food.fromMap(maps[i]));
  }

  Future<Food?> getFoodById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Food.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFood(Food food) async {
    final db = await database;
    food.updatedAt = DateTime.now();
    return await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Drink operations
  Future<int> insertDrink(Drink drink) async {
    final db = await database;
    drink.createdAt = DateTime.now();
    drink.updatedAt = DateTime.now();
    return await db.insert('drinks', drink.toMap());
  }

  Future<List<Drink>> getAllDrinks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('drinks');
    return List.generate(maps.length, (i) => Drink.fromMap(maps[i]));
  }

  Future<Drink?> getDrinkById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'drinks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Drink.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDrink(Drink drink) async {
    final db = await database;
    drink.updatedAt = DateTime.now();
    return await db.update(
      'drinks',
      drink.toMap(),
      where: 'id = ?',
      whereArgs: [drink.id],
    );
  }

  Future<int> deleteDrink(int id) async {
    final db = await database;
    return await db.delete(
      'drinks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cart operations
  Future<int> addToCart(CartItem item) async {
    final db = await database;
    
    // Check if item already exists in cart
    final List<Map<String, dynamic>> existing = await db.query(
      'cart_items',
      where: 'itemId = ? AND itemType = ?',
      whereArgs: [item.itemId, item.itemType],
    );

    if (existing.isNotEmpty) {
      // Update quantity
      final existingItem = CartItem.fromMap(existing.first);
      final newQuantity = existingItem.quantity + item.quantity;
      final newTotalPrice = newQuantity * item.price;
      
      return await db.update(
        'cart_items',
        {
          'quantity': newQuantity,
          'totalPrice': newTotalPrice,
        },
        where: 'id = ?',
        whereArgs: [existingItem.id],
      );
    } else {
      return await db.insert('cart_items', item.toMap());
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  Future<int> updateCartItem(CartItem item) async {
    final db = await database;
    return await db.update(
      'cart_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> removeFromCart(int id) async {
    final db = await database;
    return await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // Transaction operations
  Future<int> insertTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    
    // Generate invoice number
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    transaction.invoiceNumber = invoiceNumber;
    
    final transactionId = await db.insert('transactions', transaction.toMap());
    
    // Insert transaction items
    for (var item in transaction.items) {
      item.transactionId = transactionId;
      await db.insert('transaction_items', item.toMap());
    }
    
    return transactionId;
  }

  Future<List<app_transaction.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    
    List<app_transaction.Transaction> transactions = [];
    for (var map in maps) {
      final transaction = app_transaction.Transaction.fromMap(map);
      transaction.items = await getTransactionItems(transaction.id!);
      transactions.add(transaction);
    }
    
    return transactions;
  }

  Future<List<app_transaction.TransactionItem>> getTransactionItems(int transactionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    return List.generate(maps.length, (i) => app_transaction.TransactionItem.fromMap(maps[i]));
  }

  Future<app_transaction.Transaction?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final transaction = app_transaction.Transaction.fromMap(maps.first);
      transaction.items = await getTransactionItems(id);
      return transaction;
    }
    return null;
  }

  // Stock movement operations
  Future<int> insertStockMovement(StockMovement movement) async {
    final db = await database;
    return await db.insert('stock_movements', movement.toMap());
  }

  Future<List<StockMovement>> getAllStockMovements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_movements',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => StockMovement.fromMap(maps[i]));
  }

  Future<List<StockMovement>> getStockMovementsByType(String itemType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_movements',
      where: 'itemType = ?',
      whereArgs: [itemType],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => StockMovement.fromMap(maps[i]));
  }

  // Search operations
  Future<List<Food>> searchFoods(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'name LIKE ? OR type LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Food.fromMap(maps[i]));
  }

  Future<List<Drink>> searchDrinks(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'drinks',
      where: 'name LIKE ? OR type LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Drink.fromMap(maps[i]));
  }

  // Update stock operations
  Future<void> updateFoodStock(int foodId, int newStock) async {
    final db = await database;
    await db.update(
      'foods',
      {'stock': newStock, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [foodId],
    );
  }

  Future<void> updateDrinkStock(int drinkId, int newStock) async {
    final db = await database;
    await db.update(
      'drinks',
      {'stock': newStock, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [drinkId],
    );
  }

  // Member operations
  Future<int> insertMember(Member member) async {
    final db = await database;
    member.createdAt = DateTime.now();
    member.updatedAt = DateTime.now();
    return await db.insert('members', member.toMap());
  }

  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('members', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  Future<Member?> getMemberById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Member.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    member.updatedAt = DateTime.now();
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Member>> searchMembers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  Future<void> updateMemberLoyaltyPoints(int memberId, int points) async {
    final db = await database;
    final member = await getMemberById(memberId);
    if (member != null) {
      final newPoints = member.loyaltyPoints + points;
      await db.update(
        'members',
        {'loyaltyPoints': newPoints, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [memberId],
      );
    }
  }

  // Ingredient CRUD operations
  Future<List<Ingredient>> getIngredients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ingredients');
    return List.generate(maps.length, (i) => Ingredient.fromMap(maps[i]));
  }

  Future<int> insertIngredient(Ingredient ingredient) async {
    final db = await database;
    return await db.insert('ingredients', ingredient.toMap());
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    final db = await database;
    await db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<void> deleteIngredient(int id) async {
    final db = await database;
    await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Ingredient?> getIngredientById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Ingredient.fromMap(maps.first);
    }
    return null;
  }

  // Transaction CRUD operations
  Future<List<app_transaction.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    
    List<app_transaction.Transaction> transactions = [];
    for (var map in maps) {
      // Get transaction items
      final itemMaps = await db.query(
        'transaction_items',
        where: 'transactionId = ?',
        whereArgs: [map['id']],
      );
      final items = itemMaps.map((itemMap) => app_transaction.TransactionItem.fromMap(itemMap)).toList();
      
      // Create transaction with items
      final transaction = app_transaction.Transaction.fromMap(map);
      transaction.items = items;
      transactions.add(transaction);
    }
    
    return transactions;
  }

  Future<List<app_transaction.Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    List<app_transaction.Transaction> transactions = [];
    for (var map in maps) {
      // Get transaction items
      final itemMaps = await db.query(
        'transaction_items',
        where: 'transactionId = ?',
        whereArgs: [map['id']],
      );
      final items = itemMaps.map((itemMap) => app_transaction.TransactionItem.fromMap(itemMap)).toList();
      
      // Create transaction with items
      final transaction = app_transaction.Transaction.fromMap(map);
      transaction.items = items;
      transactions.add(transaction);
    }
    
    return transactions;
  }

  Future<List<app_transaction.Transaction>> getTransactionsByMember(int memberId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'date DESC',
    );
    
    List<app_transaction.Transaction> transactions = [];
    for (var map in maps) {
      // Get transaction items
      final itemMaps = await db.query(
        'transaction_items',
        where: 'transactionId = ?',
        whereArgs: [map['id']],
      );
      final items = itemMaps.map((itemMap) => app_transaction.TransactionItem.fromMap(itemMap)).toList();
      
      // Create transaction with items
      final transaction = app_transaction.Transaction.fromMap(map);
      transaction.items = items;
      transactions.add(transaction);
    }
    
    return transactions;
  }

  Future<void> updateTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    
    // Delete transaction items first
    await db.delete(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [id],
    );
    
    // Then delete the transaction
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
