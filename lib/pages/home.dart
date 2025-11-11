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

  @override
  void initState() {
    super.initState();
    getSharedPref();
  }

  getSharedPref() async {
    myUsername = await SharedPrefreferencesHelper().getUserName();
    myName = await SharedPrefreferencesHelper().GetUserDisplayName();
    myEmail = await SharedPrefreferencesHelper().GetUserEmail();
    myPicture = await SharedPrefreferencesHelper().GetUserImage();
    setState(() {});
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.compareTo(b) > 0) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  TextEditingController searchController = TextEditingController();
  bool searching = false;
  List<Map<String, dynamic>> searchResults = [];

  initiateSearch(String value) async {
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

    print("Searching for: $value");

    QuerySnapshot snapshot = await Databasemethods().Search(value);

    List<Map<String, dynamic>> temp = [];
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      print("Found: ${data["Username"]}");
      if (data["Username"]
          .toString()
          .toLowerCase()
          .startsWith(value.toLowerCase())) {
        temp.add(data);
      }
    }

    setState(() {
      searchResults = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 15),
              child: Row(
                children: [
                  Image.asset("images/wave.png", height: 40),
                  const SizedBox(width: 10),
                  const Text(
                    "Hello,",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    " ${myName ?? ''}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
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
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Welcome To",
                style: TextStyle(
                    color: Color.fromARGB(255, 238, 219, 219),
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              child: Text(
                "Chat Up",
                style: TextStyle(
                    color: Color.fromARGB(255, 238, 219, 219),
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),

            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffececf8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    initiateSearch(value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search Username...",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Results + Static Tile
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: searching
                    ? searchResults.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                    : Column(
                        children: [
                          const SizedBox(height: 10),
                          Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: MediaQuery.of(context).size.width,
                                child: ListTile(
                                  onTap: () {
                                    searching = false;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          name: 'Areebb Baig',
                                          profileurl: 'images/boy.jpg',
                                          username: 'Areeb',
                                        ),
                                      ),
                                    );
                                  },
                                  leading: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                      "images/boy.jpg",
                                    ),
                                  ),
                                  title: const Text(
                                    "Areebb Baig",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: const Text("How are you..?"),
                                  trailing: const Text("7:15 PM"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(Map<String, dynamic> data) {
    return ListTile(
      onTap: () async {
        if (myUsername == null) return;

        var chatRoomId =
            getChatRoomIdByUsername(myUsername!, data["Username"]);

        Map<String, dynamic> chatInfoMap = {
          "users": [myUsername, data["Username"]],
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
      leading: CircleAvatar(
        backgroundImage: NetworkImage(data["Image"] ?? ""),
      ),
      title: Text(
        data["Username"] ?? "",
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(data["Name"] ?? ""),
      trailing: const Icon(Icons.chat_bubble_outline),
    );
  }
}


// import 'package:chatapp_real/pages/chat_page.dart';
// import 'package:chatapp_real/services/database.dart';
// import 'package:chatapp_real/services/shared_pref.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String? myUsername, myName, myEmail, myPicture;

//   getTheChatRoomIdByUsername(String a, String b) {
//     if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
//       return "${b}_$a";
//     } else {
//       return "${a}_$b";
//     }
//   }

//   TextEditingController searchController = TextEditingController();

//   getTheSharedPref() async {
//     myUsername = await SharedPrefreferencesHelper().getUserName();
//     myName = await SharedPrefreferencesHelper().GetUserDisplayName();
//     myEmail = await SharedPrefreferencesHelper().GetUserEmail();
//     myPicture = await SharedPrefreferencesHelper().GetUserImage();
//     setState(() {});
//   }

//   bool search = false;
//   List queryResultSet = [];
//   List tempSearchStore = [];

//   initiateSearch(String value) {
//     if (value.isEmpty) {
//       setState(() {
//         queryResultSet = [];
//         tempSearchStore = [];
//         search = false;
//       });
//       return;
//     }

//     setState(() {
//       search = true;
//     });

//     var capitalizedValue =
//         value.substring(0, 1).toUpperCase() + value.substring(1);

//     if (queryResultSet.isEmpty && value.length == 1) {
//       Databasemethods().Search(value).then((QuerySnapshot docs) {
//         for (int i = 0; i < docs.docs.length; i++) {
//           queryResultSet.add(docs.docs[i].data());
//         }
//         setState(() {});
//       });
//     } else {
//       tempSearchStore = [];
//       for (var element in queryResultSet) {
//         if (element['Username'].toString().startsWith(capitalizedValue)) {
//           tempSearchStore.add(element);
//         }
//       }
//       setState(() {});
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getTheSharedPref();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff703eff),
//       body: Container(
//         margin: const EdgeInsets.only(top: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: Row(
//                 children: [
//                   Image.asset("images/wave.png", height: 40),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Hello,",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 23.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Text(
//                     " Areeb",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 23.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     margin: const EdgeInsets.only(right: 15),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(
//                       Icons.person,
//                       size: 30,
//                       color: Color(0xff703eff),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.only(left: 20),
//               child: Text(
//                 "Welcome To",
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 238, 219, 219),
//                   fontSize: 23.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.only(left: 20),
//               child: Text(
//                 "Chat Up",
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 238, 219, 219),
//                   fontSize: 32.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xffececf8),
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: TextField(
//                           controller: searchController,
//                           onChanged: (value) {
//                             initiateSearch(value);
//                           },
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             prefixIcon: const Icon(Icons.search),
//                             hintText: "Search Username...",
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     search
//                         ? Expanded(
//                             child: ListView(
//                               padding: const EdgeInsets.only(
//                                 left: 10,
//                                 right: 10,
//                               ),
//                               primary: false,
//                               shrinkWrap: true,
//                               children: tempSearchStore.map((element) {
//                                 return buildResultCard(element);
//                               }).toList(),
//                             ),
//                           )
//                         : Material(
//                             elevation: 3.0,
//                             borderRadius: BorderRadius.circular(10),
//                             child: Padding(
//                               padding: const EdgeInsets.all(5),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 width: MediaQuery.of(context).size.width,
//                                 child: ListTile(
//                                   onTap: () {
//                                     search = false;
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => ChatPage(
//                                           name: '',
//                                           profileurl: '',
//                                           username: '',
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   leading: const CircleAvatar(
//                                     backgroundImage: AssetImage(
//                                       "images/boy.jpg",
//                                     ),
//                                   ),
//                                   title: const Text(
//                                     "Areebb Baig",
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: const Text("How are you..?"),
//                                   trailing: const Text("7:15 PM"),
//                                 ),
//                               ),
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildResultCard(data) {
//     return ListTile(
//       onTap: () async {
//         search = false;
//         var chatRoomId = getTheChatRoomIdByUsername(
//           myUsername!,
//           data["Username"],
//         );
//         Map<String, dynamic> chatInfoMap = {
//           "users": [myUsername, data["Username"]],
//         };
//         await Databasemethods().createChatRoom(chatRoomId, chatInfoMap);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatPage(
//               name: data["Name"],
//               profileurl: data["Image"],
//               username: data["Username"],
//             ),
//           ),
//         );
//       },
//       leading: CircleAvatar(backgroundImage: NetworkImage(data["Image"])),
//       title: Text(
//         data["Username"],
//         style: const TextStyle(
//           color: Colors.black,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       subtitle: Text(data["Name"]),
//       trailing: const Text("7:15 PM"),
//     );
//   }
// }




// import 'package:chatapp_real/pages/chat_page.dart';
// import 'package:chatapp_real/services/database.dart';
// import 'package:chatapp_real/services/shared_pref.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String? MyUsername, MyName, MyEmail, Mypicture;

//   getthechatroomIdbyUsername(String a, String b) {
//     if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
//       return "$b/_$a";
//     } else {
//       return "$a/_$b";
//     }
//   }

//   TextEditingController searchController = new TextEditingController();

//   getthesharedpref() async {
//     MyUsername = await SharedPrefreferencesHelper().getUserName();
//     MyName = await SharedPrefreferencesHelper().GetUserDisplayName();
//     MyEmail = await SharedPrefreferencesHelper().GetUserEmail();
//     Mypicture = await SharedPrefreferencesHelper().GetUserImage();
//     setState(() {});
//   }

//   bool search = false;
//   var queryResultSet = [];
//   var tempSearchstore = [];

//   initiateSearch(value) {
//     if (value.lenght == 0) {
//       setState(() {
//         queryResultSet = [];
//         tempSearchstore = [];
//       });
//     }
//     setState(() {
//       search = true;
//     });
//     var capitalizedValue =
//         value.substring(0, 1).toUpperCase() + value.substring(1);
//     if (queryResultSet.isEmpty && value.lenght == 1) {
//       Databasemethods().Search(value).then((QuerySnapshot docs) {
//         for (int i = 0; i < docs.docs.length; i++) {
//           queryResultSet.add(docs.docs[i].data());
//         }
//       });
//     } else {
//       tempSearchstore = [];
//       queryResultSet.forEach((element) {
//         if (element['Username'].startswith(capitalizedValue)) {
//           setState(() {
//             tempSearchstore.add(element);
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff703eff),
//       body: Container(
//         margin: EdgeInsets.only(top: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: Row(
//                 children: [
//                   Image.asset("images/wave.png", height: 40),
//                   SizedBox(width: 10),
//                   Text(
//                     "Hello,",
//                     // textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 23.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     " Areeb",
//                     // textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 23.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Spacer(),
//                   Container(
//                     margin: EdgeInsets.only(right: 15),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Icon(
//                       Icons.person,
//                       size: 30,
//                       color: Color(0xff703eff),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: Text(
//                 "Welcome To",
//                 // textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: const Color.fromARGB(255, 238, 219, 219),
//                   fontSize: 23.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: Text(
//                 "Chat Up",
//                 // textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: const Color.fromARGB(255, 238, 219, 219),
//                   fontSize: 32.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Color(0xffececf8),
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: TextField(
//                           controller: searchController,
//                           onChanged: (value) {
//                             initiateSearch(value.toUpperCase());
//                           },
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             prefixIcon: Icon(Icons.search),
//                             hintText: "Search Username...",
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     search
//                         ? ListView(
//                             padding: EdgeInsets.only(left: 10, right: 10),
//                             primary: false,
//                             shrinkWrap: false,
//                             children: tempSearchstore.map((element) {
//                               return buildResultcard(element);
//                             }).toList(),
//                           )
//                         : Material(
//                             elevation: 3.0,
//                             borderRadius: BorderRadius.circular(10),
//                             child: Padding(
//                               padding: const EdgeInsets.all(5),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 width: MediaQuery.of(context).size.width,
//                                 child: ListTile(
//                                   onTap: () {
//                                     search = false;
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => ChatPage(
//                                           name: '',
//                                           profileurl: '',
//                                           username: '',
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   // shape: RoundedRectangleBorder(),
//                                   leading: CircleAvatar(
//                                     backgroundImage: AssetImage(
//                                       "images/boy.jpg",
//                                     ),
//                                   ),
//                                   title: Text(
//                                     "Areebb Baig",
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: Text("How are you..?"),
//                                   trailing: Text("7:15 PM"),
//                                 ),
//                               ),
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildResultcard(data) {
//     return ListTile(
//       onTap: () async {
//         search = false;
//         var chatRoomId = getthechatroomIdbyUsername(
//           MyUsername!,
//           data["Username"],
//         );
//         Map<String, dynamic> chatinfoMap = {
//           "users": [MyUsername, data["Username"]],
//         };
//         await Databasemethods().createChatRoom(chatRoomId, chatinfoMap);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatPage(
//               name: data["Name"],
//               profileurl: data["Image"],
//               username: data["Username"],
//             ),
//           ),
//         );
//       },
//       // shape: RoundedRectangleBorder(),
//       leading: CircleAvatar(backgroundImage: NetworkImage(data["Image"])),
//       title: Text(
//         data["Username"],
//         style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(data["Name"]),
//       trailing: Text("7:15 PM"),
//     );
//   }
// }

