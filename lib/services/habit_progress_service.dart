import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mark habit as complete
  Future<void> markHabitComplete(String habitId, String routineType) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Add completion record
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_progress')
          .add({
        'habitId': habitId,
        'routineType': routineType,
        'completedAt': FieldValue.serverTimestamp(),
        'date': DateTime.now(),
      });

      // Update streak and statistics
      await _updateHabitStatistics(habitId);
    } catch (e) {
      print('Error marking habit complete: $e');
      rethrow;
    }
  }

  // Get current streak for a habit
  Future<int> getCurrentStreak(String habitId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_progress')
          .where('habitId', isEqualTo: habitId)
          .orderBy('date', descending: true)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      int streak = 1;
      DateTime lastDate =
          (snapshot.docs.first.data() as Map<String, dynamic>)['date'].toDate();

      for (var i = 1; i < snapshot.docs.length; i++) {
        final currentDate =
            (snapshot.docs[i].data() as Map<String, dynamic>)['date'].toDate();
        if (lastDate.difference(currentDate).inDays == 1) {
          streak++;
          lastDate = currentDate;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      print('Error getting streak: $e');
      return 0;
    }
  }

  // Get completion rate for a habit
  Future<double> getCompletionRate(String habitId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final today = DateTime.now();
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_progress')
          .where('habitId', isEqualTo: habitId)
          .where('date', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      return snapshot.docs.length / 30 * 100;
    } catch (e) {
      print('Error getting completion rate: $e');
      return 0.0;
    }
  }

  // Update habit statistics
  Future<void> _updateHabitStatistics(String habitId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final currentStreak = await getCurrentStreak(habitId);
      final completionRate = await getCompletionRate(habitId);

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_statistics')
          .doc(habitId)
          .set({
        'currentStreak': currentStreak,
        'completionRate': completionRate,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating habit statistics: $e');
    }
  }

  // Get habit statistics
  Future<Map<String, dynamic>> getHabitStatistics(String habitId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_statistics')
          .doc(habitId)
          .get();

      return doc.data() ??
          {
            'currentStreak': 0,
            'completionRate': 0.0,
          };
    } catch (e) {
      print('Error getting habit statistics: $e');
      return {
        'currentStreak': 0,
        'completionRate': 0.0,
      };
    }
  }
}
