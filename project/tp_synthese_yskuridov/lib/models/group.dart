import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  int memberCount;
  List<dynamic> usersEmails;
  final String adminEmail;

  Group({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.usersEmails,
    required this.adminEmail,
  });

  Group.fromSnapshot(
      DocumentSnapshot snapshot, List<dynamic> usersEmailsFromSnapshot)
      : id = snapshot.id,
        name = snapshot['name'],
        memberCount = snapshot['memberCount'],
        usersEmails = usersEmailsFromSnapshot,
        adminEmail = snapshot['adminEmail'];

  void addUser(String email) {
    usersEmails.add(email);
    memberCount++;
  }

  void removeUser(String email) {
    usersEmails.remove(email);
    memberCount--;
  }
}
