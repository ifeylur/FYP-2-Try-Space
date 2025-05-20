import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:try_space/src/Screens/NavBar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String name = '';
  String email = '';
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool _isLoading = false;

  final List<Color> gradientColors = const [
    Color(0xFFFF5F6D),
    Color(0xFFFFC371),
  ];

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _showLoadingDialog(String message) {
    setState(() {
      _isLoading = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Flexible(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user logged in')));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // Show loading dialog
    _showLoadingDialog('Updating profile...');

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      if (email.isNotEmpty && email != user.email) {
        await user.updateEmail(email);
        await user.sendEmailVerification();
      }

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      if (name.isNotEmpty && name != user.displayName) {
        await user.updateDisplayName(name);
      }

      await user.reload();

      // Close loading dialog
      if (_isLoading) {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated. Check your email to confirm changes.',
          ),
        ),
      );
      
      // Simply pop back to previous screen (NavBar)
      Navigator.of(context).pop();
      
    } on FirebaseAuthException catch (e) {
      // Close loading dialog
      if (_isLoading) {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });
      }
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: ${e.message}')));
    } catch (e) {
      // Close loading dialog
      if (_isLoading) {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });
      }
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply the gradient to the entire scaffold background
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Simply pop back to previous screen (NavBar)
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // This container covers the full screen with gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        // Ensure the container fills the entire screen height
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            // Removed vertical padding to extend color all the way
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                      child:
                          _imageFile == null
                              ? const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.white,
                              )
                              : null,
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Name',
                    icon: Icons.person,
                    onSaved: (val) => name = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => email = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Current Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    onSaved: (val) => currentPassword = val ?? '',
                    validator:
                        (val) =>
                            val == null || val.length < 6 ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  // _buildTextField(
                  //   label: 'New Password',
                  //   icon: Icons.lock,
                  //   obscureText: true,
                  //   onSaved: (val) => newPassword = val ?? '',
                  // ),
                  // const SizedBox(height: 16),
                  // _buildTextField(
                  //   label: 'Confirm Password',
                  //   icon: Icons.lock,
                  //   obscureText: true,
                  //   onSaved: (val) => confirmPassword = val ?? '',
                  // ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                  // Add extra padding at the bottom to ensure scrolling covers everything
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
//   Future<String> _convertImageToBase64(XFile imageFile) async {
//   final bytes = await File(imageFile.path).readAsBytes();
//   return base64Encode(bytes);
// }

}