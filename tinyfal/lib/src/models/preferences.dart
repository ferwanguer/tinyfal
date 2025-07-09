import 'package:cloud_firestore/cloud_firestore.dart';

class Preferences {
  // This object is the client user which should contains preferences and anything useful related to the client

  String? description;
  String? web;
  String? username;
  bool isEscuelaEscritores;
  double textFontSize;
  String? sender;
  String? nickname;

  Preferences(
      {this.description,
      this.web,
      this.isEscuelaEscritores = false,
      this.username,
      this.sender,
      this.nickname,
      this.textFontSize = 14.0});

  static Preferences? fromFirestore(DocumentSnapshot<Object?> doc) {
    if (!doc.exists) {
      return null;
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String? sender;
    try {
      sender = data['sender'][0] as String?;
    } catch (e) {
      sender = null;
    }

    return Preferences(
        description: data['description'] as String?,
        web: data['web'] as String?,
        isEscuelaEscritores: data['isEscuelaEscritores'] as bool? ?? false,
        username: data['username'] as String?,
        textFontSize: data['textFontSize'] as double? ?? 14.0,
        nickname: data['nickname'] as String?,
        sender: sender);
  }
}
