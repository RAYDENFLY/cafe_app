import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../models/member.dart';

class AddEditMemberScreen extends StatefulWidget {
  final Member? member;

  const AddEditMemberScreen({super.key, this.member});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _loyaltyPointsController = TextEditingController();

  bool get isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.member!.name;
      _phoneController.text = widget.member!.phone ?? '';
      _emailController.text = widget.member!.email ?? '';
      _addressController.text = widget.member!.address ?? '';
      _loyaltyPointsController.text = widget.member!.loyaltyPoints.toString();
    } else {
      _loyaltyPointsController.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Member' : 'Tambah Member'),
        backgroundColor: const Color(0xFF6B73FF),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveMember,
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Member',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _loyaltyPointsController,
                      decoration: const InputDecoration(
                        labelText: 'Poin Loyalty',
                        prefixIcon: Icon(Icons.star),
                        border: OutlineInputBorder(),
                        suffix: Text('poin'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Poin loyalty harus diisi';
                        }
                        final points = int.tryParse(value);
                        if (points == null || points < 0) {
                          return 'Poin loyalty harus berupa angka positif';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Tambahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Member akan mendapatkan poin setiap pembelian'),
                    Text('• Poin dapat digunakan untuk mendapatkan diskon'),
                    Text('• Data member akan tersimpan untuk transaksi selanjutnya'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    final address = _addressController.text.trim().isEmpty ? null : _addressController.text.trim();
    final loyaltyPoints = int.parse(_loyaltyPointsController.text);

    final member = Member(
      id: isEditing ? widget.member!.id : null,
      name: name,
      phone: phone,
      email: email,
      address: address,
      loyaltyPoints: loyaltyPoints,
    );

    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    bool success;

    if (isEditing) {
      success = await memberProvider.updateMember(member);
    } else {
      success = await memberProvider.addMember(member);
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                ? 'Member berhasil diupdate' 
                : 'Member berhasil ditambahkan'
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                ? 'Gagal mengupdate member' 
                : 'Gagal menambahkan member'
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
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _loyaltyPointsController.dispose();
    super.dispose();
  }
}
