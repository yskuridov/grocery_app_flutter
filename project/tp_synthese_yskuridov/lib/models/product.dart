import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String addedBy;
  final String category;
  final String imageUrl;
  String? nutritionFacts;
  bool isMissing = false;
  DateTime? boughtOn;

  Product({
    required this.id,
    required this.name,
    required this.addedBy,
    required this.category,
    required this.nutritionFacts,
    required this.imageUrl,
  });

  Product.fromSnapshot(DocumentSnapshot snapshot) //fetch des produits
      : id = snapshot.id,
        name = snapshot['name'],
        addedBy = snapshot['addedBy'],
        category = snapshot['category'],
        nutritionFacts = snapshot['nutritionFacts'],
        imageUrl = snapshot['imageUrl'];

  Product.fromJson(
      Map<String, dynamic> json) //fetch des produits d'une epicerie
      : id = json['id'],
        name = json['name'],
        addedBy = json['addedBy'],
        category = json['category'],
        imageUrl = json['imageUrl'],
        isMissing = json['isMissing'],
        boughtOn = json['boughtOn'] != null
            ? (json['boughtOn'] as Timestamp).toDate()
            : null;

  Map<String, dynamic> toGroceryMap() {
    return {
      'id': id,
      'name': name,
      'addedBy': addedBy,
      'category': category,
      'imageUrl': imageUrl,
      'isMissing': isMissing,
      'boughtOn': boughtOn
    };
  }

  set bought(DateTime? time) {
    boughtOn = time;
  }

  set missing(bool value) {
    isMissing = value;
  }
}
