// import 'package:chatapp_real/services/database.dart';
// import 'package:chatapp_real/services/shared_pref.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// // import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount, GoogleSignIn, GoogleSignInAuthentication;
// import 'package:google_sign_in/google_sign_in.dart';

// class Authmethods {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   getcurrentuser() async {
//     return auth.currentUser;
//   }
//   signinWithGoogle(BuildContext context) async {
//     final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//     final GoogleSignIn googleSignin = GoogleSignIn();
//     final GoogleSignInAccount? googleSignInAccount = await googleSignin
//         .signIn();
//     final GoogleSignInAuthentication? googleSignInAuthentication =
//         await googleSignInAccount?.authentication;
//     final AuthCredential credential = GoogleAuthProvider.credential(
//       idToken: googleSignInAuthentication?.idToken,
//       accessToken: googleSignInAuthentication?.accessToken,
//     );
//     UserCredential result = await firebaseAuth.signInWithCredential(credential);
//     User? userDetails = result.user;
//     String username = userDetails!.email!.replaceAll("@gmail.com", "");
//     String firstLetter = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '';
//     await SharedPrefreferencesHelper().saveUserDisplayname(
//       userDetails.displayName!,
//     );
//     await SharedPrefreferencesHelper().saveUserEmail(userDetails.email!);
//     await SharedPrefreferencesHelper().saveUserId(userDetails.uid);
//     await SharedPrefreferencesHelper().saveUserImage(userDetails.photoURL!);
//     await SharedPrefreferencesHelper().SaveUsername(username);
//     if (result != null) {
//       Map<String, dynamic> userInfoMap = {
//         "Name": userDetails!.displayName,
//         "Email": userDetails.email,
//         "Image": userDetails.photoURL,
//         "Id": userDetails.uid,
//         "Username": username.toUpperCase(),
//         "Searchkey": firstLetter,
//       };
//       await Databasemethods().adduser(userInfoMap, userDetails!.uid).then((
//         onValue,
//       ) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: Colors.green,
//             content: Text(
//               "Registered Successfully",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         );
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => Home()),
//         // );
//       });
//     }
//   }
// }

import 'package:chatapp_real/pages/home.dart';
import 'package:chatapp_real/services/database.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authmethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<void> signinWithGoogle(BuildContext context) async {
    try {
      // Start Google Sign-In flow
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      // If user cancels sign-in
      if (googleAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-In cancelled by user."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get authentication from Google
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign-in failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Generate username safely
      String username = user.email!.split('@').first;
      String firstLetter = username.isNotEmpty
          ? username.substring(0, 1).toUpperCase()
          : '';

      // Save user data locally
      await SharedPrefreferencesHelper().saveUserDisplayname(
        user.displayName ?? '',
      );
      await SharedPrefreferencesHelper().saveUserEmail(user.email ?? '');
      await SharedPrefreferencesHelper().saveUserId(user.uid);
      await SharedPrefreferencesHelper().saveUserImage(user.photoURL ?? '');
      await SharedPrefreferencesHelper().SaveUsername(username);

      // Prepare user info map for Firestore or Realtime DB
      Map<String, dynamic> userInfoMap = {
        "Name": user.displayName ?? "",
        "Email": user.email ?? "",
        "Image": user.photoURL ?? "",
        "Id": user.uid,
        "Username": username.toUpperCase(),
        "Searchkey": firstLetter,
      };

      // Save user info in Firestore/Realtime DB
      await Databasemethods().adduser(userInfoMap, user.uid);

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Registered Successfully!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Optional: navigate to home screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase Error: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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