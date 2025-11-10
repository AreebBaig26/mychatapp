import 'package:chatapp_real/services/database.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  String name, profileurl, username;
  ChatPage({
    required this.name,
    required this.profileurl,
    required this.username,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? MyUsername, MyName, MyEmail, Mypicture, chatroomId, messageId;
  TextEditingController MessageController = new TextEditingController();
  getthesharedpref() async {
    MyUsername = await SharedPrefreferencesHelper().GetUserName();
    MyName = await SharedPrefreferencesHelper().GetUserDisplayName();
    MyEmail = await SharedPrefreferencesHelper().GetUserEmail();
    Mypicture = await SharedPrefreferencesHelper().GetUserImage();
    chatroomId = getthechatroomIdbyUsername(widget.username, MyUsername!);
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  getthechatroomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b/_$a";
    } else {
      return "$a/_$b";
    }
  }

  addmessage(bool sendClicked) async {
    if (MessageController.text != "") {
      String message = MessageController.text;
      MessageController.text = "";
      DateTime Now = DateTime.now();
      String Formatteddate = DateFormat('h:mma').format(Now);
      Map<String, dynamic> MessageinfoMap = {
        "message": message,
        "sendBy": MyUsername,
        "ts": Formatteddate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": Mypicture,
      };
      messageId = randomAlphaNumeric(10);
      await Databasemethods()
          .addMessge(chatroomId!, messageId!, MessageinfoMap)
          .then((Value) {
            Map<String, dynamic> LastMessageInfoMap = {
              "lastmessage": message,
              "lastmessagesendts": Formatteddate,
              "time": FieldValue.serverTimestamp(),
              "lastmessagesendby": MyUsername,
            };
            Databasemethods().Updatelastmessagesend(
              chatroomId!,
              LastMessageInfoMap,
            );
            if (sendClicked) {
              message = "";
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff703eff),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff703eff),
        title: Text(
          "Izhan Baig",
          // textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color.fromARGB(255, 238, 219, 219),
            fontSize: 23.0,
            fontWeight: FontWeight.bold,
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff703eff),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Hello,How are you..?",
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            // fontSize: 23.0,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "I am fine",
                              // textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                // fontSize: 23.0,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 1.70),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            // margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Color(0xff703eff),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.mic,
                                //  size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: MessageController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.attach_file),
                                hintText: " Write a message...",
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            // margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Color(0xff703eff),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.send,
                                // size: 3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
