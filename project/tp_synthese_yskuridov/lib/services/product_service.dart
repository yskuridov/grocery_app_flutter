import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final FirebaseFirestore _firestore;
  ProductService(this._firestore);

  Future<List<Product>> fetchProducts() async {
    return await _firestore.collection('products').get().then((snapshot) =>
        snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList());
  }

  Future<Product> createProduct(
      String name, String category, String imageUrl) async {
    DocumentReference productRef = await _firestore.collection('products').add({
      'name': name,
      'category': category,
      'addedBy': FirebaseAuth.instance.currentUser!.email,
      'imageUrl': imageUrl,
      'nutritionFacts': "",
    });
    final DocumentSnapshot snapshot = await productRef.get();
    return Product.fromSnapshot(snapshot);
  }

  Future<Product?> addByCupCode(String code) async {
    final url =
        "https://world.openfoodfacts.org/api/v2/search?code=$code&fields=product_name,categories,image_front_small_url,nutriments";

    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(utf8.decode(response.bodyBytes));

    if (json['count'] < 1 || await _productAlreadyExists(code)) return null;

    final imageUrl = json['products'][0]['image_front_small_url'];
    final name = json['products'][0]['product_name'] as String;
    final categories = (json['products'][0]['categories'] as String).split(',');

    final category = categories[0];

    Map<String, dynamic> nutritionFacts = json['products'][0]['nutriments'];

    String nutritionData = "";

    nutritionFacts.entries.take(10).forEach((entry) {
      final key = entry.key;
      final value = entry.value;
      nutritionData += "$key: $value, ";
    });

    await _firestore.collection('products').doc(code).set({
      'name': name,
      'category': category,
      'addedBy': FirebaseAuth.instance.currentUser!.email,
      'imageUrl': imageUrl,
      'nutritionFacts': nutritionData
    });
    Product product = await getProductById(code);
    print(product.name);
    return product;
  }

  Future<Product> getProductById(String id) async {
    return await _firestore
        .collection('products')
        .doc(id)
        .get()
        .then((snapshot) => Product.fromSnapshot(snapshot));
  }

  Future<bool> _productAlreadyExists(String code) async {
    final productsRef = await _firestore
        .collection('products')
        .where('id', isEqualTo: code)
        .get();
    if (productsRef.docs.isEmpty) return false;
    return true;
  }
}
