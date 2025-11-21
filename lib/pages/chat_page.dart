// import 'package:chatapp_real/services/database.dart';
// import 'package:chatapp_real/services/shared_pref.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:random_string/random_string.dart';

// class ChatPage extends StatefulWidget {
//   final String name;
//   final String profileurl;
//   final String username;

//   const ChatPage({
//     Key? key,
//     required this.name,
//     required this.profileurl,
//     required this.username,
//   }) : super(key: key);

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   String? myUsername, myName, myEmail, myPicture, chatroomId, messageId;
//   TextEditingController messageController = TextEditingController();
//   ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     getSharedPref();
//   }

//   getSharedPref() async {
//     myUsername = await SharedPrefreferencesHelper().getUserName();
//     myName = await SharedPrefreferencesHelper().GetUserDisplayName();
//     myEmail = await SharedPrefreferencesHelper().GetUserEmail();
//     myPicture = await SharedPrefreferencesHelper().GetUserImage();

//     chatroomId = getChatRoomIdByUsernames(widget.username, myUsername!);
//     setState(() {});
//   }

//   String getChatRoomIdByUsernames(String a, String b) {
//     if (a.compareTo(b) > 0) {
//       return "${b}_$a";
//     } else {
//       return "${a}_$b";
//     }
//   }

//   addMessage(bool sendClicked) async {
//     if (messageController.text.trim().isEmpty) return;

//     String message = messageController.text.trim();
//     messageController.clear();

//     DateTime now = DateTime.now();
//     String formattedDate = DateFormat('h:mma').format(now);

//     Map<String, dynamic> messageInfoMap = {
//       "message": message,
//       "sendBy": myUsername,
//       "ts": formattedDate,
//       "time": FieldValue.serverTimestamp(),
//       "imgUrl": myPicture,
//     };

//     messageId = randomAlphaNumeric(10);

//     await Databasemethods().createChatRoom(chatroomId!, {
//       "users": [myUsername, widget.username],
//       "chatroomId": chatroomId,
//     });

//     await Databasemethods().addMessage(chatroomId!, messageId!, messageInfoMap);

//     Map<String, dynamic> lastMessageInfoMap = {
//       "lastmessage": message,
//       "lastmessagesendts": formattedDate,
//       "time": FieldValue.serverTimestamp(),
//       "lastmessagesendby": myUsername,
//     };
//     await Databasemethods().updateLastMessageSend(
//       chatroomId!,
//       lastMessageInfoMap,
//     );

//     // Wait briefly so message is added, then scroll correctly
//     await Future.delayed(const Duration(milliseconds: 300));
//     if (scrollController.hasClients) {
//       scrollController.animateTo(
//         0.0, // since reverse:true, scroll to top = newest message
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Widget messageTile(Map<String, dynamic> message) {
//     bool isMe = message["sendBy"] == myUsername;
//     return Container(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         decoration: BoxDecoration(
//           color: isMe ? const Color(0xff703eff) : Colors.grey[300],
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
//             bottomRight: isMe ? Radius.zero : const Radius.circular(12),
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         child: Text(
//           message["message"] ?? "",
//           style: TextStyle(
//             color: isMe ? Colors.white : Colors.black,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget chatMessages() {
//     if (chatroomId == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(chatroomId)
//           .collection("chats")
//           .orderBy("time", descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         var messages = snapshot.data!.docs;

//         return ListView.builder(
//           controller: scrollController,
//           reverse: true, // newest message appears at bottom visually
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             var message = messages[index].data() as Map<String, dynamic>;
//             return messageTile(message);
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: const Color(0xff703eff),
//       appBar: AppBar(
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xff703eff),
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: NetworkImage(widget.profileurl),
//               radius: screenWidth * 0.06,
//             ),
//             SizedBox(width: screenWidth * 0.03),
//             Flexible(
//               child: Text(
//                 widget.name,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: screenWidth * 0.05,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: chatMessages(),
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.03,
//               vertical: screenWidth * 0.02,
//             ),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xff703eff),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Icon(Icons.mic, color: Colors.white),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.02),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: TextField(
//                       controller: messageController,
//                       style: TextStyle(fontSize: screenWidth * 0.04),
//                       decoration: InputDecoration(
//                         hintText: "Write a message...",
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.04,
//                           vertical: screenWidth * 0.02,
//                         ),
//                         suffixIcon: Icon(Icons.attach_file,
//                             size: screenWidth * 0.06),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.02),
//                 GestureDetector(
//                   onTap: () => addMessage(true),
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: Color(0xff703eff),
//                       shape: BoxShape.circle,
//                     ),
//                     padding: EdgeInsets.all(screenWidth * 0.03),
//                     child: Icon(Icons.send,
//                         color: Colors.white, size: screenWidth * 0.06),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:chatapp_real/services/database.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String profileurl;
  final String username; // This is now LOWERCASE

  const ChatPage({
    Key? key,
    required this.name,
    required this.profileurl,
    required this.username,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? myUsername, myUpperUsername, chatroomId;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Stream<QuerySnapshot>? chatStream; 

  @override
  void initState() {
    super.initState();
    getSharedPref();
  }

  getSharedPref() async {
    myUsername = await SharedPrefreferencesHelper().getUserName();
    
    if (myUsername != null) {
      myUpperUsername = myUsername!.toUpperCase(); // Use UPPERCASE for chatroom logic
      String otherUpperUsername = widget.username.toUpperCase();
      
      chatroomId = getChatRoomIdByUsernames(otherUpperUsername, myUpperUsername!);
      
      if (chatroomId != null) {
        chatStream = Databasemethods().getChatMessages(chatroomId!);
      }
    }
    
    setState(() {});
  }

  String getChatRoomIdByUsernames(String a, String b) {
    // Both 'a' and 'b' should be UPPERCASE usernames
    if (a.compareTo(b) > 0) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  addMessage(bool sendClicked) async {
    if (messageController.text.trim().isEmpty || chatroomId == null || myUpperUsername == null) return;

    String message = messageController.text.trim();
    messageController.clear();
    
    Map<String, dynamic> messageInfoMap = {
      "message": message,
      "sendBy": myUpperUsername, // SendBy is the UPPERCASE username
      "ts": FieldValue.serverTimestamp(), // Timestamp for accurate sorting
      // "imgUrl" is not used in the message tile so we skip saving it here unless needed
    };

    String messageId = randomAlphaNumeric(10);

    // Create chatroom (uses UPPERCASE usernames)
    await Databasemethods().createChatRoom(chatroomId!, {
      "users": [myUpperUsername, widget.username.toUpperCase()],
      "chatroomId": chatroomId,
      "time": FieldValue.serverTimestamp(), // For Home Screen sorting
    });

    // Add message
    await Databasemethods().addMessage(chatroomId!, messageId, messageInfoMap);

    // Update last message info (uses UPPERCASE username)
    Map<String, dynamic> lastMessageInfoMap = {
      "lastmessage": message,
      "time": FieldValue.serverTimestamp(), // For Home screen sorting
      "lastmessagesendby": myUpperUsername,
    };
    
    await Databasemethods().updateLastMessageSend(
      chatroomId!,
      lastMessageInfoMap,
    );

    // Scroll to the newest message
    await Future.delayed(const Duration(milliseconds: 300));
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget messageTile(Map<String, dynamic> message) {
    // Compare sendBy with UPPERCASE username
    bool isMe = message["sendBy"] == myUpperUsername; 
    
    // Get time from Firestore Timestamp
    String timeText = "";
    if (message["ts"] is Timestamp) {
      Timestamp ts = message["ts"] as Timestamp;
      timeText = DateFormat('h:mma').format(ts.toDate());
    }

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xff703eff) : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              message["message"] ?? "...",
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
          ),
          if (timeText.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 2, right: isMe ? 4 : 0, left: isMe ? 0 : 4),
              child: Text(
                timeText,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget chatMessages() {
    if (chatroomId == null || chatStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: chatStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Start a conversation with ${widget.name}",
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        var messages = snapshot.data!.docs;

        return ListView.builder(
          controller: scrollController,
          reverse: true, // newest message appears at bottom visually
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index].data() as Map<String, dynamic>;
            return messageTile(message);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... build method remains the same ...
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff703eff),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.profileurl.isNotEmpty ? NetworkImage(widget.profileurl) : null,
              radius: screenWidth * 0.06,
              backgroundColor: Colors.white,
              child: widget.profileurl.isEmpty ? const Icon(Icons.person, color: Color(0xff703eff)) : null,
            ),
            SizedBox(width: screenWidth * 0.03),
            Flexible(
              child: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: chatMessages(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.02,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff703eff),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.mic, color: Colors.white),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                      decoration: InputDecoration(
                        hintText: "Write a message...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenWidth * 0.02,
                        ),
                        suffixIcon: Icon(Icons.attach_file,
                            size: screenWidth * 0.06),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () => addMessage(true),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff703eff),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: Icon(Icons.send,
                        color: Colors.white, size: screenWidth * 0.06),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}