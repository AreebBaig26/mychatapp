import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Databasemethods {
  Future adduser(Map<String, dynamic> userinfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userinfoMap);
    // class Databasemethods {
    //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    //   // ✅ Add this method to save user info
    //   Future<void> addUser(Map<String, dynamic> userInfoMap, String userId) async {
    //     await _firestore.collection('users').doc(userId).set(userInfoMap);
    //   }

    //   // ✅ Optional: Add this method if you need user search
    //   Future<QuerySnapshot> searchUser(String username) async {
    //     return await _firestore
    //         .collection('users')
    //         .where('username', isGreaterThanOrEqualTo: username)
    //         .where('username', isLessThan: username + 'z')
    //         .get();
    //   }
  }

  Future addMessge(
    String chatroomId,
    String messageId,
    Map<String, dynamic> messageInfoMap,
  ) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Updatelastmessagesend(
    String chatroomId,
    Map<String, dynamic> LastMessaggeInfoMap,
  ) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .update(LastMessaggeInfoMap);
  }

  Search(String username) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("Username", isGreaterThanOrEqualTo: username)
        .where("Username", isLessThanOrEqualTo: username + '\uf8ff')
        .get();
  }

  // Future<QuerySnapshot> Search(String username) async {
  //   return await FirebaseFirestore.instance
  //       .collection("users")
  //       .where("SearchKey", isEqualTo: username.substring(0, 1).toUpperCase())
  //       .get();
  // }

  createChatRoom(
    String ChatRoomId,
    Map<String, dynamic> ChatRoomInfoMap,
  ) async {
    final Snapshot = await FirebaseFirestore.instance
        .collection("Chatrooms")
        .doc(ChatRoomId)
        .get();
    if (Snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(ChatRoomId)
          .set(ChatRoomInfoMap);
    }
  }
}
