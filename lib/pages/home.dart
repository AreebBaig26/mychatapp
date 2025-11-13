
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp_real/services/database.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:chatapp_real/pages/chat_page.dart';
import 'package:chatapp_real/pages/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? myUsername, myName, myPicture;
  Stream<QuerySnapshot>? chatRoomStream;

  TextEditingController searchController = TextEditingController();
  bool searching = false;
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    myUsername = await SharedPrefreferencesHelper().getUserName();
    myName = await SharedPrefreferencesHelper().GetUserDisplayName();
    myPicture = await SharedPrefreferencesHelper().GetUserImage();
    chatRoomStream = await Databasemethods().getChatRooms();
    setState(() {});
  }

  String getChatRoomIdByUsername(String a, String b) {
    return (a.compareTo(b) > 0) ? "${b}_$a" : "${a}_$b";
  }

  Future<void> initiateSearch(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        searching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() => searching = true);
    QuerySnapshot snapshot = await Databasemethods().Search(value);
    List<Map<String, dynamic>> temp = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data["Username"].toString().toLowerCase().startsWith(value.toLowerCase())) {
        temp.add(data);
      }
    }
    setState(() => searchResults = temp);
  }

  Widget chatRoomList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No chats yet 😊"));

        var docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var docData = docs[index].data() as Map<String, dynamic>;
            // String chatRoomId = docs[index].id;
            String lastMessage = docData["lastmessage"] ?? "";

            // Timestamp fix
            Timestamp? ts;
            if (docData["lastmessagesendts"] is Timestamp) {
              ts = docData["lastmessagesendts"] as Timestamp;
            }

            String timeText = ts != null
                ? "${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}"
                : "";

            List users = docData["users"] ?? [];
            String otherUser = users.firstWhere((u) => u != myUsername, orElse: () => "");

            return FutureBuilder<QuerySnapshot>(
              future: Databasemethods().getUserInfo(otherUser),
              builder: (context, userSnap) {
                String name = "";
                String image = "";
                if (userSnap.hasData && userSnap.data!.docs.isNotEmpty) {
                  name = userSnap.data!.docs[0]["Name"] ?? "";
                  image = userSnap.data!.docs[0]["Image"] ?? "";
                }

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          name: name,
                          profileurl: image,
                          username: otherUser,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                    backgroundColor: image.isEmpty ? Colors.grey.shade400 : Colors.transparent,
                    child: image.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  title: Text(name),
                  subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget searchList() {
    return searchResults.isEmpty
        ? const Center(child: Text("No user found 😕"))
        : ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              var data = searchResults[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data["Image"] ?? ""),
                ),
                title: Text(data["Username"] ?? ""),
                subtitle: Text(data["Name"] ?? ""),
                onTap: () {
                  String chatRoomId = getChatRoomIdByUsername(myUsername!, data["Username"]);
                  Map<String, dynamic> chatInfoMap = {
                    "users": [myUsername, data["Username"]],
                    "lastmessage": "",
                    "lastmessagesendts": FieldValue.serverTimestamp(),
                  };
                  Databasemethods().createChatRoom(chatRoomId, chatInfoMap);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        name: data["Name"],
                        profileurl: data["Image"],
                        username: data["Username"],
                      ),
                    ),
                  );
                },
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenW * 0.05, vertical: screenH * 0.02),
              child: Row(
                children: [
                  Image.asset("images/wave.png", height: screenH * 0.05),
                  SizedBox(width: screenW * 0.02),
                  Expanded(
                    child: Text(
                      "Hello, ${myName ?? ''}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenW * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    ),
                    child: CircleAvatar(
                      radius: screenW * 0.06,
                      backgroundColor: Colors.white,
                      backgroundImage: (myPicture != null && myPicture!.isNotEmpty)
                          ? NetworkImage(myPicture!)
                          : null,
                      child: (myPicture == null || myPicture!.isEmpty)
                          ? const Icon(Icons.person, color: Color(0xff703eff))
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: screenW * 0.05),
              child: Text(
                "Welcome To",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenW * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: screenW * 0.05, bottom: screenH * 0.015),
              child: Text(
                "Chat Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenW * 0.09,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: searchController,
                onChanged: initiateSearch,
                decoration: InputDecoration(
                  hintText: "Search Username...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Chat/List container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: searching ? searchList() : chatRoomList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
