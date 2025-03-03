class Photo{
  final int id;
  final String fileKey;
  final bool mainPhoto;

  Photo({
    required this.id,
    required this.fileKey,
    required this.mainPhoto,
  });

  factory Photo.fromJson(Map<String, dynamic> json){
    return Photo(
      id: json['id'],
      fileKey: json['fileKey'],
      mainPhoto: json['mainPhoto'] ?? false,
    );
  }
}