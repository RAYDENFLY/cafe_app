import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart' as app_transaction;
import '../providers/product_provider.dart';
import '../providers/ingredient_provider.dart';
import '../providers/transaction_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<app_transaction.Transaction> _transactions = [];
  bool _isLoading = true;

  double _totalRevenue = 0;
  int _totalTransactions = 0;
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReportData();
    
    // Load transaction provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    // Load through provider untuk konsistensi
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    await transactionProvider.loadTransactions();
    _transactions = transactionProvider.transactions;
    
    _calculateFinancialSummary();

    setState(() {
      _isLoading = false;
    });
  }

  void _calculateFinancialSummary() {
    final filteredTransactions = _transactions.where((transaction) {
      return transaction.date.isAfter(_selectedStartDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(_selectedEndDate.add(const Duration(days: 1)));
    }).toList();

    _totalRevenue = filteredTransactions.fold(0, (sum, transaction) => sum + transaction.totalAmount);
    _totalTransactions = filteredTransactions.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Date Range Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode Laporan',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectStartDate(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedStartDate),
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(' - '),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectEndDate(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedEndDate),
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF6B73FF),
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              indicatorColor: const Color(0xFF6B73FF),
              tabs: const [
                Tab(
                  icon: Icon(FontAwesomeIcons.chartLine, size: 16),
                  text: 'Keuangan',
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.bell, size: 16),
                  text: 'Alert',
                ),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFinancialReportTab(),
                      _buildAlertTab(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _generatePDFReport(),
        backgroundColor: const Color(0xFF6B73FF),
        child: const Icon(FontAwesomeIcons.filePdf, color: Colors.white),
      ),
    );
  }

  Widget _buildFinancialReportTab() {
    final filteredTransactions = _transactions.where((transaction) {
      return transaction.date.isAfter(_selectedStartDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(_selectedEndDate.add(const Duration(days: 1)));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Pendapatan',
                  value: 'Rp ${_totalRevenue.toStringAsFixed(0)}',
                  icon: FontAwesomeIcons.moneyBill,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Transaksi',
                  value: '$_totalTransactions',
                  icon: FontAwesomeIcons.receipt,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Rata-rata per Transaksi',
                  value: _totalTransactions > 0 
                      ? 'Rp ${(_totalRevenue / _totalTransactions).toStringAsFixed(0)}'
                      : 'Rp 0',
                  icon: FontAwesomeIcons.calculator,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Transaksi/Hari',
                  value: '${(_totalTransactions / (_selectedEndDate.difference(_selectedStartDate).inDays + 1)).toStringAsFixed(1)}',
                  icon: FontAwesomeIcons.calendar,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Transaction List
          Text(
            'Riwayat Transaksi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          
          ...filteredTransactions.map((transaction) => _buildTransactionCard(transaction)),
        ],
      ),
    );
  }

  Widget _buildAlertTab() {
    return Consumer2<ProductProvider, IngredientProvider>(
      builder: (context, productProvider, ingredientProvider, child) {
        final lowStockFoods = productProvider.allFoods.where((food) => food.stock <= 5).toList();
        final lowStockDrinks = productProvider.allDrinks.where((drink) => drink.stock <= 5).toList();
        final lowStockIngredients = ingredientProvider.lowStockIngredients;
        final expiringSoonIngredients = ingredientProvider.expiringSoonIngredients;
        final expiredIngredients = ingredientProvider.expiredIngredients;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Stok Rendah',
                      value: '${lowStockFoods.length + lowStockDrinks.length + lowStockIngredients.length}',
                      icon: FontAwesomeIcons.triangleExclamation,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Akan Expired',
                      value: '${expiringSoonIngredients.length}',
                      icon: FontAwesomeIcons.clock,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Low Stock Foods
              if (lowStockFoods.isNotEmpty) ...[
                Text(
                  'Makanan Stok Rendah',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                ...lowStockFoods.map((food) => _buildAlertCard(
                  name: food.name,
                  detail: 'Stok: ${food.stock}',
                  alertType: 'Stok Rendah',
                  color: Colors.orange,
                  icon: FontAwesomeIcons.utensils,
                )),
                const SizedBox(height: 20),
              ],

              // Low Stock Drinks
              if (lowStockDrinks.isNotEmpty) ...[
                Text(
                  'Minuman Stok Rendah',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                ...lowStockDrinks.map((drink) => _buildAlertCard(
                  name: drink.name,
                  detail: 'Stok: ${drink.stock}',
                  alertType: 'Stok Rendah',
                  color: Colors.orange,
                  icon: FontAwesomeIcons.mugHot,
                )),
                const SizedBox(height: 20),
              ],

              // Low Stock Ingredients
              if (lowStockIngredients.isNotEmpty) ...[
                Text(
                  'Bahan Baku Stok Rendah',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                ...lowStockIngredients.map((ingredient) => _buildAlertCard(
                  name: ingredient.name,
                  detail: 'Stok: ${ingredient.stock} ${ingredient.unit} (Min: ${ingredient.minimumStock})',
                  alertType: 'Stok Rendah',
                  color: Colors.orange,
                  icon: FontAwesomeIcons.seedling,
                )),
                const SizedBox(height: 20),
              ],

              // Expiring Soon Ingredients
              if (expiringSoonIngredients.isNotEmpty) ...[
                Text(
                  'Bahan Baku Akan Expired',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                ...expiringSoonIngredients.map((ingredient) => _buildAlertCard(
                  name: ingredient.name,
                  detail: 'Expired: ${DateFormat('dd/MM/yyyy').format(ingredient.expiryDate!)}',
                  alertType: 'Akan Expired',
                  color: Colors.red,
                  icon: FontAwesomeIcons.clock,
                )),
                const SizedBox(height: 20),
              ],

              // Expired Ingredients
              if (expiredIngredients.isNotEmpty) ...[
                Text(
                  'Bahan Baku Expired',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                ...expiredIngredients.map((ingredient) => _buildAlertCard(
                  name: ingredient.name,
                  detail: 'Expired: ${DateFormat('dd/MM/yyyy').format(ingredient.expiryDate!)}',
                  alertType: 'EXPIRED',
                  color: Colors.red[800]!,
                  icon: FontAwesomeIcons.xmark,
                )),
              ],

              // No Alerts
              if (lowStockFoods.isEmpty && 
                  lowStockDrinks.isEmpty && 
                  lowStockIngredients.isEmpty && 
                  expiringSoonIngredients.isEmpty && 
                  expiredIngredients.isEmpty) ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        FontAwesomeIcons.circleCheck,
                        size: 80,
                        color: Colors.green[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak Ada Alert',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semua stok dalam kondisi baik',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertCard({
    required String name,
    required String detail,
    required String alertType,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alertType,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(app_transaction.Transaction transaction) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                FontAwesomeIcons.receipt,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.invoiceNumber ?? 'INV-${transaction.id}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${transaction.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    transaction.paymentMethod.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
      _calculateFinancialSummary();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
      _calculateFinancialSummary();
    }
  }

  Future<void> _generatePDFReport() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Kafe',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Periode: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate)} - ${DateFormat('dd/MM/yyyy').format(_selectedEndDate)}',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Ringkasan Keuangan:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Total Pendapatan: Rp ${_totalRevenue.toStringAsFixed(0)}'),
              pw.Text('Total Transaksi: $_totalTransactions'),
              pw.SizedBox(height: 20),
              // Add more report content here
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
