import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tp_synthese_yskuridov/pages/authentication/auth_page.dart';
import 'package:tp_synthese_yskuridov/firebase_options.dart';
import 'package:tp_synthese_yskuridov/pages/homePage.dart';
import 'package:provider/provider.dart';
import 'package:tp_synthese_yskuridov/providers/groceries_provider.dart';
import 'package:tp_synthese_yskuridov/providers/product_provider.dart';
import 'package:tp_synthese_yskuridov/services/grocery_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tp_synthese_yskuridov/services/product_service.dart';
import './providers/groups_provider.dart';
import './services/group_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.signOut();

  final firestore = FirebaseFirestore.instance;
  final ProductService productService = ProductService(firestore);
  final GroupService groupService = GroupService(firestore);
  final GroceryService groceryService = GroceryService(firestore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GroceryProvider>(
          create: (_) => GroceryProvider(
            groceryService,
          ),
        ),
        ChangeNotifierProvider<GroupProvider>(
          create: (_) => GroupProvider(
            groupService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            productService,
          ),
        )
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 50, child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.teal,
            ),
            home: const Center(
              child: Text("PROBLEME!!!"),
            ),
          );
        }
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 15),
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
                .copyWith(background: Colors.grey),
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  FirebaseAuth.instance.currentUser != null) {
                final groupProvider =
                    Provider.of<GroupProvider>(context, listen: false);
                final groceryProvider =
                    Provider.of<GroceryProvider>(context, listen: false);
                final productProvider =
                    Provider.of<ProductProvider>(context, listen: false);
                return FutureBuilder(
                  future: groupProvider
                      .fetchUserGroups(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('ERREUR!!!'));
                    } else {
                      groceryProvider.fetchGroceries(groupProvider.userGroups);
                      productProvider.fetchProducts();
                      return HomePage();
                    }
                  },
                );
              } else {
                return const AuthenticationScreen();
              }
            },
          ),
        );
      },
    );
  }
}
