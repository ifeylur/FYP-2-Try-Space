import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:try_space/Models/TryOnResultModel.dart';

class TryOnResultProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TryOnResultModel> _results = [];
  List<TryOnResultModel> get results => _results;

  /// Fetch results by userId
  Future<void> fetchResults(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tryon_results')
          .where('userId', isEqualTo: userId)
          .get();

      _results = snapshot.docs
          .map((doc) => TryOnResultModel.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching try-on results: $e');
    }
  }

  /// Add a new try-on result
  Future<void> addResult(TryOnResultModel result) async {
    try {
      await _firestore
          .collection('tryon_results')
          .doc(result.id)
          .set(result.toMap());

      _results.add(result);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding try-on result: $e');
    }
  }

  /// Clear results (optional)
  void clearResults() {
    _results.clear();
    notifyListeners();
  }
}
