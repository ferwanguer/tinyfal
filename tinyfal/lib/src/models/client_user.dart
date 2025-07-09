import 'package:firebase_auth/firebase_auth.dart';
import 'package:tinyfal/src/services/database.dart';

class ClientUser {
  // This object is the client user which should contains preferences and anything useful related to the client

  final String uid;
  final String? email;
  final String? description;
  final String? twitter;
  final String? instagram;
  final String? web;
  final String? phoneNumber;
  final String? photoUrl;
  final String? providerId;

  ClientUser({
    required this.uid,
    this.description,
    this.email,
    this.twitter,
    this.instagram,
    this.web,
    this.phoneNumber,
    this.photoUrl,
    this.providerId,
  });

  // Conversion methods
  static ClientUser? fromFirebaseUser(User? user) {
    if (user != null) {
      //TODO Mirar eseta mierda
      ClientUser clientUser = ClientUser(
        uid: user.uid.toLowerCase(),
        email: user.email,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        providerId: user.providerData[0].providerId,
      );

      postFirstTimeToFirestore(user);

      return clientUser;
    }
    return null;
  }

  static void postFirstTimeToFirestore(User? user) {
    if (user != null) {
      createUserPreference(
        user.uid.toLowerCase(),
        user.email ?? "",
      ); // Implement the function to post info to Firestore
    }
  }
}
