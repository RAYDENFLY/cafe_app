import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../database/database_helper.dart';

class MemberProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Member> _members = [];
  bool _isLoading = false;
  Member? _selectedMember;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  Member? get selectedMember => _selectedMember;

  Future<void> loadMembers() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _members = await _dbHelper.getAllMembers();
    } catch (e) {
      debugPrint('Error loading members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMember(Member member) async {
    try {
      final id = await _dbHelper.insertMember(member);
      member.id = id;
      _members.add(member);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding member: $e');
      return false;
    }
  }

  Future<bool> updateMember(Member member) async {
    try {
      await _dbHelper.updateMember(member);
      final index = _members.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _members[index] = member;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating member: $e');
      return false;
    }
  }

  Future<bool> deleteMember(int id) async {
    try {
      await _dbHelper.deleteMember(id);
      _members.removeWhere((member) => member.id == id);
      if (_selectedMember?.id == id) {
        _selectedMember = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting member: $e');
      return false;
    }
  }

  Future<List<Member>> searchMembers(String query) async {
    try {
      return await _dbHelper.searchMembers(query);
    } catch (e) {
      debugPrint('Error searching members: $e');
      return [];
    }
  }

  void selectMember(Member? member) {
    _selectedMember = member;
    notifyListeners();
  }

  void clearSelectedMember() {
    _selectedMember = null;
    notifyListeners();
  }

  Future<void> updateLoyaltyPoints(int memberId, int points) async {
    try {
      await _dbHelper.updateMemberLoyaltyPoints(memberId, points);
      final index = _members.indexWhere((m) => m.id == memberId);
      if (index != -1) {
        _members[index].loyaltyPoints += points;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating loyalty points: $e');
    }
  }
}
