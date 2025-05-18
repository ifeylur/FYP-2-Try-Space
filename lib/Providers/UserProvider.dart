import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:try_space/Models/UserModel.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  /// Fetch user data by UID
  Future<void> fetchUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
  }

  /// Add new user to Firestore
  Future<void> addUserToFirestore(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    notifyListeners();
  }

  /// Create or update user (overwrite)
  Future<void> saveUser(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap());

      _user = userModel;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  /// Update user's name and optionally profileImageUrl
  Future<void> updateUserProfile({
    required String name,
    String? profileImageUrl,
  }) async {
    if (_user == null) {
      debugPrint('No user loaded to update');
      return;
    }

    try {
      final docRef = _firestore.collection('users').doc(_user!.uid);

      Map<String, dynamic> updateData = {'name': name};
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        updateData['profileImageUrl'] = profileImageUrl;
      }

      // Update Firestore document partially
      await docRef.update(updateData);

      // Update local user model and notify listeners
      _user = UserModel(
        uid: _user!.uid,
        name: name,
        email: _user!.email,
        profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Clear user data
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
