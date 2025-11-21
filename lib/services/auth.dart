// import 'package:chatapp_real/pages/home.dart';
// import 'package:chatapp_real/services/database.dart';
// import 'package:chatapp_real/services/shared_pref.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class Authmethods {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // Get current user
//   User? get currentUser => _auth.currentUser;

//   // Sign in with Google
//   Future<void> signinWithGoogle(BuildContext context) async {
//     try {
//       // Start Google Sign-In flow
//       final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

//       // If user cancels sign-in
//       if (googleAccount == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Google Sign-In cancelled by user."),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         return;
//       }

//       // Get authentication from Google
//       final GoogleSignInAuthentication googleAuth =
//           await googleAccount.authentication;

//       // Create Firebase credential
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in with Firebase
//       final UserCredential userCredential = await _auth.signInWithCredential(
//         credential,
//       );
//       final User? user = userCredential.user;

//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Sign-in failed. Please try again."),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // Generate username safely
//       String username = user.email!.split('@').first;
//       String firstLetter = username.isNotEmpty
//           ? username.substring(0, 1).toUpperCase()
//           : '';

//       // Save user data locally
//       await SharedPrefreferencesHelper().saveUserDisplayname(
//         user.displayName ?? '',
//       );
//       await SharedPrefreferencesHelper().saveUserEmail(user.email ?? '');
//       await SharedPrefreferencesHelper().saveUserId(user.uid);
//       await SharedPrefreferencesHelper().saveUserImage(user.photoURL ?? '');
//       await SharedPrefreferencesHelper().SaveUsername(username);

//       // Prepare user info map for Firestore or Realtime DB
//       Map<String, dynamic> userInfoMap = {
//         "Name": user.displayName ?? "",
//         "Email": user.email ?? "",
//         "Image": user.photoURL ?? "",
//         "Id": user.uid,
//         "Username": username.toUpperCase(),
//         "Searchkey": firstLetter,
//       };

//       // Save user info in Firestore/Realtime DB
//       await Databasemethods().adduser(userInfoMap, user.uid);

//       // Success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.green,
//           content: Text(
//             "Registered Successfully!",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       );

//       // Optional: navigate to home screen after successful login
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Home()),
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Firebase Error: ${e.message}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//       );
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
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        // User cancelled sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-In cancelled by user."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

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

      // Generate username safely (LOWERCASE for comparison consistency)
      String username = user.email!.split('@').first.toLowerCase(); 
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
      // Saving the generated LOWERCASE username
      await SharedPrefreferencesHelper().SaveUsername(username); 

      // Prepare user info map for Firestore. Saving Username in UPPERCASE for search.
      Map<String, dynamic> userInfoMap = {
        "Name": user.displayName ?? "",
        "Email": user.email ?? "",
        "Image": user.photoURL ?? "",
        "Id": user.uid,
        "Username": username.toUpperCase(), // Storing uppercase for search
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

      // Navigate to home screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
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