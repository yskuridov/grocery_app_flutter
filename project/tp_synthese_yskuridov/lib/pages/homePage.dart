import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tp_synthese_yskuridov/pages/products/products_page.dart';
import '../pages/groups/groups_page.dart';
import '../pages/groceries/groceries_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'L\'épicier',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: _buildPage(_currentTab),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.teal,
        backgroundColor: Colors.grey[300],
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        currentIndex: _currentTab,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Mes épiceries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Mes groupes',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const GroceriesPage();
      case 1:
        return const ProductsPage();
      case 2:
        return const GroupsPage();
      default:
        return const Center(
          child: Text("Page inexistante"),
        );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
