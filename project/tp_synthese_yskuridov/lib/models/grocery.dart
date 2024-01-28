import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';

class Grocery {
  final String id;
  final String name;
  final DateTime date;
  final String createdBy;
  bool isActive = false;
  List<dynamic> groupsIds = [];
  List<Product> products = [];

  Grocery(
      {required this.id,
      required this.name,
      required this.date,
      required this.createdBy,
      required this.groupsIds,
      required this.products});

  Grocery.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        name = snapshot['name'],
        date = (snapshot['date'] as Timestamp).toDate(),
        createdBy = snapshot['createdBy'],
        groupsIds = snapshot['groups'],
        products = (snapshot['products'] as List<dynamic>)
            .map((item) => Product.fromJson(item))
            .toList();

  void addGroupId(String id) {
    groupsIds.add(id);
  }

  void removeGroupId(String id) {
    groupsIds.removeWhere((groupId) => groupId == id);
  }

  void toggleActive() {
    isActive = !isActive;
  }

  void addProduct(Product product) {
    products.add(product);
  }

  void removeProduct(Product product) {
    products.removeWhere((item) => item.id == product.id);
  }
}
