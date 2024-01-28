import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/groups_provider.dart';
import 'package:tp_synthese_yskuridov/models/group.dart';

class GroupPage extends StatefulWidget {
  final Group group;

  const GroupPage(this.group, {Key? key}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          final isAdmin = widget.group.adminEmail ==
              FirebaseAuth.instance.currentUser!.email;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: widget.group.usersEmails.length,
                  itemBuilder: (context, index) {
                    final userEmail = widget.group.usersEmails[index];
                    return ListTile(
                      tileColor: Colors.grey[100],
                      title: Text(userEmail),
                      subtitle: userEmail == widget.group.adminEmail
                          ? const Text(
                              'Administrateur',
                              style: TextStyle(color: Colors.teal),
                            )
                          : const Text('Membre'),
                      trailing: isAdmin &&
                              userEmail !=
                                  FirebaseAuth.instance.currentUser!.email
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                groupProvider.removeUserFromGroup(
                                  widget.group.id,
                                  userEmail,
                                );
                                _showSnackbar(
                                    'L\'utilisateur a été retiré du groupe');
                              },
                            )
                          : userEmail ==
                                  FirebaseAuth.instance.currentUser!.email
                              ? const Text(
                                  'Vous',
                                  style: TextStyle(color: Colors.teal),
                                )
                              : null,
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isAdmin) {
                    groupProvider.deleteGroup(widget.group.id);
                  } else {
                    groupProvider.quitGroup(widget.group.id);
                  }
                  _showSnackbar('Vous avez quitté le groupe');
                  Navigator.pop(context);
                },
                child: const Text('Quitter le groupe'),
              ),
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            fillColor: Colors.teal,
                            labelText: 'Ajouter un utilisateur',
                            hintText: 'Adresse courriel de l\'utilisateur',
                          ),
                        ),
                      ),
                      IconButton(
                        color: Colors.teal,
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final emailToAdd = _emailController.text.trim();
                          final lengthBeforeAdd = widget.group.memberCount;
                          if (emailToAdd.isNotEmpty) {
                            try {
                              await groupProvider.addUserToGroup(
                                  widget.group.id, emailToAdd);
                            } catch (e) {
                              _showSnackbar('Utilisateur non trouvé');
                              _hideKeyboard();
                            }
                          }
                          if (lengthBeforeAdd < widget.group.memberCount) {
                            _showSnackbar('Utilisateur ajouté au groupe');
                            _emailController.clear();
                            _hideKeyboard();
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
