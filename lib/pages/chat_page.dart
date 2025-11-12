import 'package:chatapp_real/services/database.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String profileurl;
  final String username;

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
  String? MyUsername, MyName, MyEmail, Mypicture, chatroomId, messageId;
  TextEditingController MessageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  getthesharedpref() async {
    MyUsername = await SharedPrefreferencesHelper().getUserName();
    MyName = await SharedPrefreferencesHelper().GetUserDisplayName();
    MyEmail = await SharedPrefreferencesHelper().GetUserEmail();
    Mypicture = await SharedPrefreferencesHelper().GetUserImage();
    chatroomId = getChatRoomIdByUsernames(widget.username, MyUsername!);
    setState(() {});
  }

  // Generate chatroom ID safely
  String getChatRoomIdByUsernames(String a, String b) {
    if (a.compareTo(b) > 0) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }
  addmessage(bool sendClicked) async {
    if (MessageController.text.trim() != "") {
      String message = MessageController.text.trim();
      MessageController.text = "";

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": MyUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": Mypicture,
      };

      messageId = randomAlphaNumeric(10);

      await Databasemethods().createChatRoom(chatroomId!, {
        "users": [MyUsername, widget.username],
        "chatroomId": chatroomId,
      });

      await Databasemethods()
          .addMessage(chatroomId!, messageId!, messageInfoMap)
          .then((value) {
            Map<String, dynamic> lastMessageInfoMap = {
              "lastmessage": message,
              "lastmessagesendts": formattedDate,
              "time": FieldValue.serverTimestamp(),
              "lastmessagesendby": MyUsername,
            };
            Databasemethods().updateLastMessageSend(
              chatroomId!,
              lastMessageInfoMap,
            );
            if (sendClicked) message = "";

            scrollController.animateTo(
              scrollController.position.maxScrollExtent + 60,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
    }
  }

  // Chat bubble widget
  Widget messageTile(Map<String, dynamic> message) {
    bool isMe = message["sendBy"] == MyUsername;
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? Color(0xff703eff) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          message["message"] ?? "",
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // StreamBuilder for chat messages
  Widget chatMessages() {
    if (chatroomId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatroomId)
          .collection("chats")
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        var messages = snapshot.data!.docs;
        // Scroll to bottom when new message arrives
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        return ListView.builder(
          controller: scrollController,
          itemCount: messages.length,
          reverse: true,
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
    return Scaffold(
      backgroundColor: Color(0xff703eff),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff703eff),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.profileurl)),
            SizedBox(width: 10),
            Text(
              widget.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
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
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff703eff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.mic, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: MessageController,
                      decoration: InputDecoration(
                        hintText: "Write a message...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        suffixIcon: Icon(Icons.attach_file),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    addmessage(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff703eff),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
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