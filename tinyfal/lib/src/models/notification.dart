import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/services/database.dart';

class Notificacion {
  String title;
  String body;
  DateTime timestamp;
  String? escritoId;

  Notificacion({
    required this.title,
    required this.body,
    required this.timestamp,
    this.escritoId,
  });

  factory Notificacion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Notificacion(
      title: data['title'],
      body: data['body'],
      escritoId: data['escritoId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Future<Escrito?> fetchEscrito(String userId, String escritoId) async {
    return await getEscrito(userId, escritoId);
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'body': title, 'timestamp': timestamp};
  }
}
