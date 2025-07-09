import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/comment.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';

class Escrito {
  String? uid;
  String? title;
  String? text;
  String visibility;
  String category;
  ClientUser? clientUser;
  List<Comment> comments = [];

  Escrito({
    this.title,
    this.text,
    required this.uid,
    required this.clientUser,
    required this.visibility,
    required this.category,
    this.comments = const [],
  });

  Future<void> uploadToFirestore() async {
    await updateEscrito(clientUser!.uid, uid!, this);
  }

  Future<void> deleteFromFirestore() async {
    await deleteEscrito(clientUser!.uid, uid!);
  }

  factory Escrito.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Escrito(
      uid: doc.id,
      title: data['title'],
      text: data['text'],
      visibility: data['visibility'],
      category: data['category'],
      clientUser: ClientUser(uid: data['authorId']),
    );
  }
}
