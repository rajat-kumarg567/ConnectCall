import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Live list of every other registered user (used by the Contacts screen).
  Stream<List<UserModel>> contactsStream() {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return _db.collection(AppConstants.usersCollection).snapshots().map(
          (snap) => snap.docs
              .where((d) => d.id != myUid)
              .map((d) => UserModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection(AppConstants.usersCollection).doc(uid).snapshots().map(
          (d) => d.exists ? UserModel.fromMap(d.data()!, d.id) : null,
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateProfile({required String uid, String? name, String? photoUrl}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isEmpty) return;
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  /// Simple client-side search over the cached contact list (fine for an
  /// assignment-scale user base; swap for Algolia/Firestore array-contains
  /// indexing if the user base grows).
  List<UserModel> filter(List<UserModel> all, String query) {
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((u) => u.name.toLowerCase().contains(q)).toList();
  }
}
