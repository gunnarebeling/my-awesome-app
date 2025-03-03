

import 'package:my_awesome_app/model/photo.dart';

class Sewclass {
  final int id;
  final String name;
  final String description;
  final int maxPeople;
  final double pricePerPerson;
  final int duration;
  final List<Photo> photos;

  Sewclass({
    required this.id,
    required this.name,
    required this.description,
    required this.maxPeople,
    required this.pricePerPerson,
    required this.duration,
    required this.photos,
  });

  factory Sewclass.fromJson(Map<String, dynamic> json) {
    return Sewclass(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      maxPeople: json['maxPeople'] as int,
      pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
      duration: json['duration'],
      photos: (json['photos'] as List).map((e) => Photo.fromJson(e)).toList(),
    );
  }

  static List<Sewclass> fromJsonList(List<dynamic> json) {
    return json.map((e) => Sewclass.fromJson(e)).toList();
  }

}