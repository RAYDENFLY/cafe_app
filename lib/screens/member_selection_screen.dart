import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../models/member.dart';

class MemberSelectionScreen extends StatefulWidget {
  const MemberSelectionScreen({super.key});

  @override
  State<MemberSelectionScreen> createState() => _MemberSelectionScreenState();
}

class _MemberSelectionScreenState extends State<MemberSelectionScreen> {
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
      appBar: AppBar(
        title: const Text('Pilih Member'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada member yang ditemukan',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = _filteredMembers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown[200],
                          child: Text(
                            member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                            style: TextStyle(
                              color: Colors.brown[700],
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
                            if (member.phone != null) 
                              Text('📞 ${member.phone}'),
                            Text('🏆 ${member.loyaltyPoints} poin'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Navigator.pop(context, member),
                      ),
                    );
                  },
                );
              },
            ),
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
