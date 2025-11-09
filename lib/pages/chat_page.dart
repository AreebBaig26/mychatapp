import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
