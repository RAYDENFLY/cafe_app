import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/member_provider.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';
import 'invoice_screen.dart';

class CashPaymentScreen extends StatefulWidget {
  final double totalAmount;

  const CashPaymentScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  final TextEditingController _cashAmountController = TextEditingController();
  double _change = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cashAmountController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
    setState(() {
      _change = cashAmount - widget.totalAmount;
    });
  }

  Future<void> _processPayment() async {
    final cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
    
    if (cashAmount < widget.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah uang tidak mencukupi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final dbHelper = DatabaseHelper();

      // Create transaction
      final transaction = Transaction(
        date: DateTime.now(),
        totalAmount: widget.totalAmount,
        paymentMethod: 'cash',
        cashAmount: cashAmount,
        change: _change,
        memberId: memberProvider.selectedMember?.id,
        memberName: memberProvider.selectedMember?.name,
        items: cartProvider.items.map((cartItem) => TransactionItem(
          transactionId: 0, // Will be set by database
          itemName: cartItem.itemName,
          itemType: cartItem.itemType,
          itemId: cartItem.itemId,
          quantity: cartItem.quantity,
          price: cartItem.price,
          totalPrice: cartItem.totalPrice,
        )).toList(),
      );

      // Save transaction
      final transactionId = await dbHelper.insertTransaction(transaction);
      
      // Update member loyalty points if member selected
      if (memberProvider.selectedMember != null) {
        final loyaltyPoints = (widget.totalAmount / 10000).floor(); // 1 point per 10k
        await memberProvider.updateLoyaltyPoints(memberProvider.selectedMember!.id!, loyaltyPoints);
      }
      
      // Update stock for each item
      for (var cartItem in cartProvider.items) {
        if (cartItem.itemType == 'food') {
          final food = await dbHelper.getFoodById(cartItem.itemId);
          if (food != null) {
            await dbHelper.updateFoodStock(cartItem.itemId, food.stock - cartItem.quantity);
          }
        } else {
          final drink = await dbHelper.getDrinkById(cartItem.itemId);
          if (drink != null) {
            await dbHelper.updateDrinkStock(cartItem.itemId, drink.stock - cartItem.quantity);
          }
        }
      }

      // Clear cart and selected member
      await cartProvider.clearCart();
      memberProvider.clearSelectedMember();

      // Get complete transaction data
      final completeTransaction = await dbHelper.getTransactionById(transactionId);

      if (mounted && completeTransaction != null) {
        // Navigate to invoice
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceScreen(transaction: completeTransaction),
          ),
          (route) => route.settings.name == '/home',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pembayaran Tunai',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6B73FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6B73FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6B73FF).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Total yang harus dibayar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${widget.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B73FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cash Input
            Text(
              'Jumlah Uang Diterima',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),

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
                controller: _cashAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah uang',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: const Icon(
                    FontAwesomeIcons.moneyBill,
                    color: Color(0xFF6B73FF),
                  ),
                  prefixText: 'Rp ',
                  prefixStyle: GoogleFonts.poppins(
                    color: const Color(0xFF2C3E50),
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) => _calculateChange(),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Amount Buttons
            Text(
              'Jumlah Cepat',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickAmountButton(widget.totalAmount),
                _buildQuickAmountButton(50000),
                _buildQuickAmountButton(100000),
                _buildQuickAmountButton(200000),
                _buildQuickAmountButton(500000),
              ],
            ),
            const SizedBox(height: 24),

            // Change Display
            if (_cashAmountController.text.isNotEmpty && 
                (double.tryParse(_cashAmountController.text) ?? 0) >= widget.totalAmount)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Kembalian',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${_change.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Process Payment Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing || 
                         _cashAmountController.text.isEmpty ||
                         (double.tryParse(_cashAmountController.text) ?? 0) < widget.totalAmount
                    ? null
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B73FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FontAwesomeIcons.check, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            'Proses Pembayaran',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildQuickAmountButton(double amount) {
    return ElevatedButton(
      onPressed: () {
        _cashAmountController.text = amount.toStringAsFixed(0);
        _calculateChange();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        foregroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        'Rp ${amount.toStringAsFixed(0)}',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
