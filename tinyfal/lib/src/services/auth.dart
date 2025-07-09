import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tinyfal/src/models/client_user.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

Future<UserCredential?> signInWithGoogle() async {
  if (kIsWeb) {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope(
      'https://www.googleapis.com/auth/contacts.readonly',
    );
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  } else {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    try {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }
}

Future<UserCredential?> signInWithApple() async {
  final appleProvider = AppleAuthProvider();

  if (kIsWeb) {
    appleProvider.addScope('email');

    return await FirebaseAuth.instance.signInWithPopup(appleProvider);
  } else {
    try {
      final credential = await FirebaseAuth.instance.signInWithProvider(
        appleProvider,
      );
      print(credential);
      return credential;
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    }
  }
}

Future<UserCredential?> signInWithEmail(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } catch (e) {
    print('Error signing in with email: $e');
    rethrow;
  }
}

Future<UserCredential?> registerWithEmail(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return credential;
  } catch (e) {
    print('Error registering with email: $e');
    rethrow;
  }
}

Map<String, dynamic> userCredentialToMap(UserCredential userCredential) {
  final user = userCredential.user;
  return {
    'uid': user?.uid,
    'email': user?.email,
    'displayName': user?.displayName,
    'photoURL': user?.photoURL,
    'phoneNumber': user?.phoneNumber,
    'isEmailVerified': user?.emailVerified,
    'username': userCredential.additionalUserInfo?.username,
  };
}

Stream<ClientUser?> get user {
  return auth.authStateChanges().map(ClientUser.fromFirebaseUser);
}

// sign out
Future signOut() async {
  try {
    await auth.signOut();
    // Sign out from GoogleSignIn
    await GoogleSignIn().signOut();
    // Sign out from Apple
    // Note: Apple sign out does not have a direct method, but you can clear the session if needed
  } catch (e) {
    return null;
  }
}
