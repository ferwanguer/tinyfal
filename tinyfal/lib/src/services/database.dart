import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:tinyfal/src/models/notification.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/models/escrito.dart';

// Collections ============================================================================================
late CollectionReference users = FirebaseFirestore.instance.collection('users');
// ========================================================================================================

// POST TO THE DATABASE OPERATIONS
// beware of the SET method, it will overwrite the document if it already exists.
Future<void> setUserPreferences(
  String userId,
  Map<String, dynamic> preferences,
) async {
  await users.doc(userId).set(preferences);
}

// QUERY STREAM OF PREFERENCES

// Getter for the company preferences
Future<Preferences?> getPreferences(String userId) {
  return users.doc(userId).get().then((doc) {
    return Preferences.fromFirestore(doc);
  });
}

// Getter for the company preferences as a Stream
Stream<Preferences?> getPreferencesStream(String userId) {
  return users.doc(userId).snapshots().map((doc) {
    return Preferences.fromFirestore(doc);
  });
}

// UPDATE SPECIFIC FIELD OF PREFERENCES

Future<void> updateUserPreferenceField(
  String userId,
  String field,
  dynamic value,
) async {
  await users.doc(userId).update({field: value});
}

Future<void> createUserPreference(String userId, String email) async {
  DocumentSnapshot doc = await users.doc(userId).get();

  if (doc.exists) {
    // Document exists
  } else {
    // Document does not exist
    String? token;

    if (Platform.isIOS) {
      // APNs token is available, use it for iOS devices
      await FirebaseMessaging.instance.getAPNSToken();
      token = await FirebaseMessaging.instance.getToken();
    } else {
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('Error getting FCM token: $e');
      }
    }

    await users.doc(userId).set({
      "fcmToken": token ?? "notnow",
      "email": email,
    });
  }
}

// Function to update a document under 'escritos' collection for a user
Future<void> updateEscrito(
  String userId,
  String escritoId,
  Escrito escrito,
) async {
  await users.doc(userId).collection('escritos').doc(escritoId).set({
    'title': escrito.title,
    'title_lower': escrito.title?.toLowerCase(),
    'text': escrito.text,

    'visibility': escrito.visibility,
    'category': escrito.category,
    'authorId': userId,
    'timestamp': FieldValue.serverTimestamp(),
    // Set timestamp in seconds
  });
}

// Function to get an 'Escrito' object from the database using an 'escritoId'
Future<Escrito?> getEscrito(String userId, String escritoId) async {
  DocumentSnapshot doc = await users
      .doc(userId)
      .collection('escritos')
      .doc(escritoId)
      .get();
  if (doc.exists) {
    return Escrito.fromFirestore(doc);
  }
  return null;
}

// Function to delete an 'Escrito' object from the database using an 'escritoId'
Future<void> deleteEscrito(String userId, String escritoId) async {
  await users.doc(userId).collection('escritos').doc(escritoId).delete();
}

// Stream to get a list of 'Escrito' objects for a given user, sorted by timestamp
Stream<List<Escrito>> getEscritosStream(String userId) {
  return users
      .doc(userId)
      .collection('escritos')
      .orderBy('timestamp', descending: true) // Sort by timestamp
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Escrito.fromFirestore(doc)).toList();
      });
}

// Stream to get a list of 'Escrito' objects for a given user, sorted by timestamp
Stream<List<Notificacion>> getNotificacionsStream(String userId) {
  return users
      .doc(userId)
      .collection('notifications')
      .orderBy('timestamp', descending: true) // Sort by timestamp
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Notificacion.fromFirestore(doc))
            .toList();
      });
}

Stream<List<Escrito?>> get publicEscritos {
  return FirebaseFirestore.instance
      .collectionGroup("escritos")
      .where('visibility', isNotEqualTo: "privado")
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Escrito.fromFirestore(doc)).toList();
      });
}

// Function to search for 'Escrito' objects based on a search text
Stream<List<Escrito>> searchEscritos(String searchText) {
  return FirebaseFirestore.instance
      .collectionGroup('escritos')
      .where('visibility', isNotEqualTo: 'privado')
      .orderBy('title_lower')
      .startAt([searchText])
      .endAt(['$searchText\uf8ff'])
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Escrito.fromFirestore(doc)).toList();
      });
}
