import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:tinyfal/src/models/notification.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/models/resource.dart';

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

    await users.doc(userId).set({"fcmToken": token ?? "", "email": email});
  }
}

// Function to create a new resource document for a user
Future<String> createResource(String userId, Resource resource) async {
  DocumentReference docRef = await users
      .doc(userId)
      .collection('resources')
      .add({
        'title': resource.title,
        'creation_timestamp': FieldValue.serverTimestamp(),
        'token': resource.token,
        'metrics': null, // Initialize with no metrics data
      });

  return docRef.id; // Return the auto-generated document ID
}

// Function to update a document under 'escritos' collection for a user
Future<void> updateResource(
  String userId,
  String resourceId,
  Resource resource,
) async {
  await users.doc(userId).collection('resources').doc(resourceId).set({
    'title': resource.title,
    'authorId': userId,
    'timestamp': FieldValue.serverTimestamp(),
    'token': resource.token,
    // Set timestamp in seconds
  });
}

// Function to update only the token field without affecting timestamp
Future<void> updateResourceToken(
  String userId,
  String resourceId,
  String token,
) async {
  await users.doc(userId).collection('resources').doc(resourceId).update({
    'token': token,
  });
}

// Function to get an 'Escrito' object from the database using an 'escritoId'
Future<Resource?> getResource(String userId, String escritoId) async {
  DocumentSnapshot doc = await users
      .doc(userId)
      .collection('resources')
      .doc(escritoId)
      .get();
  if (doc.exists) {
    return Resource.fromFirestore(doc, userId);
  }
  return null;
}

// Function to delete an 'Escrito' object from the database using an 'escritoId'
Future<void> deleteResource(String userId, String resourceId) async {
  await users.doc(userId).collection('resources').doc(resourceId).delete();
}

// Stream to get a list of 'Escrito' objects for a given user, sorted by timestamp
Stream<List<Resource>> getResourcesStream(String userId) {
  return users
      .doc(userId)
      .collection('resources')
      .orderBy('title', descending: true) // Sort by name
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Resource.fromFirestore(doc, userId))
            .toList();
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
