import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Journal entry save karne ke liye
  Future<void> saveJournalEntry({
    required String content,
    required DateTime date,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journal_entries')
          .add({
        'content': content,
        'date': Timestamp.fromDate(date),
        'title': additionalData?['title'] ?? '',
        'mood': additionalData?['mood'] ?? 'neutral',
        'tags': additionalData?['tags'] ?? [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving journal entry: $e');
      rethrow;
    }
  }

  // User ke saare journal entries fetch karne ke liye
  Stream<QuerySnapshot> getJournalEntries() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journal_entries')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Specific date ki entry fetch karne ke liye
  Future<QuerySnapshot> getJournalEntriesByDate(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journal_entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
  }

  // Entry delete karne ke liye
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journal_entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      print('Error deleting journal entry: $e');
      rethrow;
    }
  }
}
