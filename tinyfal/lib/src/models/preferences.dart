import 'package:cloud_firestore/cloud_firestore.dart';

class Preferences {
  // This object is the client user which should contains preferences and anything useful related to the client

  String? sender;

  Preferences({this.sender});

  static Preferences? fromFirestore(DocumentSnapshot<Object?> doc) {
    if (!doc.exists) {
      return null;
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String? sender;
    try {
      sender = data['email'] as String?;
    } catch (e) {
      sender = null;
    }

    return Preferences(sender: sender);
  }
}
