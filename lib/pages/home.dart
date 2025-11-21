// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:chatapp_real/services/database.dart';
// import 'package:chatapp_real/services/shared_pref.dart';
// import 'package:chatapp_real/pages/chat_page.dart';
// import 'package:chatapp_real/pages/profile.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String? myUsername, myName, myPicture;
//   Stream<QuerySnapshot>? chatRoomStream;

//   TextEditingController searchController = TextEditingController();
//   bool searching = false;
//   List<Map<String, dynamic>> searchResults = [];

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   Future<void> loadData() async {
//     myUsername = await SharedPrefreferencesHelper().getUserName();
//     myName = await SharedPrefreferencesHelper().GetUserDisplayName();
//     myPicture = await SharedPrefreferencesHelper().GetUserImage();
//     chatRoomStream = await Databasemethods().getChatRooms();
//     setState(() {});
//   }

//   String getChatRoomIdByUsername(String a, String b) {
//     return (a.compareTo(b) > 0) ? "${b}_$a" : "${a}_$b";
//   }

//   Future<void> initiateSearch(String value) async {
//     if (value.trim().isEmpty) {
//       setState(() {
//         searching = false;
//         searchResults.clear();
//       });
//       return;
//     }

//     setState(() => searching = true);
//     QuerySnapshot snapshot = await Databasemethods().Search(value);
//     List<Map<String, dynamic>> temp = [];

//     for (var doc in snapshot.docs) {
//       var data = doc.data() as Map<String, dynamic>;
//       if (data["Username"].toString().toLowerCase().startsWith(value.toLowerCase())) {
//         temp.add(data);
//       }
//     }
//     setState(() => searchResults = temp);
//   }

//   Widget chatRoomList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: chatRoomStream,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//         if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No chats yet 😊"));

//         var docs = snapshot.data!.docs;

//         return ListView.builder(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//           itemCount: docs.length,
//           itemBuilder: (context, index) {
//             var docData = docs[index].data() as Map<String, dynamic>;
//             String lastMessage = docData["lastmessage"] ?? "";

//             // Timestamp fix
//             Timestamp? ts;
//             if (docData["lastmessagesendts"] is Timestamp) {
//               ts = docData["lastmessagesendts"] as Timestamp;
//             }

//             String timeText = ts != null
//                 ? "${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}"
//                 : "";

//             List users = docData["users"] ?? [];
//             String otherUser = users.firstWhere((u) => u != myUsername, orElse: () => "");

//             return FutureBuilder<QuerySnapshot>(
//               future: Databasemethods().getUserInfo(otherUser),
//               builder: (context, userSnap) {
//                 String name = "";
//                 String image = "";
//                 if (userSnap.hasData && userSnap.data!.docs.isNotEmpty) {
//                   name = userSnap.data!.docs[0]["Name"] ?? "";
//                   image = userSnap.data!.docs[0]["Image"] ?? "";
//                 }

//                 return Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ChatPage(
//                             name: name,
//                             profileurl: image,
//                             username: otherUser,
//                           ),
//                         ),
//                       );
//                     },
//                     leading: CircleAvatar(
//                       radius: 28,
//                       backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
//                       backgroundColor: image.isEmpty ? Colors.grey.shade400 : Colors.transparent,
//                       child: image.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
//                     ),
//                     title: Text(
//                       name,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(
//                       lastMessage,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: Colors.grey.shade600),
//                     ),
//                     trailing: Text(
//                       timeText,
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget searchList() {
//     return searchResults.isEmpty
//         ? const Center(child: Text("No user found 😕"))
//         : ListView.builder(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//             itemCount: searchResults.length,
//             itemBuilder: (context, index) {
//               var data = searchResults[index];
//               return Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                 margin: const EdgeInsets.symmetric(vertical: 6),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//                   leading: CircleAvatar(
//                     radius: 28,
//                     backgroundImage: NetworkImage(data["Image"] ?? ""),
//                     backgroundColor: Colors.grey.shade300,
//                   ),
//                   title: Text(
//                     data["Username"] ?? "",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(data["Name"] ?? ""),
//                   onTap: () {
//                     String chatRoomId = getChatRoomIdByUsername(myUsername!, data["Username"]);
//                     Map<String, dynamic> chatInfoMap = {
//                       "users": [myUsername, data["Username"]],
//                       "lastmessage": "",
//                       "lastmessagesendts": FieldValue.serverTimestamp(),
//                     };
//                     Databasemethods().createChatRoom(chatRoomId, chatInfoMap);

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatPage(
//                           name: data["Name"],
//                           profileurl: data["Image"],
//                           username: data["Username"],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenW = MediaQuery.of(context).size.width;
//     double screenH = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: const Color(0xff703eff),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Padding(
//               padding: EdgeInsets.symmetric(
//                   horizontal: screenW * 0.05, vertical: screenH * 0.02),
//               child: Row(
//                 children: [
//                   Image.asset("images/wave.png", height: screenH * 0.05),
//                   SizedBox(width: screenW * 0.02),
//                   Expanded(
//                     child: Text(
//                       "Hello, ${myName ?? ''}",
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: screenW * 0.06,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const Profile()),
//                     ),
//                     child: CircleAvatar(
//                       radius: screenW * 0.06,
//                       backgroundColor: Colors.white,
//                       backgroundImage: (myPicture != null && myPicture!.isNotEmpty)
//                           ? NetworkImage(myPicture!)
//                           : null,
//                       child: (myPicture == null || myPicture!.isEmpty)
//                           ? const Icon(Icons.person, color: Color(0xff703eff))
//                           : null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding: EdgeInsets.only(left: screenW * 0.05),
//               child: Text(
//                 "Welcome To",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: screenW * 0.05,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: screenW * 0.05, bottom: screenH * 0.015),
//               child: Text(
//                 "Chat Up",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: screenW * 0.09,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             // Search
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextField(
//                 controller: searchController,
//                 onChanged: initiateSearch,
//                 decoration: InputDecoration(
//                   hintText: "Search Username...",
//                   prefixIcon: const Icon(Icons.search),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Chat/List container
//             Expanded(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//                 ),
//                 child: searching ? searchList() : chatRoomList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp_real/services/database.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:chatapp_real/pages/chat_page.dart';
import 'package:chatapp_real/pages/profile.dart';
import 'package:intl/intl.dart'; // Added for time formatting

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

  // FIX: Added setState after setting chatRoomStream
  Future<void> loadData() async {
    myUsername = await SharedPrefreferencesHelper().getUserName();
    myName = await SharedPrefreferencesHelper().GetUserDisplayName();
    myPicture = await SharedPrefreferencesHelper().GetUserImage();
    
    if (myUsername != null) {
      // Ensure username is converted to UPPERCASE for database query comparison, 
      // as it's saved in Firestore as UPPERCASE (from Authmethods)
      chatRoomStream = await Databasemethods().getChatRooms(myUsername!.toUpperCase());
    }
    
    setState(() {});
  }

  String getChatRoomIdByUsername(String a, String b) {
    // Ensuring comparison happens on the same case
    String u1 = a.toUpperCase();
    String u2 = b.toUpperCase();
    return (u1.compareTo(u2) > 0) ? "${u2}_$u1" : "${u1}_$u2";
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
    QuerySnapshot snapshot = await Databasemethods().Search(value.toUpperCase());
    List<Map<String, dynamic>> temp = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      // Filter out the current user and check startsWith on UPPERCASE username
      if (data["Username"].toString() != myUsername?.toUpperCase() &&
          data["Username"].toString().startsWith(value.toUpperCase())) {
        temp.add(data);
      }
    }
    setState(() => searchResults = temp);
  }

  Widget chatRoomList() {
    if (myUsername == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (chatRoomStream == null) {
      // If loadData() failed to get the stream
      return const Center(child: Text("Error loading chats or username not found."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No chats yet 😊"));
        }

        var docs = snapshot.data!.docs;

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var docData = docs[index].data() as Map<String, dynamic>;
            String lastMessage = docData["lastmessage"] ?? "";

            // FIX: Use 'time' which is the server timestamp for sorting and display
            Timestamp? ts;
            if (docData["time"] is Timestamp) {
              ts = docData["time"] as Timestamp;
            }

            String timeText = ts != null
                ? DateFormat('h:mma').format(ts.toDate())
                : "";

            List users = docData["users"] ?? [];
            
            // Find the other user (compare with UPPERCASE username saved in chatroom)
            String otherUserUsername = users.firstWhere(
              (u) => u != myUsername!.toUpperCase(), 
              orElse: () => ""
            );
            
            // Get the original username for passing to ChatPage
            String originalOtherUsername = otherUserUsername.toLowerCase(); 

            // Use FutureBuilder to get the other user's display name and image
            return FutureBuilder<QuerySnapshot>(
              // Fetch user info based on the UPPERCASE username
              future: Databasemethods().getUserInfo(otherUserUsername),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80, 
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                
                String name = originalOtherUsername; // Default name is username
                String image = "";
                if (userSnap.hasData && userSnap.data!.docs.isNotEmpty) {
                  name = userSnap.data!.docs[0]["Name"] ?? originalOtherUsername;
                  image = userSnap.data!.docs[0]["Image"] ?? "";
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            name: name,
                            profileurl: image,
                            username: originalOtherUsername, // Pass lowercase username
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                      backgroundColor: image.isEmpty ? Colors.grey.shade400 : Colors.transparent,
                      child: image.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Text(
                      timeText,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              var data = searchResults[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(data["Image"] ?? ""),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  title: Text(
                    data["Username"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data["Name"] ?? ""),
                  onTap: () {
                    // ChatRoomId uses UPPERCASE usernames from Firestore
                    String myUpperUsername = myUsername!.toUpperCase();
                    String otherUpperUsername = data["Username"];

                    String chatRoomId = getChatRoomIdByUsername(myUpperUsername, otherUpperUsername);
                    Map<String, dynamic> chatInfoMap = {
                      // Storing UPPERCASE usernames in the chatroom
                      "users": [myUpperUsername, otherUpperUsername], 
                      "lastmessage": "",
                      "time": FieldValue.serverTimestamp(), // For sorting
                    };
                    Databasemethods().createChatRoom(chatRoomId, chatInfoMap);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          name: data["Name"],
                          profileurl: data["Image"],
                          username: otherUpperUsername.toLowerCase(), // Passing lowercase username
                        ),
                      ),
                    );
                  },
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: initiateSearch,
                decoration: InputDecoration(
                  hintText: "Search Username...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

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