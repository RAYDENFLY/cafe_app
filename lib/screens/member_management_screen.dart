import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../models/member.dart';
import 'add_edit_member_screen.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Member> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMembers();
    });
  }

  Future<void> _loadMembers() async {
    await Provider.of<MemberProvider>(context, listen: false).loadMembers();
    _filterMembers();
  }

  void _filterMembers() {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      _filteredMembers = List.from(memberProvider.members);
    } else {
      _filteredMembers = memberProvider.members.where((member) {
        return member.name.toLowerCase().contains(query) ||
               (member.phone?.toLowerCase().contains(query) ?? false) ||
               (member.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterMembers(),
              decoration: InputDecoration(
                hintText: 'Cari member...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, memberProvider, child) {
                if (memberProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredMembers.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada member yang ditemukan'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = _filteredMembers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6B73FF).withOpacity(0.1),
                          child: Text(
                            member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                            style: const TextStyle(
                              color: Color(0xFF6B73FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (member.phone != null) Text('📞 ${member.phone}'),
                            if (member.email != null) Text('📧 ${member.email}'),
                            Text('🏆 ${member.loyaltyPoints} poin'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editMember(member);
                                break;
                              case 'delete':
                                _deleteMember(member);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMember,
        backgroundColor: const Color(0xFF6B73FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addMember() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditMemberScreen(),
      ),
    );
    
    if (result == true) {
      _loadMembers();
    }
  }

  void _editMember(Member member) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMemberScreen(member: member),
      ),
    );
    
    if (result == true) {
      _loadMembers();
    }
  }

  void _deleteMember(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Member'),
        content: Text('Apakah Anda yakin ingin menghapus member ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<MemberProvider>(context, listen: false)
                  .deleteMember(member.id!);
              if (success) {
                _filterMembers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Member berhasil dihapus')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
