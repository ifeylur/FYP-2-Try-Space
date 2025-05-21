import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:try_space/Models/TryOnResultModel.dart';
import 'package:try_space/Providers/TryOnResultProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Add this package

class ResultScreen extends StatefulWidget {
  final File userImage;
  final File garmentImage;

  const ResultScreen({
    Key? key,
    required this.userImage,
    required this.garmentImage,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _resultKey = GlobalKey();
  bool _isSaving = false;
  String _errorMessage = '';

  // Define the gradient colors (same as in HomePage)
  final List<Color> gradientColors = const [
    Color(0xFFFF5F6D),
    Color(0xFFFFC371),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Try-On Result',
          style: TextStyle(color: Colors.white),
        ),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _resultKey,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    // In a real application, you would use a proper try-on algorithm here
                    // For now, we're just displaying the user image with a semi-transparent garment overlay
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(
                          widget.userImage,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        Opacity(
                          opacity: 0.7,
                          child: Image.file(
                            widget.garmentImage,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveResultToFirestore,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 30,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.grey;
                  }
                  return gradientColors[0];
                }),
              ),
              child:
                  _isSaving
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Save Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResultToFirestore() async {
    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      // Check authentication first
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _errorMessage = 'User not authenticated. Please log in again.';
          _isSaving = false;
        });
        return;
      }

      // Capture the result image as Base64
      final base64Image = await _captureResultAsBase64();

      if (base64Image != null) {
        // Generate a unique ID
        final resultId = const Uuid().v4();
        
        // Create TryOnResult object with the generated ID
        final result = TryOnResultModel(
          id: resultId,
          resultImage: base64Image,
          userId: userId,
          title: 'Try-On Result',
        );

        // Save to Firestore using provider
        await Provider.of<TryOnResultProvider>(
          context,
          listen: false,
        ).postTryOnResult(result);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result saved successfully!')),
        );

        // Navigate back to home page
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = 'Failed to capture result image';
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving result: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<String?> _captureResultAsBase64() async {
    try {
      // Find the RenderRepaintBoundary
      RenderRepaintBoundary? boundary =
          _resultKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Capture image with a lower pixel ratio for smaller file size
      ui.Image image = await boundary.toImage(pixelRatio: 0.7); // Lower pixel ratio

      // Get PNG bytes with lower quality
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData == null) return null;

      // Convert to Uint8List
      Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Compress the image further before base64 encoding
      Uint8List compressedBytes = await _compressImage(pngBytes);
      
      // Convert to Base64
      String base64Image = base64Encode(compressedBytes);
      
      return base64Image;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }
  
  // Add this method to compress the image bytes further
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    // If you have flutter_image_compress package:
    try {
      // You'll need to add flutter_image_compress package
      // For now, we'll just return the original bytes
      // In a real app, use:
      // return await FlutterImageCompress.compressWithList(
      //   bytes,
      //   quality: 70,
      //   format: CompressFormat.jpeg,
      // );
      
      // Simulate compression by returning original bytes
      return bytes;
    } catch (e) {
      print('Error compressing image: $e');
      return bytes; // Return original if compression fails
    }
  }
}