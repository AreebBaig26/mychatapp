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
}
