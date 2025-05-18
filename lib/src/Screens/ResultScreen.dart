import 'package:flutter/material.dart';
import 'dart:io' show File;
class ResultScreen extends StatelessWidget {
  final File userImage;
  final File garmentImage;

  const ResultScreen({
    super.key,
    required this.userImage,
    required this.garmentImage,
  });

  @override
  Widget build(BuildContext context) {
    // In a real app, this would show the processed image from backend
    // For this demo, we'll just show the garment image as a placeholder
    final List<Color> gradientColors = const [Color(0xFFFF5F6D), Color(0xFFFFC371)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Try-On Result', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back arrow
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                // In a real app, this would be the processed result image
                // For demo purposes, showing the garment image
                child: Image.file(garmentImage, fit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Save image functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image saved to gallery'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_alt, color: Colors.white),
                        label: const Text('Save', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gradientColors[0],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Share functionality
                        },
                        icon: Icon(Icons.share, color: gradientColors[0]),
                        label: Text('Share', style: TextStyle(color: gradientColors[0])),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: gradientColors[0]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Try Another Item', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientColors[0],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 0), // Full width button
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}