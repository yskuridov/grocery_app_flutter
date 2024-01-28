import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tp_synthese_yskuridov/models/group.dart';
import 'package:tp_synthese_yskuridov/models/grocery.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';

class GroceryService {
  final FirebaseFirestore _firestore;

  GroceryService(this._firestore);

  Future<List<Grocery>> fetchGroceries(List<Group> userGroups) async {
    List<dynamic> userGroupsIds = [];
    for (Group group in userGroups) {
      userGroupsIds.add(group.id);
    }

    final groceries = <Grocery>[];

    final groupGroceries = await _firestore
        .collection('groceries')
        .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    final userGroceries = await _firestore
        .collection('groceries')
        .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    final groceryDocs = [...groupGroceries.docs, ...userGroceries.docs];

    for (final doc in groceryDocs) {
      if (groceries.any((grocery) => grocery.id == doc.id)) {
        continue; //Si le groupe est déjà dans la liste
      }
      groceries.add(Grocery.fromSnapshot(doc));
    }
    return groceries;
  }

  Future<void> addGroupToGrocery(String groupId, String groceryId) async {
    _firestore.collection('groceries').doc(groceryId).update({
      'groups': FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> removeGroupFromGrocery(String groceryId, String groupId) async {
    _firestore.collection('groceries').doc(groceryId).update({
      'groups': FieldValue.arrayRemove([groupId]),
    });
  }

  Future<Grocery> createGrocery(String groceryName, DateTime date) async {
    final DocumentReference groceryRef =
        await _firestore.collection('groceries').add({
      'name': groceryName,
      'date': date,
      'createdBy': FirebaseAuth.instance.currentUser!.email,
      'groups': [],
      'products': [],
    });

    final DocumentSnapshot snapshot = await groceryRef.get();
    return Grocery.fromSnapshot(snapshot);
  }

  Future<void> deleteGrocery(String groceryId) async {
    await _firestore.collection('groceries').doc(groceryId).delete();
  }

  Future<void> setProductAsMissing(Product product, String groceryId) async {
    await _removeProductFromGrocery(product, groceryId);
    product.isMissing = true;
    await addProductToGrocery(product, groceryId);
  }

  Future<void> setProductAsBought(Product product, String groceryId) async {
    await _removeProductFromGrocery(product, groceryId);
    product.boughtOn = DateTime.now();
    await addProductToGrocery(product, groceryId);
  }

  Future<void> _removeProductFromGrocery(
      Product product, String groceryId) async {
    await _firestore.collection('groceries').doc(groceryId).update({
      'products': FieldValue.arrayRemove([product.toGroceryMap()])
    });
  }

  Future<void> addProductToGrocery(Product product, String groceryId) async {
    await _firestore.collection('groceries').doc(groceryId).update({
      'products': FieldValue.arrayUnion([product.toGroceryMap()])
    });
  }
}
