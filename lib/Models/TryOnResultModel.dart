import 'dart:convert';
import 'dart:io';

class TryOnResultModel {
  final String id;
  final String resultImageBase64;
  final String userId;
  final String title;

  TryOnResultModel({
    required this.id,
    required this.resultImageBase64,
    required this.userId,
    this.title = 'Try-On Result',
  });

  // Convert File to base64 encoded string
  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  // Convert base64 string back to File (for display purposes)
  static Future<File> base64ToFile(String base64String, String filePath) async {
    final bytes = base64Decode(base64String);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resultImageBase64': resultImageBase64,
      'userId': userId,
      'title': title,
    };
  }

  factory TryOnResultModel.fromMap(Map<String, dynamic> map) {
    return TryOnResultModel(
      id: map['id'],
      resultImageBase64: map['resultImageBase64'],
      userId: map['userId'],
      title: map['title'] ?? 'Try-On Result',
    );
  }
}