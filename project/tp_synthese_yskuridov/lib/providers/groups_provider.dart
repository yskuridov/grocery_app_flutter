import 'package:flutter/foundation.dart';
import '../services/group_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tp_synthese_yskuridov/models/group.dart';

class GroupProvider with ChangeNotifier {
  final GroupService _groupService;

  GroupProvider(this._groupService);

  List<Group> _userGroups = [];

  List<Group> get userGroups => _userGroups;

  List<dynamic> getGroupEmails(String groupId) {
    return _userGroups.firstWhere((group) => group.id == groupId).usersEmails;
  }

  Future<void> fetchUserGroups(String userId) async {
    try {
      _userGroups = await _groupService.getUserGroups(userId);
    } catch (e) {
      _userGroups = [];
    }
    notifyListeners();
  }

  Future<void> createGroup(String name) async {
    if (groupExists(name)) return;
    await _groupService.createGroup(name);
    await fetchUserGroups(FirebaseAuth.instance.currentUser!.uid);
    notifyListeners();
  }

  Future<void> deleteGroup(String groupId) async {
    await _groupService.deleteGroup(groupId);
    _userGroups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }

  Future<void> addUserToGroup(String groupId, String userEmail) async {
    if (_userInGroup(groupId, userEmail)) return;
    await _groupService.addUserToGroup(groupId, userEmail);
    Group group = _userGroups.firstWhere((group) => group.id == groupId);
    group.addUser(userEmail);
    notifyListeners();
  }

  Future<void> removeUserFromGroup(String groupId, String userEmail) async {
    await _groupService.removeUserFromGroup(groupId, userEmail);
    _userGroups
        .firstWhere((group) => group.id == groupId)
        .removeUser(userEmail);
    notifyListeners();
  }

  Future<void> quitGroup(String groupId) async {
    await _groupService.removeUserFromGroup(
        groupId, FirebaseAuth.instance.currentUser!.email!);
    _userGroups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }

  bool _userInGroup(String groupId, String userEmail) {
    return _userGroups
        .firstWhere((group) => group.id == groupId)
        .usersEmails
        .contains(userEmail);
  }

  bool groupExists(String groupName) {
    return _userGroups.any((group) => group.name == groupName);
  }
}
