class TryOnResultModel {
  final String id;
  final String userId;
  final String uploadedUserImageUrl;
  final String garmentId;
  final String garmentImageUrl;
  final String resultImageUrl;

  TryOnResultModel({
    required this.id,
    required this.userId,
    required this.uploadedUserImageUrl,
    required this.garmentId,
    required this.garmentImageUrl,
    required this.resultImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'uploadedUserImageUrl': uploadedUserImageUrl,
      'garmentId': garmentId,
      'garmentImageUrl': garmentImageUrl,
      'resultImageUrl': resultImageUrl,
    };
  }

  factory TryOnResultModel.fromMap(Map<String, dynamic> map) {
    return TryOnResultModel(
      id: map['id'],
      userId: map['userId'],
      uploadedUserImageUrl: map['uploadedUserImageUrl'],
      garmentId: map['garmentId'],
      garmentImageUrl: map['garmentImageUrl'],
      resultImageUrl: map['resultImageUrl'],
    );
  }
}
