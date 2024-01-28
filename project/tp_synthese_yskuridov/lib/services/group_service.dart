import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tp_synthese_yskuridov/models/group.dart';

class GroupService {
  final FirebaseFirestore _firestore;

  GroupService(this._firestore);

  Future<List<Group>> getUserGroups(String userId) async {
    final groups = <Group>[];

    //On retrouve les ids des groupes de l'utilisateur courant
    final groupUserQuery = await _firestore
        .collection('groupUser')
        .where('userId', isEqualTo: userId)
        .get();

    final userGroupsIds =
        groupUserQuery.docs.map((doc) => doc['groupId']).toList();

    //On retrouve les groupes de l'utilisateur courant
    final List<DocumentSnapshot> userGroups = [];
    for (final groupId in userGroupsIds) {
      final groupQuery =
          await _firestore.collection('groups').doc(groupId).get();
      if (groupQuery.exists) {
        userGroups.add(groupQuery);
      }
    }

    //On retrouve les utilisateurs de chaque groupe
    for (final groupe in userGroups) {
      final groupUserQuery = await _firestore
          .collection('groupUser')
          .where('groupId', isEqualTo: groupe.id)
          .get();

      final userIds = groupUserQuery.docs.map((doc) => doc['userId']).toList();

      final group =
          Group.fromSnapshot(groupe, await _getGroupUsersEmails(userIds));
      groups.add(group);
    }
    return groups;
  }

  Future<List> _getGroupUsersEmails(ids) async {
    List<dynamic> userEmails = [];
    for (final userId in ids) {
      final userEmail =
          await _firestore.collection('users').doc(userId).get().then((value) {
        return value['email'];
      });
      userEmails.add(userEmail);
    }
    return userEmails;
  }

  Future<void> createGroup(String name) async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    //On crée le groupe et on ajoute l'utilisateur comme admin
    final group = await _firestore.collection('groups').add({
      'name': name,
      'memberCount': 1,
      'adminEmail': userEmail,
    });
    //On crée une entrée dans la table groupUser
    await _firestore.collection('groupUser').add({
      'groupId': group.id,
      'userId': await _getUserIdFromEmail(userEmail!),
    });
  }

  Future<void> deleteGroup(String groupId) async {
    //On supprime le groupe et ses références dans la table groupUser
    await _firestore.collection('groups').doc(groupId).delete();
    await _firestore
        .collection('groupUser')
        .where('groupId', isEqualTo: groupId)
        .get()
        .then((data) {
      for (var element in data.docs) {
        element.reference.delete();
      }
    });
  }

  Future<void> addUserToGroup(String groupId, String userEmail) async {
    String userId = '';
    userId = await _getUserIdFromEmail(userEmail);
    await _firestore.collection('groupUser').add({
      'groupId': groupId,
      'userId': userId,
    });
    await _firestore.collection('groups').doc(groupId).update({
      'memberCount': FieldValue.increment(1),
    });
  }

  Future<void> removeUserFromGroup(String groupId, String userEmail) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberCount': FieldValue.increment(-1),
    });
    String userId = await _getUserIdFromEmail(userEmail);
    await _firestore
        .collection('groupUser')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .get()
        .then((data) => data.docs.first.reference.delete());
  }

  Future<String> _getUserIdFromEmail(String email) {
    return _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) => value.docs.first.id);
  }
}
