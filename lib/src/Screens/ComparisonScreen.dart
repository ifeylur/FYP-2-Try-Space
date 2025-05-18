import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  File? _firstImage;
  File? _secondImage;
  bool _showResult = false;

  int _selectedIndex = 1;

  Future<void> _pickImage(bool isFirst) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isFirst) {
          _firstImage = File(pickedFile.path);
        } else {
          _secondImage = File(pickedFile.path);
        }
      });
    }
  }

  void _onTryOnPressed() {
    if (_firstImage != null && _secondImage != null) {
      setState(() {
        _showResult = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select both images before trying on.'),
      ));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
      // Already on compare screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compare Outfits"),
        backgroundColor: const Color(0xFF2A86E3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Upload Two Images to Compare",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // First image picker
            GestureDetector(
              onTap: () => _pickImage(true),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[100],
                ),
                child: _firstImage != null
                    ? Image.file(_firstImage!, fit: BoxFit.cover)
                    : const Center(child: Text("Tap to select first image")),
              ),
            ),
            const SizedBox(height: 16),

            // Second image picker
            GestureDetector(
              onTap: () => _pickImage(false),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[100],
                ),
                child: _secondImage != null
                    ? Image.file(_secondImage!, fit: BoxFit.cover)
                    : const Center(child: Text("Tap to select second image")),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _onTryOnPressed,
              child: const Text("Try On"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A86E3),
              ),
            ),

            const SizedBox(height: 30),

            // Result section
            if (_showResult)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Comparison Result",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _firstImage != null
                            ? Image.file(_firstImage!)
                            : const SizedBox(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _secondImage != null
                            ? Image.file(_secondImage!)
                            : const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "This is a basic visual comparison. AI styling suggestions will be added soon.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2A86E3),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.compare), label: 'Try On'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
