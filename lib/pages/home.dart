import 'package:chatapp_real/pages/chat_page.dart';
import 'package:chatapp_real/services/database.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? myUsername, myName, myEmail, myPicture;
  Stream<QuerySnapshot>? chatRoomStream;

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  // Load user data and chat rooms
  Future<void> onTheLoad() async {
    await getSharedPref();
    chatRoomStream = await Databasemethods().getChatRooms();
    setState(() {});
  }

  Future<void> getSharedPref() async {
    myUsername = await SharedPrefreferencesHelper().getUserName();
    myName = await SharedPrefreferencesHelper().GetUserDisplayName();
    myEmail = await SharedPrefreferencesHelper().GetUserEmail();
    myPicture = await SharedPrefreferencesHelper().GetUserImage();
    setState(() {});
  }

  // Generate chatroom id
  String getChatRoomIdByUsername(String a, String b) {
    if (a.compareTo(b) > 0) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  TextEditingController searchController = TextEditingController();
  bool searching = false;
  List<Map<String, dynamic>> searchResults = [];

  // Search users
  Future<void> initiateSearch(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        searching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      searching = true;
    });

    QuerySnapshot snapshot = await Databasemethods().Search(value);

    List<Map<String, dynamic>> temp = [];
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data["Username"].toString().toLowerCase().startsWith(
        value.toLowerCase(),
      )) {
        temp.add(data);
      }
    }

    setState(() {
      searchResults = temp;
    });
  }

  // Chatroom list
  Widget chatRoomList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No chats yet 😊",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        var docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var ds = docs[index];
            return ChatRoomTile(
              chatRoomId: ds.id,
              lastMessage: ds["lastmessage"] ?? "",
              myUsername: myUsername ?? "",
              time: ds["lastmessagesendts"] ?? "",
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      body: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset("images/wave.png", height: 40),
                  const SizedBox(width: 10),
                  const Text(
                    "Hello, ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    myName ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xff703eff),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Text(
                "Welcome To",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 15),
              child: Text(
                "Chat Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffececf8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: initiateSearch,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search Username...",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Body
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: searching
                    ? searchResults.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                var data = searchResults[index];
                                return buildResultCard(data);
                              },
                            )
                          : const Center(
                              child: Text(
                                "No user found 😕",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: chatRoomList(),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search result tile
  Widget buildResultCard(Map<String, dynamic> data) {
    return ListTile(
      onTap: () async {
        if (myUsername == null) return;

        String chatRoomId = getChatRoomIdByUsername(
          myUsername!,
          data["Username"],
        );

        Map<String, dynamic> chatInfoMap = {
          "users": [myUsername, data["Username"]],
          "lastmessage": "",
          "lastmessagesendts": "",
        };

        await Databasemethods().createChatRoom(chatRoomId, chatInfoMap);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: data["Name"],
              profileurl: data["Image"],
              username: data["Username"],
            ),
          ),
        );
      },
      leading: CircleAvatar(backgroundImage: NetworkImage(data["Image"] ?? "")),
      title: Text(
        data["Username"] ?? "",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(data["Name"] ?? ""),
      trailing: const Icon(Icons.chat_bubble_outline),
    );
  }
}

// Chat Room Tile
class ChatRoomTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  const ChatRoomTile({
    super.key,
    required this.chatRoomId,
    required this.lastMessage,
    required this.myUsername,
    required this.time,
  });

  @override
  State<ChatRoomTile> createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username = widget.chatRoomId
        .replaceAll("_", "")
        .replaceAll(widget.myUsername, "");

    QuerySnapshot querySnapshot = await Databasemethods().getUserInfo(username);

    if (querySnapshot.docs.isNotEmpty) {
      name = querySnapshot.docs[0]["Name"];
      profilePicUrl = querySnapshot.docs[0]["Image"];
      // id = querySnapshot.docs[0]["Id"];
    }

    if (!mounted) return;
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    getThisUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: name,
              profileurl: profilePicUrl,
              username: username,
            ),
          ),
        );
      },
      leading: profilePicUrl.isEmpty
          ? const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            )
          : CircleAvatar(backgroundImage: NetworkImage(profilePicUrl)),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(widget.lastMessage),
      trailing: Text(
        widget.time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
