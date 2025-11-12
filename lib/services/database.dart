import 'package:chatapp_real/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Databasemethods {
  // Add user to Firestore
  Future adduser(Map<String, dynamic> userinfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userinfoMap);
  }

  // Create chatroom if not exists
  Future createChatRoom(
    String chatRoomId,
    Map<String, dynamic> chatRoomInfoMap,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (!snapshot.exists) {
      return await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    } else {
      return true;
    }
  }

  // Add message to chats subcollection
  Future addMessage(
    String chatroomId,
    String messageId,
    Map<String, dynamic> messageInfoMap,
  ) async {
    print("DEBUG -> chatrooms/$chatroomId/chats/$messageId");
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  // Update last message info in chatroom
  Future updateLastMessageSend(
    String chatroomId,
    Map<String, dynamic> lastMessageInfoMap,
  ) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .update(lastMessageInfoMap);
  }

  // Search users by username
  Future Search(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Username", isGreaterThanOrEqualTo: username)
        .where("Username", isLessThanOrEqualTo: username + '\uf8ff')
        .get();
  }

  // Get user info by username
  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Username", isEqualTo: username)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myusername = await SharedPrefreferencesHelper().getUserName();
    print("DEBUG → My username for chatroom filter: $myusername");

    return FirebaseFirestore.instance
        .collection("chatrooms")
        .where("users", arrayContains: myusername)
        .orderBy("lastmessagesendts", descending: true)
        .snapshots();
  }

  // Get all chatrooms of current user
  // Future<Stream<QuerySnapshot>> getChatRooms() async {
  //   String? myusername = await SharedPrefreferencesHelper().getUserName();
  //   return FirebaseFirestore.instance
  //       .collection("chatrooms")
  //       .where("users", arrayContains: myusername)
  //       .orderBy("lastmessagesendts", descending: true)
  //       .snapshots();
  // }
}

// import 'package:chatapp_real/services/shared_pref.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Databasemethods {
//   // Add user to Firestore
//   Future adduser(Map<String, dynamic> userinfoMap, String id) async {
//     return await FirebaseFirestore.instance
//         .collection("users")
//         .doc(id)
//         .set(userinfoMap);
//   }

//   // Create chatroom if not exists
//   Future createChatRoom(
//     String chatRoomId,
//     Map<String, dynamic> chatRoomInfoMap,
//   ) async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection("chatrooms") // lowercase 'c'
//         .doc(chatRoomId)
//         .get();

//     if (!snapshot.exists) {
//       return await FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(chatRoomId)
//           .set(chatRoomInfoMap);
//     } else {
//       return true;
//     }
//   }

//   // Add message to chats subcollection
//   Future addMessge(
//     String chatroomId,
//     String messageId,
//     Map<String, dynamic> messageInfoMap,
//   ) async {
//     print("DEBUG -> chatrooms/$chatroomId/chats/$messageId"); // debug
//     return await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(chatroomId)
//         .collection("chats")
//         .doc(messageId)
//         .set(messageInfoMap);
//   }

//   // Update last message info in chatroom
//   Future Updatelastmessagesend(
//     String chatroomId,
//     Map<String, dynamic> lastMessageInfoMap,
//   ) async {
//     return FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(chatroomId)
//         .update(lastMessageInfoMap);
//   }

//   // Search users by username
//   Future Search(String username) async {
//     return await FirebaseFirestore.instance
//         .collection("users")
//         .where("Username", isGreaterThanOrEqualTo: username)
//         .where("Username", isLessThanOrEqualTo: username + '\uf8ff')
//         .get();
//   }

//   Future<QuerySnapshot> getUserInfo(String username) async {
//     return await FirebaseFirestore.instance
//         .collection("users")
//         .where("Username", isEqualTo: username)
//         .get();
//   }

//   Future<Stream<QuerySnapshot>> getChatRooms() async {
//     String? myusername = await SharedPrefreferencesHelper().getUserName();
//     return await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .orderBy("time", descending: true)
//         .where("users", arrayContains: myusername!)
//         .snapshots();
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';

// class Databasemethods {
//   Future adduser(Map<String, dynamic> userinfoMap, String id) async {
//     return await FirebaseFirestore.instance
//         .collection("users")
//         .doc(id)
//         .set(userinfoMap);
//     // class Databasemethods {
//     //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//     //   // ✅ Add this method to save user info
//     //   Future<void> addUser(Map<String, dynamic> userInfoMap, String userId) async {
//     //     await _firestore.collection('users').doc(userId).set(userInfoMap);
//     //   }

//     //   // ✅ Optional: Add this method if you need user search
//     //   Future<QuerySnapshot> searchUser(String username) async {
//     //     return await _firestore
//     //         .collection('users')
//     //         .where('username', isGreaterThanOrEqualTo: username)
//     //         .where('username', isLessThan: username + 'z')
//     //         .get();
//     //   }
//   }

//   Future addMessge(
//     String chatroomId,
//     String messageId,
//     Map<String, dynamic> messageInfoMap,
//   ) async {
//     print(
//       "DEBUG -> chatrooms/$chatroomId/chats/$messageId",
//     ); // 👈 add this line

//     return await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(chatroomId)
//         .collection("chats")
//         .doc(messageId)
//         .set(messageInfoMap);
//   }

//   // Future addMessge(
//   //   String chatroomId,
//   //   String messageId,
//   //   Map<String, dynamic> messageInfoMap,
//   // ) async {
//   //   return await FirebaseFirestore.instance
//   //       .collection("chatrooms")
//   //       .doc(chatroomId)
//   //       .collection("chats")
//   //       .doc(messageId)
//   //       .set(messageInfoMap);
//   // }

//   Updatelastmessagesend(
//     String chatroomId,
//     Map<String, dynamic> LastMessaggeInfoMap,
//   ) async {
//     return FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(chatroomId)
//         .update(LastMessaggeInfoMap);
//   }

//   Search(String username) {
//     return FirebaseFirestore.instance
//         .collection("users")
//         .where("Username", isGreaterThanOrEqualTo: username)
//         .where("Username", isLessThanOrEqualTo: username + '\uf8ff')
//         .get();
//   }

//   // Future<QuerySnapshot> Search(String username) async {
//   //   return await FirebaseFirestore.instance
//   //       .collection("users")
//   //       .where("SearchKey", isEqualTo: username.substring(0, 1).toUpperCase())
//   //       .get();
//   // }

//   createChatRoom(
//     String ChatRoomId,
//     Map<String, dynamic> ChatRoomInfoMap,
//   ) async {
//     final Snapshot = await FirebaseFirestore.instance
//         .collection("Chatrooms")
//         .doc(ChatRoomId)
//         .get();
//     if (Snapshot.exists) {
//       return true;
//     } else {
//       return FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(ChatRoomId)
//           .set(ChatRoomInfoMap);
//     }
//   }
// }
