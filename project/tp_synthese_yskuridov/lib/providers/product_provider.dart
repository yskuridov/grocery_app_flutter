import 'package:flutter/material.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';
import 'package:tp_synthese_yskuridov/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  ProductProvider(this._productService);

  List<Product> _products = [];

  List<Product> get products => _products;

  List<String> get categories =>
      _products.map((product) => product.category).toList();

  Future<void> fetchProducts() async {
    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      _products = [];
    }
    notifyListeners();
  }

  void createProduct(String name, String category, String imageUrl) async {
    _products
        .add(await _productService.createProduct(name, category, imageUrl));
    notifyListeners();
  }

  void createProductFromCupCode(String code) async {
    Product? product = await _productService.addByCupCode(code);
    if (product != null) {
      _products.add(product);
      notifyListeners();
    }
  }
}
