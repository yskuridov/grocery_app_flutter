import 'package:flutter/foundation.dart';
import '../services/grocery_service.dart';
import 'package:tp_synthese_yskuridov/models/grocery.dart';
import 'package:tp_synthese_yskuridov/models/group.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';

class GroceryProvider with ChangeNotifier {
  final GroceryService _groceryService;

  List<Grocery> _userGroceries = [];

  GroceryProvider(this._groceryService);

  List<Grocery> get groceries => _userGroceries;

  Future<void> fetchGroceries(List<Group> userGroups) async {
    try {
      _userGroceries = await _groceryService.fetchGroceries(userGroups);
      _sortAndSetActive();
    } catch (e) {
      _userGroceries = [];
    }
    notifyListeners();
  }

  void _sortAndSetActive() {
    if (_userGroceries.isNotEmpty) {
      _userGroceries.sort((a, b) => b.date.compareTo(a.date));
      //L'épicerie la plus récente est active
      for (var grocery in _userGroceries) {
        grocery.isActive = false;
      }
      _userGroceries.first.isActive = true;
    }
  }

  Future<void> addGroupToGrocery(String groupId, String groceryId) async {
    if (_groupExistsInGrocery(groceryId, groupId)) return;
    await _groceryService.addGroupToGrocery(groupId, groceryId);
    _userGroceries
        .firstWhere((grocery) => grocery.id == groceryId)
        .groupsIds
        .add(groupId);
    notifyListeners();
  }

  bool _groupExistsInGrocery(String groceryId, String groupId) {
    return _userGroceries
        .firstWhere((grocery) => grocery.id == groceryId)
        .groupsIds
        .any((id) => id == groupId);
  }

  Future<void> removeGroupFromGrocery(String groceryId, String groupId) async {
    await _groceryService.removeGroupFromGrocery(groceryId, groupId);
    _userGroceries
        .firstWhere((grocery) => grocery.id == groceryId)
        .groupsIds
        .remove(groupId);
    notifyListeners();
  }

  Future<void> createGrocery(String groceryName, DateTime date) async {
    if (_groceryExists(groceryName)) return;
    _userGroceries.add(await _groceryService.createGrocery(groceryName, date));
    _sortAndSetActive();
    notifyListeners();
  }

  bool _groceryExists(String name) {
    return _userGroceries.any((grocery) => grocery.name == name);
  }

  Future<void> deleteGrocery(String groceryId) async {
    if (_userGroceries
        .firstWhere((grocery) => grocery.id == groceryId)
        .isActive) return;
    await _groceryService.deleteGrocery(groceryId);
    _userGroceries.removeWhere((grocery) => grocery.id == groceryId);
    notifyListeners();
  }

  Future<void> addProductToGrocery(Product product) async {
    final activeGrocery =
        _userGroceries.firstWhere((grocery) => grocery.isActive);
    if (_productExistsInGrocery(product, activeGrocery)) return;
    await _groceryService.addProductToGrocery(product, activeGrocery.id);
    activeGrocery.products.add(product);
    notifyListeners();
  }

  bool _productExistsInGrocery(Product product, Grocery grocery) {
    return grocery.products.any((item) => item.id == product.id);
  }

  void setItemAsMissing(String groceryId, Product product) async {
    await _groceryService.setProductAsMissing(product, groceryId);
    _userGroceries
        .firstWhere((grocery) => grocery.id == groceryId)
        .products
        .firstWhere((item) => item.id == product.id)
        .isMissing = true;
    notifyListeners();
  }

  void setItemAsBought(String groceryId, Product product) async {
    await _groceryService.setProductAsBought(product, groceryId);
    _userGroceries
        .firstWhere((grocery) => grocery.id == groceryId)
        .products
        .firstWhere((item) => item.id == product.id)
        .boughtOn = DateTime.now();
    notifyListeners();
  }

  void updateProductOrder(String groceryId, List<Product> products) {
    _userGroceries.firstWhere((grocery) => grocery.id == groceryId).products =
        products;
    notifyListeners();
  }
}
