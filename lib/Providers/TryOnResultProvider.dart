import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:try_space/Models/TryOnResultModel.dart';
import 'package:try_space/Utilities/Auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TryOnResultProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth _auth = Auth();
  
  List<TryOnResultModel> _results = [];
  List<TryOnResultModel> get results => _results;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch all results for the current user
  Future<void> fetchResults() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userId = _auth.getCurrentUserId();
      if (userId == null) {
        debugPrint('No user logged in');
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final snapshot = await _firestore
          .collection('tryOnResults')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
          
      _results = snapshot.docs
          .map((doc) => TryOnResultModel.fromMap(doc.data()))
          .toList();
          
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching try-on results: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new try-on result
  Future<bool> addResult(File resultImage) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userId = _auth.getCurrentUserId();
      if (userId == null) {
        debugPrint('No user logged in');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Convert image to base64
      final base64Image = await TryOnResultModel.fileToBase64(resultImage);
      
      // Generate unique ID
      final docRef = _firestore.collection('tryOnResults').doc();
      
      // Create model
      final result = TryOnResultModel(
        id: docRef.id,
        resultImageBase64: base64Image,
        userId: userId,
        title: 'Try-On ${_results.length + 1}',
      );
      
      // Save to Firestore
      await docRef.set(result.toMap());
      
      // Add to local list
      _results.insert(0, result);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding try-on result: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get decoded images for display
  Future<File?> getDecodedImage(String resultId) async {
    try {
      final result = _results.firstWhere((result) => result.id == resultId);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/tryOn_${result.id}.jpg';
      
      return await TryOnResultModel.base64ToFile(
        result.resultImageBase64, 
        filePath
      );
    } catch (e) {
      debugPrint('Error decoding image: $e');
      return null;
    }
  }

  /// Delete a try-on result
  Future<void> deleteResult(String resultId) async {
    try {
      await _firestore.collection('tryOnResults').doc(resultId).delete();
      _results.removeWhere((result) => result.id == resultId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting try-on result: $e');
    }
  }
}