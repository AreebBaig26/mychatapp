import 'package:chatapp_real/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount, GoogleSignIn, GoogleSignInAuthentication;
import 'package:google_sign_in/google_sign_in.dart';

class Authmethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  getcurrentuser() async {
    return auth.currentUser;
  }

  signinWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignin = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount = await googleSignin
        .signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken,
    );
    UserCredential result = await firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;
    if (result != null) {
      Map<String, dynamic> userinfoMap = {
        "Name": userDetails!.displayName,
        "Email": userDetails.email,
        "Image": userDetails.photoURL,
        "Id": userDetails.uid,
      };
      await Databasemethods()
          .adduser(userinfoMap, userDetails.uid)
          .then((onValue) {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}











// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthMethods {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   Future<User?> getCurrentUser() async {
//     return _auth.currentUser;
//   }

//   Future<User?> signInWithGoogle(BuildContext context) async {
//     try {
//       // Step 1: Start Google Sign-In flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         // User cancelled
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Sign-in cancelled")),
//         );
//         return null;
//       }

//       // Step 2: Obtain auth details
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Step 3: Create new credential
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Step 4: Sign in with Firebase
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//       final User? user = userCredential.user;

//       if (user != null) {
//         print("✅ Signed in: ${user.displayName}");
//       }

//       return user;
//     } catch (e) {
//       print("❌ Error during Google Sign-In: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Sign-in failed: $e")),
//       );
//       return null;
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }