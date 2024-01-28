import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp_synthese_yskuridov/models/group.dart';
import '../../providers/groups_provider.dart';
import './group_page.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          var userGroups = groupProvider.userGroups;
          return Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Mes groupes',
                style: TextStyle(fontSize: 18, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: userGroups.length,
                  itemBuilder: (context, index) {
                    final Group group = userGroups[index];
                    return ListTile(
                      tileColor: Colors.grey[100],
                      trailing: Text(
                        'Rôle: ${group.adminEmail == FirebaseAuth.instance.currentUser!.email ? 'Administrateur' : 'Membre'}',
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Membres: ${group.memberCount}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupPage(group),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateGroupDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String groupName = '';

        return AlertDialog(
          title: const Text('Créer un groupe'),
          content: TextField(
            onChanged: (value) {
              groupName = value;
            },
            decoration: const InputDecoration(hintText: 'Nom du groupe'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Créer'),
              onPressed: () {
                final groupProvider =
                    Provider.of<GroupProvider>(context, listen: false);
                groupProvider.createGroup(groupName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
